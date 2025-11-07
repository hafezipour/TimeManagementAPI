-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-11-07
-- Description: Updates the ScheduleId for a shift assignment record
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftAssignment_UpdateScheduleId]
    @AssignmentId INT,
    @ScheduleId INT,
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
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Ensure schedule exists for tenant (optional but keeps data integrity)
        IF NOT EXISTS (SELECT 1 FROM Schedules WHERE Id = @ScheduleId AND TenantId = @TenantId)
        BEGIN
            SELECT
                success = CAST(0 AS BIT),
                message = 'Schedule not found.',
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Ensure schedule is not linked to a different assignment for this tenant
        IF EXISTS (
            SELECT 1
            FROM ShiftAssignment
            WHERE TenantId = @TenantId
              AND ScheduleId = @ScheduleId
              AND Id <> @AssignmentId
        )
        BEGIN
            SELECT
                success = CAST(0 AS BIT),
                message = 'Schedule is already linked to a different shift assignment.',
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE ShiftAssignment
        SET
            ScheduleId = @ScheduleId,
            UpdatedBy = @UserId,
            DateUpdated = SYSDATETIMEOFFSET()
        WHERE Id = @AssignmentId
          AND TenantId = @TenantId;

        COMMIT TRANSACTION;

        SELECT
            success = CAST(1 AS BIT),
            message = 'Schedule linked to shift assignment successfully.',
            assignmentId = @AssignmentId,
            scheduleId = @ScheduleId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            success = CAST(0 AS BIT),
            message = ERROR_MESSAGE(),
            assignmentId = NULL,
            scheduleId = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END

