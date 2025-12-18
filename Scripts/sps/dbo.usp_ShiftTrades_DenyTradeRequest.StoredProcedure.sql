USE [StaffScheduling_DEV]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      System
-- Create date: 2025-12-19
-- Description: Deny a shift trade request (set StatusCustomTableValueId to 3) and delete associated shift assignments
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftTrades_DenyTradeRequest]
    @TradeRequestId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate that the trade request exists and belongs to the tenant
        IF NOT EXISTS (SELECT 1 FROM [dbo].[ShiftTrades] WHERE Id = @TradeRequestId AND TenantId = @TenantId)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Trade request not found or does not belong to this tenant.'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Delete associated shift assignments where TradeRequestId matches
        DELETE FROM [dbo].[ShiftAssignment]
        WHERE TradeRequestId = @TradeRequestId
            AND TenantId = @TenantId;

        -- Update the trade request status to Denied (3)
        UPDATE [dbo].[ShiftTrades]
        SET StatusCustomTableValueId = 3,
            DateUpdated = SYSDATETIMEOFFSET()
        WHERE Id = @TradeRequestId
            AND TenantId = @TenantId;

        COMMIT TRANSACTION;

        -- Return success response
        SELECT 
            success = CAST(1 AS BIT),
            message = 'Trade request denied successfully'
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        SELECT 
            success = CAST(0 AS BIT),
            message = @ErrorMessage
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

