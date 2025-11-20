USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_LogTransactions]    Script Date: 11/19/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/19/2025
-- Description: Log accrual transactions in bulk
--              Takes JSON array from UpdateBalances results
--              Inserts records into AccrualTransactions table
--              Returns array of inserted transaction records
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_LogTransactions]
    @Json NVARCHAR(MAX),
    @CreatedBy INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON input (from UpdateBalances results)
        DECLARE @Transactions TABLE (
            TempId INT IDENTITY(1,1),
            BankId INT,
            AccrualRuleId INT,
            OldBalance DECIMAL(10, 2),
            NewBalance DECIMAL(10, 2),
            Operator VARCHAR(1),
            AdjustmentAmount DECIMAL(10, 2),
            Notes NVARCHAR(MAX) NULL,
            HasError BIT DEFAULT 0
        );

        -- Insert parsed JSON data
        INSERT INTO @Transactions (BankId, AccrualRuleId, OldBalance, NewBalance, Operator, AdjustmentAmount, Notes, HasError)
        SELECT 
            BankId,
            NULL, -- Will be populated from AccrualBanks table
            OldBalance,
            NewBalance,
            Operator,
            AdjustmentAmount,
            Notes,
            CASE WHEN Success = 'false' OR Success = 0 OR BankId IS NULL THEN 1 ELSE 0 END
        FROM OPENJSON(@Json)
        WITH (
            BankId INT '$.bankId',
            OldBalance DECIMAL(10, 2) '$.oldBalance',
            NewBalance DECIMAL(10, 2) '$.newBalance',
            Operator VARCHAR(1) '$.operator',
            AdjustmentAmount DECIMAL(10, 2) '$.adjustmentAmount',
            Notes NVARCHAR(MAX) '$.notes',
            Success VARCHAR(10) '$.success'
        );

        -- Get AccrualRuleId from AccrualBanks table
        UPDATE t
        SET t.AccrualRuleId = ab.AccrualRuleId
        FROM @Transactions t
        INNER JOIN [dbo].[AccrualBanks] ab ON t.BankId = ab.Id
        WHERE ab.TenantId = @TenantId;

        -- Filter valid transactions (only log successful updates)
        DECLARE @ValidTransactions TABLE (
            BankId INT,
            AccrualRuleId INT,
            OldBalance DECIMAL(10, 2),
            NewBalance DECIMAL(10, 2),
            Operator VARCHAR(1),
            AdjustmentAmount DECIMAL(10, 2),
            Notes NVARCHAR(MAX) NULL
        );

        INSERT INTO @ValidTransactions (BankId, AccrualRuleId, OldBalance, NewBalance, Operator, AdjustmentAmount, Notes)
        SELECT BankId, AccrualRuleId, OldBalance, NewBalance, Operator, AdjustmentAmount, Notes
        FROM @Transactions
        WHERE HasError = 0 AND BankId IS NOT NULL;

        -- Insert into AccrualTransactions table
        -- Note: SourceTypeID and SourceID should be set based on business logic
        -- For now, using BankId as SourceID and 1 as SourceTypeID (adjustment)
        -- CustomTableTransactionTypeId should be set based on transaction type mapping
        INSERT INTO [dbo].[AccrualTransactions] (
            TenantId,
            AccrualRuleId,
            SourceTypeID,
            SourceID,
            CustomTableTransactionTypeId,
            Amount,
            BalanceAfter,
            Description,
            ProcessedDate,
            Processedby
        )
        SELECT 
            @TenantId,
            vt.AccrualRuleId,
            1, -- SourceTypeID: 1 = Manual Adjustment (adjust based on your business logic)
            vt.BankId, -- SourceID: BankId
            1, -- CustomTableTransactionTypeId: 1 = Adjustment (adjust based on your CustomTable values)
            vt.AdjustmentAmount,
            vt.NewBalance,
            CASE 
                WHEN vt.Operator = '+' THEN 'Balance added: ' + CAST(vt.AdjustmentAmount AS VARCHAR(20))
                ELSE 'Balance subtracted: ' + CAST(vt.AdjustmentAmount AS VARCHAR(20))
            END + ISNULL(' - ' + vt.Notes, ''),
            GETUTCDATE(),
            @CreatedBy
        FROM @ValidTransactions vt;

        COMMIT TRANSACTION;

        -- Return results
        SELECT 
            t.Id AS transactionId,
            t.AccrualRuleId AS accrualRuleId,
            t.SourceTypeID AS sourceTypeID,
            t.SourceID AS sourceID,
            t.Amount AS amount,
            t.BalanceAfter AS balanceAfter,
            t.Description AS description,
            t.ProcessedDate AS processedDate,
            'true' AS success,
            'Transaction logged successfully' AS message
        FROM [dbo].[AccrualTransactions] t
        INNER JOIN @ValidTransactions vt ON t.SourceID = vt.BankId
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

