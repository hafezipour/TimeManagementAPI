USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTransactions_GetHistory]    Script Date: 11/20/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/20/2025
-- Description: Get accrual transaction history for a bank with server-side paging
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualTransactions_GetHistory]
    @AccrualBankId INT,
    @TenantId INT,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'ProcessedDate',
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        ;WITH _rows AS (
            SELECT 
                at.Id AS transactionId,
                at.ProcessedDate AS processedOn,
                at.Amount AS adjustment,
                at.Description AS details,
                at.BalanceAfter AS balanceAfter
            FROM [dbo].[AccrualTransactions] at
            WHERE at.TenantId = @TenantId
                AND at.AccrualBankId = @AccrualBankId
        )
        SELECT 
            _rows.transactionId,
            _rows.processedOn,
            _rows.adjustment,
            _rows.details,
            _rows.balanceAfter,
            (SELECT COUNT(_rows.transactionId) FROM _rows) AS totalCount
        FROM _rows
        ORDER BY 
            CASE WHEN @SortColumn = 'ProcessedDate' AND @SortDirection = 'ASC' THEN _rows.processedOn END ASC,
            CASE WHEN @SortColumn = 'ProcessedDate' AND @SortDirection = 'DESC' THEN _rows.processedOn END DESC,
            CASE WHEN @SortColumn = 'Amount' AND @SortDirection = 'ASC' THEN _rows.adjustment END ASC,
            CASE WHEN @SortColumn = 'Amount' AND @SortDirection = 'DESC' THEN _rows.adjustment END DESC,
            CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'ASC' THEN _rows.details END ASC,
            CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'DESC' THEN _rows.details END DESC,
            _rows.processedOn DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY
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

