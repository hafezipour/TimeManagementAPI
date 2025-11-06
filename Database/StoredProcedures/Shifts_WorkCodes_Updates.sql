-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Update fn_GetShiftData to include workCodes from ShiftWorkCodeAssignment
-- =============================================

-- This script updates the fn_GetShiftData function to return workCodes
-- along with shift data for SchedulingShift objects

ALTER FUNCTION [dbo].[fn_GetShiftData]
(
    @TenantId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.Id as id,
        s.ShiftName as shiftName,
        s.ShiftCode as shiftCode,
        s.MinimumPositions as minimumPositions,
        s.MaxTimeOffs as maxTimeOffs,
        s.Location as location,
        s.IsWorkShift as isWorkShift,
        s.IsSelfSchedulingEnabled as isSelfSchedulingEnabled,
        s.IsSelfSchedulingRequiresAdminApprovals as isSelfSchedulingRequiresAdminApprovals,
        s.IsHideOpenSlots as isHideOpenSlots,
        s.ShiftLabelId as shiftLabelId,
        l.labelName,
        l.labelCode,
        l.colorCode,
        s.BackgroundColour as backgroundColour,
        s.IsActive as isActive,
        s.CreatedBy as createdBy,
        s.UpdatedBy as updatedBy,
        s.DateCreated as dateCreated,
        s.DateUpdated as dateUpdated,
        s.DisplayOrder as displayOrder,
        s.StatusCustomTableValueId as statusCustomTableValueId,
        ss.id as scheduleId,
        ss.scheduleWithoutTimes,
        ss.startFrom as scheduleStartFrom,
        ss.startTime as scheduleStartTime,
        ss.scheduleType,
        (
            select 
                a.id,
                a.shiftId,
                a.groupId,
                g.groupName,
                g.colorCode
            from ShiftGroupAssignment a
            inner join Groups g on g.Id = a.groupId and g.isActive = 1
            where 
                    a.ShiftId = s.Id 
                and a.TenantId = @TenantId
            for json path, include_null_values
        ) as shiftGroupAssignments,
        -- *** NEW: WorkCodes subquery ***
        (
            select 
                wc.Id as id,
                wc.WorkCodeName as workCodeName,
                wc.WorkCode as workCode,
                wc.ColorCode as colorCode,
                wc.IsActive as isActive
            from ShiftWorkCodeAssignment swca
            inner join WorkCodes wc on wc.Id = swca.WorkCodeId and wc.IsActive = 1
            where 
                    swca.ShiftId = s.Id 
                and swca.TenantId = @TenantId
            for json path, include_null_values
        ) as workCodes,
        -- *** NEW: JobCodes subquery ***
        (
            select 
                jc.Id as id,
                jc.JobTitle as jobTitle,
                jc.JobCode as jobCode,
                jc.IsActive as isActive
            from ShiftJobCodeAssignment sjca
            inner join JobCodes jc on jc.Id = sjca.JobCodeId and jc.IsActive = 1
            where 
                    sjca.ShiftId = s.Id 
                and sjca.TenantId = @TenantId
            for json path, include_null_values
        ) as jobCodes
        -- *** END NEW ***
    FROM Shifts s
    Left Join Labels l on l.id = s.ShiftLabelId
    LEFT JOIN Schedules ss on ss.SourceId = s.Id and ss.SourceType = 1
    WHERE s.TenantId = @TenantId
)
GO

-- =============================================
-- NOTES:
-- =============================================
-- This change affects the following stored procedures that use fn_GetShiftData:
-- 1. usp_Shifts_Get (Updated to include shiftGroupAssignments, workCodes, jobCodes)
-- 2. usp_Shifts_GetSchedulingShifts (Already returns all columns via fn_GetShiftData)
-- 3. Any other SPs that call fn_GetShiftData
--
-- The workCodes array will be returned as JSON for each shift, containing:
-- - id: WorkCode ID
-- - workCodeName: Name of the work code
-- - workCode: Work code identifier
-- - colorCode: Color for UI display
-- - isActive: Whether the work code is active
-- Data comes from ShiftWorkCodeAssignment junction table
--
-- The jobCodes array will be returned as JSON for each shift, containing:
-- - id: JobCode ID
-- - jobTitle: Title/Name of the job code
-- - jobCode: Job code identifier
-- - isActive: Whether the job code is active
-- Data comes from ShiftJobCodeAssignment junction table
--
-- UPDATED STORED PROCEDURES:
-- 1. fn_GetShiftData: Added workCodes and jobCodes subqueries
-- 2. usp_Shifts_Get: Added shiftGroupAssignments, workCodes, jobCodes to SELECT
-- 3. usp_Shifts_GetSchedulingShifts: Added a. prefix and workCodes, jobCodes to SELECT
-- =============================================

-- =============================================
-- ADDITIONAL UPDATE: usp_Shifts_Get
-- =============================================
-- The usp_Shifts_Get stored procedure needed explicit column additions
-- because it selects specific columns from fn_GetShiftData result.
--
-- Changes made to usp_Shifts_Get SELECT statement:
-- Added the following three columns after _rows.scheduleType:
--   _rows.shiftGroupAssignments,
--   _rows.workCodes,
--   _rows.jobCodes
--
-- These columns were already being returned by fn_GetShiftData but were
-- not included in the final SELECT, so they were being omitted from the
-- JSON output of usp_Shifts_Get.
--
-- After this change, usp_Shifts_Get will now return:
-- - All previous shift data (id, shiftName, etc.)
-- - Schedule information (scheduleType, scheduleStartFrom, etc.)
-- - shiftGroupAssignments array (groups assigned to the shift)
-- - workCodes array (work codes assigned to the shift) [NEW]
-- - jobCodes array (job codes assigned to the shift) [NEW]
-- =============================================

-- =============================================
-- ADDITIONAL UPDATE: usp_Shifts_GetSchedulingShifts
-- =============================================
-- The usp_Shifts_GetSchedulingShifts stored procedure also needed updates
-- because it was selecting 'shiftGroupAssignments' without the 'a.' prefix
-- and wasn't including workCodes and jobCodes at all.
--
-- Changes made to usp_Shifts_GetSchedulingShifts SELECT statement:
-- Changed:
--   shiftGroupAssignments
-- To:
--   a.shiftGroupAssignments,
--   a.workCodes,
--   a.jobCodes
--
-- After this change, usp_Shifts_GetSchedulingShifts will now return:
-- - All previous shift data (id, shiftName, labels, etc.)
-- - shiftGroupAssignments array (groups assigned to the shift)
-- - workCodes array (work codes assigned to the shift) [NEW]
-- - jobCodes array (job codes assigned to the shift) [NEW]
-- =============================================

