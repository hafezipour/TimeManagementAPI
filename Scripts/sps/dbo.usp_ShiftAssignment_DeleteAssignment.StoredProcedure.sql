USE [StaffScheduling_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftAssignment_DeleteAssignment]    Script Date: 12/24/2025 2:44:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      System
-- Create date: 2025-12-24
-- Description: End a shift assignment (update ToDate) instead of deleting
--              Checks for trades and prevents ending before trade date
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftAssignment_DeleteAssignment]
    @AssignmentId INT,
    @DeleteDate DATE,
    @DeleteTime TIME(7) = NULL,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate that the assignment exists and belongs to the tenant
        IF NOT EXISTS (SELECT 1 FROM [dbo].[ShiftAssignment] WHERE Id = @AssignmentId AND TenantId = @TenantId)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Assignment not found or does not belong to this tenant.'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check directly from ShiftTrades table if TradingDate or AcceptingDate > deletion date
        -- If found, block deletion
        IF EXISTS (
            SELECT 1 
            FROM [dbo].[ShiftTrades]
            WHERE (FromAssignmentId = @AssignmentId OR ToAssignmentId = @AssignmentId)
                AND TenantId = @TenantId
                AND (TradingDate > @DeleteDate OR AcceptingDate > @DeleteDate)
        )
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Assignment cannot be ended. A trade is present with a date greater than the selected date.'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Get the assignment's schedule to update ToDate
        DECLARE @ScheduleId INT;
        SELECT @ScheduleId = ScheduleId 
        FROM [dbo].[ShiftAssignment] 
        WHERE Id = @AssignmentId AND TenantId = @TenantId;

        -- Update the assignment's ToDate by updating the schedule's ValidUntil
        IF @ScheduleId IS NOT NULL
        BEGIN
            DECLARE @EndDateTime DATETIMEOFFSET;
            
            -- Combine date and time if time is provided
            IF @DeleteTime IS NOT NULL
            BEGIN
                SET @EndDateTime = CAST(@DeleteDate AS DATETIMEOFFSET) + CAST(@DeleteTime AS TIME);
            END
            ELSE
            BEGIN
                -- If no time provided, set to end of day
                SET @EndDateTime = CAST(@DeleteDate AS DATETIMEOFFSET) + CAST('23:59:59' AS TIME);
            END

            -- Update the schedule's ValidUntil to end the assignment
            UPDATE [dbo].[Schedules]
            SET ValidUntil = @EndDateTime,
                DateUpdated = SYSUTCDATETIME(),
                UpdatedBy = @UserId
            WHERE Id = @ScheduleId
                AND TenantId = @TenantId;
        END

        COMMIT TRANSACTION;

        -- Return success response
        SELECT 
            success = CAST(1 AS BIT),
            message = 'Assignment ended successfully',
            assignmentId = @AssignmentId,
            endDate = @DeleteDate
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

