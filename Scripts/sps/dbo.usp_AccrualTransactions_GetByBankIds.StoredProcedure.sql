USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTransactions_GetByBankIds]    Script Date: 11/27/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Auto Generated
-- Create date: 11/27/2025
-- Description: Get accrual transactions by bank IDs in bulk
--              Takes JSON array of bank IDs and tenant ID
--              Returns transactions for all specified banks
--              Used for checking existing transactions during accrual evaluation
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualTransactions_GetByBankIds]
    @BankIdsJson NVARCHAR(MAX),
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Parse JSON array of bank IDs
        DECLARE @BankIds TABLE (AccrualBankId INT);
        
        IF @BankIdsJson IS NOT NULL AND LEN(@BankIdsJson) > 0
        BEGIN
            INSERT INTO @BankIds (AccrualBankId)
            SELECT value AS AccrualBankId
            FROM OPENJSON(@BankIdsJson)
            WHERE value IS NOT NULL;
        END

        -- Return transactions for the specified banks
        SELECT 
            at.AccrualBankId AS accrualBankId,
            at.Amount AS amount,
            at.BalanceAfter AS balanceAfter,
            at.AccrualPeriodDate AS accrualPeriodDate,
            at.ProcessedDate AS processedDate
        FROM [dbo].[AccrualTransactions] at
        INNER JOIN @BankIds bi ON at.AccrualBankId = bi.AccrualBankId
        WHERE at.TenantId = @TenantId
        ORDER BY at.AccrualBankId, at.AccrualPeriodDate, at.ProcessedDate
        FOR JSON PATH, INCLUDE_NULL_VALUES;

    END TRY
    BEGIN CATCH
        SELECT 
            'false' AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

