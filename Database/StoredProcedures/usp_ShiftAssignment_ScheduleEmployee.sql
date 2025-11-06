-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Schedule an employee to a shift with work codes, job codes, and labels
--              Supports both INSERT (new assignment) and UPDATE (existing assignment)
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
    DECLARE @ExistingAssignmentId INT;
    DECLARE @IsUpdate BIT = 0;
    DECLARE @CurrentDateTime DATETIMEOFFSET = SYSDATETIMEOFFSET();

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON data
        SELECT 
            @ExistingAssignmentId = JSON_VALUE(@JsonData, '$.id'),
            @ShiftId = JSON_VALUE(@JsonData, '$.shiftId'),
            @EmployeeUserId = JSON_VALUE(@JsonData, '$.userId'),
            @WorkCodeIds = JSON_VALUE(@JsonData, '$.workCodeIds'),
            @JobCodeIds = JSON_VALUE(@JsonData, '$.jobCodeIds'),
            @LabelIds = JSON_VALUE(@JsonData, '$.labelIds'),
            @Notes = JSON_VALUE(@JsonData, '$.notes');

        -- Validate required fields
        IF @ShiftId IS NULL OR @EmployeeUserId IS NULL
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'ShiftId and UserId are required',
                id = NULL,
                shiftId = NULL,
                userId = NULL,
                notes = NULL,
                assignedAt = NULL,
                assignedBy = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate Shift exists
        IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Shift not found',
                id = NULL,
                shiftId = NULL,
                userId = NULL,
                notes = NULL,
                assignedAt = NULL,
                assignedBy = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if this is an update (assignment ID provided)
        IF @ExistingAssignmentId IS NOT NULL
        BEGIN
            -- Validate assignment exists
            IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE Id = @ExistingAssignmentId AND TenantId = @TenantId)
            BEGIN
                SELECT 
                    success = CAST(0 AS BIT),
                    message = 'Shift assignment not found',
                    id = NULL,
                    shiftId = NULL,
                    userId = NULL,
                    notes = NULL,
                    assignedAt = NULL,
                    assignedBy = NULL
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                
                ROLLBACK TRANSACTION;
                RETURN;
            END

            SET @IsUpdate = 1;
            SET @AssignmentId = @ExistingAssignmentId;

            -- Delete existing junction table records
            DELETE FROM EmployeeShiftAssignmentWorkCodes 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            DELETE FROM EmployeeShiftAssignmentJobCodes 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            DELETE FROM EmployeeShiftAssignmentLabels 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            -- Update ShiftAssignment table
            UPDATE ShiftAssignment
            SET 
                ShiftId = @ShiftId,
                UserId = @EmployeeUserId,
                Notes = @Notes,
                UpdatedBy = @UserId,
                DateUpdated = @CurrentDateTime
            WHERE Id = @AssignmentId AND TenantId = @TenantId;
        END
        ELSE
        BEGIN
            -- Insert new ShiftAssignment
            INSERT INTO ShiftAssignment (
                TenantId,
                ShiftId,
                UserId,
                StatusCustomTableValueId,
                Notes,
                AssignedAt,
                Assignedby,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @ShiftId,
                @EmployeeUserId,
                1, -- Active status
                @Notes,
                @CurrentDateTime,
                @UserId,
                @UserId,
                @CurrentDateTime
            );

            SET @AssignmentId = SCOPE_IDENTITY();
        END

        -- Insert Work Codes into junction table
        IF @WorkCodeIds IS NOT NULL AND LEN(@WorkCodeIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentWorkCodes (
                TenantId,
                ShiftAssignmentId,
                WorkCodeId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@WorkCodeIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        -- Insert Job Codes into junction table
        IF @JobCodeIds IS NOT NULL AND LEN(@JobCodeIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentJobCodes (
                TenantId,
                ShiftAssignmentId,
                JobCodeId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@JobCodeIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        -- Insert Labels into junction table
        IF @LabelIds IS NOT NULL AND LEN(@LabelIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentLabels (
                TenantId,
                ShiftAssignmentId,
                LabelId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@LabelIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        COMMIT TRANSACTION;

        -- Get the assignment details for response
        DECLARE @AssignedAt DATETIMEOFFSET;
        DECLARE @AssignedBy INT;
        
        SELECT 
            @AssignedAt = AssignedAt,
            @AssignedBy = Assignedby
        FROM ShiftAssignment
        WHERE Id = @AssignmentId AND TenantId = @TenantId;

        -- Return the created/updated assignment
        SELECT 
            success = CAST(1 AS BIT),
            message = CASE WHEN @IsUpdate = 1 THEN 'Employee shift assignment updated successfully' ELSE 'Employee scheduled successfully' END,
            id = @AssignmentId,
            shiftId = @ShiftId,
            userId = @EmployeeUserId,
            notes = @Notes,
            assignedAt = @AssignedAt,
            assignedBy = @AssignedBy
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        SELECT 
            success = CAST(0 AS BIT),
            message = @ErrorMessage,
            id = NULL,
            shiftId = NULL,
            userId = NULL,
            notes = NULL,
            assignedAt = NULL,
            assignedBy = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO
