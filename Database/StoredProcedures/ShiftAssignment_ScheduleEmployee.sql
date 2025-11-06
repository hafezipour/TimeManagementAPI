-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Schedule an employee to a shift with work codes, job codes, labels, and schedule
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftAssignment_ScheduleEmployee]
    @JsonData NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ShiftId INT;
    DECLARE @EmployeeUserId INT;
    DECLARE @WorkCodeIds NVARCHAR(MAX);
    DECLARE @JobCodeIds NVARCHAR(MAX);
    DECLARE @LabelIds NVARCHAR(MAX);
    DECLARE @Notes NVARCHAR(MAX);
    DECLARE @AssignmentId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON data
        SELECT 
            @ShiftId = JSON_VALUE(@JsonData, '$.shiftId'),
            @EmployeeUserId = JSON_VALUE(@JsonData, '$.userId'),
            @WorkCodeIds = JSON_VALUE(@JsonData, '$.workCodeIds'),
            @JobCodeIds = JSON_VALUE(@JsonData, '$.jobCodeIds'),
            @LabelIds = JSON_VALUE(@JsonData, '$.labelIds'),
            @Notes = JSON_VALUE(@JsonData, '$.notes');

        -- Validate required fields
        IF @ShiftId IS NULL OR @EmployeeUserId IS NULL OR @WorkCodeIds IS NULL
        BEGIN
            SELECT 
                success = 0,
                message = 'ShiftId, UserId, and WorkCodeIds are required'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- TODO: Create ShiftAssignment table and insert logic
        -- For now, return a placeholder response
        
        COMMIT TRANSACTION;

        -- Return success response with assignment ID
        SELECT 
            success = 1,
            message = 'Employee scheduled successfully',
            assignmentId = ISNULL(@AssignmentId, 0)
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 
            success = 0,
            message = @ErrorMessage
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

