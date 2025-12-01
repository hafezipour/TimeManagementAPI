USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_LogTransactionsWithPeriodDate]    Script Date: 11/27/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Auto Generated
-- Create date: 11/27/2025
-- Description: Log accrual transactions in bulk with AccrualPeriodDate
--              Takes JSON array with bankId, userId, accrualProfileId, accrualRulesSlotId, 
--              oldBalance, newBalance, operator, adjustmentAmount, notes
--              Extracts AccrualPeriodDate from notes field (format: "Accrual for period YYYY-MM-DD")
--              Inserts records into AccrualTransactions table with AccrualPeriodDate
--              Returns array of inserted transaction records
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_LogTransactionsWithPeriodDate]
    @Json NVARCHAR(MAX),
    @CreatedBy INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON input (matching the provided format)
        DECLARE @Transactions TABLE (
            TempId INT IDENTITY(1,1),
            BankId INT,
            UserId INT,
            AccrualProfileId INT,
            AccrualRulesSlotId INT,
            OldBalance DECIMAL(10, 2),
            NewBalance DECIMAL(10, 2),
            Operator VARCHAR(1),
            AdjustmentAmount DECIMAL(10, 2),
            Notes NVARCHAR(MAX) NULL,
            AccrualPeriodDate DATE,
            HasError BIT DEFAULT 0
        );

        -- Insert parsed JSON data and extract period date from notes
        INSERT INTO @Transactions (BankId, UserId, AccrualProfileId, AccrualRulesSlotId, OldBalance, NewBalance, Operator, AdjustmentAmount, Notes, AccrualPeriodDate, HasError)
        SELECT 
            BankId,
            UserId,
            AccrualProfileId,
            AccrualRulesSlotId,
            OldBalance,
            NewBalance,
            Operator,
            AdjustmentAmount,
            Notes,
            -- Extract date from notes: "Accrual for period YYYY-MM-DD" format
            CASE 
                WHEN Notes IS NOT NULL AND Notes LIKE '%period%' THEN
                    TRY_CAST(
                        SUBSTRING(
                            Notes, 
                            CHARINDEX('period', Notes) + 7, 
                            10
                        ) AS DATE
                    )
                ELSE NULL
            END AS AccrualPeriodDate,
            CASE WHEN BankId IS NULL THEN 1 ELSE 0 END
        FROM OPENJSON(@Json)
        WITH (
            BankId INT '$.bankId',
            UserId INT '$.userId',
            AccrualProfileId INT '$.accrualProfileId',
            AccrualRulesSlotId INT '$.accrualRulesSlotId',
            OldBalance DECIMAL(10, 2) '$.oldBalance',
            NewBalance DECIMAL(10, 2) '$.newBalance',
            Operator VARCHAR(1) '$.operator',
            AdjustmentAmount DECIMAL(10, 2) '$.adjustmentAmount',
            Notes NVARCHAR(MAX) '$.notes'
        );

        -- Filter valid transactions
        DECLARE @ValidTransactions TABLE (
            BankId INT,
            UserId INT,
            AccrualProfileId INT,
            AccrualRulesSlotId INT,
            AccrualPeriodDate DATE,
            AdjustmentAmount DECIMAL(10, 2),
            OldBalance DECIMAL(10, 2),
            NewBalance DECIMAL(10, 2),
            Notes NVARCHAR(MAX) NULL
        );

        INSERT INTO @ValidTransactions (BankId, UserId, AccrualProfileId, AccrualRulesSlotId, AccrualPeriodDate, AdjustmentAmount, OldBalance, NewBalance, Notes)
        SELECT BankId, UserId, AccrualProfileId, AccrualRulesSlotId, AccrualPeriodDate, AdjustmentAmount, OldBalance, NewBalance, Notes
        FROM @Transactions
        WHERE HasError = 0 AND BankId IS NOT NULL AND AccrualPeriodDate IS NOT NULL;

        -- Insert into AccrualTransactions table with AccrualPeriodDate
        -- Note: SourceTypeID and SourceID should be set based on business logic
        -- For accrual transactions, using AccrualRulesSlotId as SourceID and appropriate SourceTypeID
        -- CustomTableTransactionTypeId should be set based on transaction type mapping
        INSERT INTO [dbo].[AccrualTransactions] (
            TenantId,
            AccrualBankId,
            SourceTypeID,
            SourceID,
            CustomTableTransactionTypeId,
            Amount,
            BalanceAfter,
            Description,
            ProcessedDate,
            ProcessedBy,
            AccrualPeriodDate
        )
        SELECT 
            @TenantId,
            vt.BankId,
            2, -- SourceTypeID: 2 = Accrual (adjust based on your business logic)
            vt.AccrualRulesSlotId, -- SourceID: AccrualRulesSlotId
            2, -- CustomTableTransactionTypeId: 2 = Accrual (adjust based on your CustomTable values)
            vt.AdjustmentAmount,
            vt.NewBalance,
            ISNULL(vt.Notes, 'Accrual transaction for period: ' + CAST(vt.AccrualPeriodDate AS VARCHAR(20))),
            GETUTCDATE(),
            @CreatedBy,
            vt.AccrualPeriodDate
        FROM @ValidTransactions vt;

        COMMIT TRANSACTION;

        -- Return results
        SELECT 
            t.Id AS transactionId,
            t.AccrualBankId AS accrualBankId,
            t.SourceTypeID AS sourceTypeID,
            t.SourceID AS sourceID,
            t.Amount AS amount,
            t.BalanceAfter AS balanceAfter,
            t.Description AS description,
            t.ProcessedDate AS processedDate,
            t.AccrualPeriodDate AS accrualPeriodDate,
            'true' AS success,
            'Transaction logged successfully' AS message
        FROM [dbo].[AccrualTransactions] t
        INNER JOIN @ValidTransactions vt ON t.AccrualBankId = vt.BankId
            AND t.AccrualPeriodDate = vt.AccrualPeriodDate
            AND t.ProcessedDate >= DATEADD(SECOND, -5, GETUTCDATE())
        WHERE t.TenantId = @TenantId
        ORDER BY t.Id
        FOR JSON PATH, INCLUDE_NULL_VALUES;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            'false' AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

