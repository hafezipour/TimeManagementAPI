USE [StaffScheduling_DEV]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      System
-- Create date: 2025-12-19
-- Description: Update trade-related fields on shift assignment
-- =============================================

CREATE PROCEDURE [dbo].[usp_ShiftAssignment_UpdateTradeFields]
    @AssignmentId INT,
    @IsTraded BIT = NULL,
    @TradingUserAssignmentId INT = NULL,
    @IsSwap BIT = NULL,
    @AcceptingUserAssignmentId INT = NULL,
    @TradeRequestId INT = NULL,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate shift assignment exists for tenant
        IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE Id = @AssignmentId AND TenantId = @TenantId)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Shift assignment not found.',
                assignmentId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update trade-related fields
        UPDATE ShiftAssignment
        SET 
            IsTraded = ISNULL(@IsTraded, IsTraded),
            TradingUserAssignmentId = ISNULL(@TradingUserAssignmentId, TradingUserAssignmentId),
            IsSwap = ISNULL(@IsSwap, IsSwap),
            AcceptingUserAssignmentId = ISNULL(@AcceptingUserAssignmentId, AcceptingUserAssignmentId),
            TradeRequestId = ISNULL(@TradeRequestId, TradeRequestId),
            UpdatedBy = @UserId,
            DateUpdated = SYSDATETIMEOFFSET()
        WHERE Id = @AssignmentId
          AND TenantId = @TenantId;

        COMMIT TRANSACTION;

        SELECT 
            success = CAST(1 AS BIT),
            message = 'Trade fields updated successfully.',
            assignmentId = @AssignmentId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            success = CAST(0 AS BIT),
            message = ERROR_MESSAGE(),
            assignmentId = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

