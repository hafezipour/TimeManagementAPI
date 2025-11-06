-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Get shift assignments by userIds or shiftIds
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftAssignment_Get]
    @UserIds NVARCHAR(MAX) = NULL,
    @ShiftIds NVARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Get all shift assignments matching the criteria
        SELECT 
            sa.Id as id,
            sa.ShiftId as shiftId,
            sa.UserId as userId,
            sa.StatusCustomTableValueId as statusCustomTableValueId,
            sa.Notes as notes,
            sa.AssignedAt as assignedAt,
            sa.Assignedby as assignedBy,
            sa.StartTime as startTime,
            sa.EndTime as endTime,
            sa.ScheduleId as scheduleId,
            sa.CreatedBy as createdBy,
            sa.UpdatedBy as updatedBy,
            sa.DateCreated as dateCreated,
            sa.DateUpdated as dateUpdated,
            -- Shift information
            s.ShiftName as shiftName,
            s.ShiftCode as shiftCode,
            s.BackgroundColour as shiftBackgroundColour,
            -- Work Codes array
            (
                SELECT 
                    wc.Id as id,
                    wc.WorkCodeName as workCodeName,
                    wc.WorkCode as workCode,
                    wc.ColorCode as colorCode,
                    wc.IsActive as isActive
                FROM EmployeeShiftAssignmentWorkCodes eswc
                INNER JOIN WorkCodes wc ON wc.Id = eswc.WorkCodeId
                WHERE eswc.ShiftAssignmentId = sa.Id 
                    AND eswc.TenantId = @TenantId
                FOR JSON PATH
            ) as workCodes,
            -- Job Codes array
            (
                SELECT 
                    jc.Id as id,
                    jc.JobTitle as jobTitle,
                    jc.JobCode as jobCode,
                    jc.IsActive as isActive
                FROM EmployeeShiftAssignmentJobCodes esjc
                INNER JOIN JobCodes jc ON jc.Id = esjc.JobCodeId
                WHERE esjc.ShiftAssignmentId = sa.Id 
                    AND esjc.TenantId = @TenantId
                FOR JSON PATH
            ) as jobCodes,
            -- Labels array
            (
                SELECT 
                    l.Id as id,
                    l.LabelName as labelName,
                    l.LabelCode as labelCode,
                    l.ColorCode as colorCode,
                    l.IsActive as isActive
                FROM EmployeeShiftAssignmentLabels esl
                INNER JOIN Labels l ON l.Id = esl.LabelId
                WHERE esl.ShiftAssignmentId = sa.Id 
                    AND esl.TenantId = @TenantId
                FOR JSON PATH
            ) as labels
        FROM ShiftAssignment sa
        INNER JOIN Shifts s ON s.Id = sa.ShiftId
        WHERE sa.TenantId = @TenantId
            AND (
                (@UserIds IS NULL OR sa.UserId IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@UserIds, ',')))
                OR
                (@ShiftIds IS NULL OR sa.ShiftId IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@ShiftIds, ',')))
            )
        ORDER BY sa.AssignedAt DESC, sa.DateCreated DESC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        SELECT 
            success = CAST(0 AS BIT),
            message = @ErrorMessage,
            data = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

