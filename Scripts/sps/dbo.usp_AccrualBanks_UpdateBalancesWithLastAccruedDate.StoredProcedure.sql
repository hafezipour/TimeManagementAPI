USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_UpdateBalancesWithLastAccruedDate]    Script Date: 11/27/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Auto Generated
-- Create date: 11/27/2025
-- Description: Update AccrualBanks balances and LastAccruedPeriodDate in bulk
--              Takes JSON array with bankId, userId, accrualProfileId, accrualRulesSlotId,
--              currentBalance, operator, adjustmentAmount, notes
--              Extracts LastAccruedPeriodDate from notes field (format: "Accrual update - Last accrued: YYYY-MM-DD")
--              Updates both CurrentBalance and LastAccruedPeriodDate in AccrualBanks table
--              Returns array with updated bank records
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_UpdateBalancesWithLastAccruedDate]
    @Json NVARCHAR(MAX),
    @UpdatedBy INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON input (matching the provided format)
        DECLARE @Adjustments TABLE (
            TempId INT IDENTITY(1,1),
            BankId INT,
            UserId INT,
            AccrualProfileId INT,
            AccrualRulesSlotId INT,
            CurrentBalance DECIMAL(10, 2),
            Operator VARCHAR(1),
            AdjustmentAmount DECIMAL(10, 2),
            Notes NVARCHAR(MAX) NULL,
            LastAccruedPeriodDate DATE,
            NewBalance DECIMAL(10, 2) NULL,
            HasError BIT DEFAULT 0,
            ErrorMessage NVARCHAR(MAX) NULL
        );

        -- Insert parsed JSON data and extract LastAccruedPeriodDate from notes
        INSERT INTO @Adjustments (BankId, UserId, AccrualProfileId, AccrualRulesSlotId, CurrentBalance, Operator, AdjustmentAmount, Notes, LastAccruedPeriodDate, HasError)
        SELECT 
            BankId,
            UserId,
            AccrualProfileId,
            AccrualRulesSlotId,
            CurrentBalance,
            Operator,
            AdjustmentAmount,
            Notes,
            -- Extract date from notes: "Accrual update - Last accrued: YYYY-MM-DD" format
            CASE 
                WHEN Notes IS NOT NULL AND Notes LIKE '%Last accrued:%' THEN
                    TRY_CAST(
                        SUBSTRING(
                            Notes, 
                            CHARINDEX('Last accrued:', Notes) + 14, 
                            10
                        ) AS DATE
                    )
                ELSE NULL
            END AS LastAccruedPeriodDate,
            CASE WHEN BankId IS NULL THEN 1 ELSE 0 END
        FROM OPENJSON(@Json)
        WITH (
            BankId INT '$.bankId',
            UserId INT '$.userId',
            AccrualProfileId INT '$.accrualProfileId',
            AccrualRulesSlotId INT '$.accrualRulesSlotId',
            CurrentBalance DECIMAL(10, 2) '$.currentBalance',
            Operator VARCHAR(1) '$.operator',
            AdjustmentAmount DECIMAL(10, 2) '$.adjustmentAmount',
            Notes NVARCHAR(MAX) '$.notes'
        );

        -- Validate and calculate new balances
        UPDATE @Adjustments
        SET 
            NewBalance = CASE 
                WHEN Operator = '+' THEN CurrentBalance + AdjustmentAmount
                WHEN Operator = '-' THEN CurrentBalance - AdjustmentAmount
                ELSE CurrentBalance
            END,
            HasError = CASE 
                WHEN Operator NOT IN ('+', '-') THEN 1
                WHEN AdjustmentAmount <= 0 THEN 1
                WHEN BankId IS NULL THEN 1
                ELSE 0
            END,
            ErrorMessage = CASE 
                WHEN Operator NOT IN ('+', '-') THEN 'Invalid operator'
                WHEN AdjustmentAmount <= 0 THEN 'Adjustment amount must be greater than 0'
                WHEN BankId IS NULL THEN 'Bank ID is required'
                ELSE NULL
            END;

        -- Filter valid adjustments
        DECLARE @ValidAdjustments TABLE (
            BankId INT,
            NewBalance DECIMAL(10, 2),
            LastAccruedPeriodDate DATE,
            Notes NVARCHAR(MAX) NULL
        );

        INSERT INTO @ValidAdjustments (BankId, NewBalance, LastAccruedPeriodDate, Notes)
        SELECT BankId, NewBalance, LastAccruedPeriodDate, Notes
        FROM @Adjustments
        WHERE HasError = 0 AND BankId IS NOT NULL;

        -- Update AccrualBanks in bulk (both CurrentBalance and LastAccruedPeriodDate)
        UPDATE ab
        SET ab.CurrentBalance = va.NewBalance,
            ab.LastAccruedPeriodDate = va.LastAccruedPeriodDate,
            ab.DateUpdated = GETUTCDATE(),
            ab.UpdatedBy = @UpdatedBy
        FROM [dbo].[AccrualBanks] ab
        INNER JOIN @ValidAdjustments va ON ab.Id = va.BankId
        WHERE ab.TenantId = @TenantId;

        COMMIT TRANSACTION;

        -- Return results with updated balances
        SELECT 
            a.BankId AS bankId,
            a.UserId AS userId,
            a.AccrualProfileId AS accrualProfileId,
            a.AccrualRulesSlotId AS accrualRulesSlotId,
            a.CurrentBalance AS oldBalance,
            a.NewBalance AS newBalance,
            a.Operator AS operator,
            a.AdjustmentAmount AS adjustmentAmount,
            a.Notes AS notes,
            a.LastAccruedPeriodDate AS lastAccruedPeriodDate,
            a.ErrorMessage AS errorMessage,
            CASE WHEN a.HasError = 0 THEN 'true' ELSE 'false' END AS success
        FROM @Adjustments a
        ORDER BY a.TempId
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

