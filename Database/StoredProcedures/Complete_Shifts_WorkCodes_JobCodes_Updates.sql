-- =============================================
-- Complete Update Script for Shifts with WorkCodes and JobCodes
-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Complete script containing all changes to add workCodes and jobCodes
--              to shift data across the system
-- 
-- This script includes:
-- 1. ALTER FUNCTION fn_GetShiftData - Base function that returns shift data with workCodes and jobCodes
-- 2. ALTER PROCEDURE usp_Shifts_Get - Paginated shift list with new arrays
-- 3. ALTER PROCEDURE usp_Shifts_GetSchedulingShifts - Scheduling shifts with new arrays
-- =============================================

USE [TimeManagement_DEV]
GO

-- =============================================
-- 1. UPDATE FUNCTION: fn_GetShiftData
-- =============================================
-- Add workCodes and jobCodes subqueries to return arrays of assigned codes
-- =============================================

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
        -- ShiftGroupAssignments subquery (existing)
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

PRINT '✓ fn_GetShiftData updated successfully'
GO

-- =============================================
-- 2. UPDATE PROCEDURE: usp_Shifts_Get
-- =============================================
-- Add shiftGroupAssignments, workCodes, and jobCodes to SELECT statement
-- =============================================

ALTER PROCEDURE [dbo].[usp_Shifts_Get]
	@ShiftId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'DisplayOrder',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL,
	@StatusCustomTableValueId int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	IF(@StatusCustomTableValueId IS NULL)
	BEGIN
		SET @StatusCustomTableValueId = 1;
	END

	;WITH _rows AS (
		SELECT *
		FROM [dbo].[fn_GetShiftData](@TenantId)
		WHERE (@ShiftId IS NULL OR id = @ShiftId)
			AND (
				@SearchTerm IS NULL OR 
				shiftName LIKE '%' + @SearchTerm + '%' OR 
				shiftCode LIKE '%' + @SearchTerm + '%' OR
				location LIKE '%' + @SearchTerm + '%'
			)
			AND statusCustomTableValueId = @StatusCustomTableValueId
	)
	SELECT 
		_rows.id,
		_rows.shiftName,
		_rows.shiftCode,
		_rows.minimumPositions,
		_rows.maxTimeOffs,
		_rows.location,
		_rows.isWorkShift,
		_rows.isSelfSchedulingEnabled,
		_rows.isSelfSchedulingRequiresAdminApprovals,
		_rows.isHideOpenSlots,
		_rows.shiftLabelId,
		_rows.backgroundColour,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		_rows.displayOrder,
		(SELECT count(_rows.id) from _rows) as totalCount,
		_rows.scheduleWithoutTimes,
		_rows.scheduleStartFrom,
		_rows.scheduleStartTime,
		_rows.scheduleType,
		-- *** NEW: Added these three columns ***
		_rows.shiftGroupAssignments,
		_rows.workCodes,
		_rows.jobCodes
		-- *** END NEW ***
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'ShiftName' AND @SortDirection = 'ASC' THEN _rows.shiftName END ASC,
		CASE WHEN @SortColumn = 'ShiftName' AND @SortDirection = 'DESC' THEN _rows.shiftName END DESC,
		CASE WHEN @SortColumn = 'ShiftCode' AND @SortDirection = 'ASC' THEN _rows.shiftCode END ASC,
		CASE WHEN @SortColumn = 'ShiftCode' AND @SortDirection = 'DESC' THEN _rows.shiftCode END DESC,
		CASE WHEN @SortColumn = 'Location' AND @SortDirection = 'ASC' THEN _rows.location END ASC,
		CASE WHEN @SortColumn = 'Location' AND @SortDirection = 'DESC' THEN _rows.location END DESC,
		CASE WHEN @SortColumn = 'DisplayOrder' AND @SortDirection = 'ASC' THEN _rows.displayOrder END ASC,
		CASE WHEN @SortColumn = 'DisplayOrder' AND @SortDirection = 'DESC' THEN _rows.displayOrder END DESC,
		_rows.displayOrder ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

PRINT '✓ usp_Shifts_Get updated successfully'
GO

-- =============================================
-- 3. UPDATE PROCEDURE: usp_Shifts_GetSchedulingShifts
-- =============================================
-- Add a. prefix to shiftGroupAssignments and add workCodes, jobCodes
-- =============================================

ALTER PROCEDURE [dbo].[usp_Shifts_GetSchedulingShifts]
(
    @TenantId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT distinct
        a.id,
        a.shiftName,
        a.shiftCode,
        a.minimumPositions,
        a.maxTimeOffs,
        a.location,
        a.isWorkShift,
        a.isSelfSchedulingEnabled,
        a.isSelfSchedulingRequiresAdminApprovals,
        a.isHideOpenSlots,
        a.shiftLabelId,
        a.labelName,
        a.labelCode,
        a.colorCode,
        a.backgroundColour,
        a.isActive,
        a.createdBy,
        a.updatedBy,
        a.dateCreated,
        a.dateUpdated,
        a.displayOrder,
        a.statusCustomTableValueId,
        -- *** UPDATED: Added a. prefix and new columns ***
        a.shiftGroupAssignments,
        a.workCodes,
        a.jobCodes
        -- *** END NEW ***
    FROM dbo.fn_GetShiftData(@TenantId) a
    for json path, include_null_values
END
GO

PRINT '✓ usp_Shifts_GetSchedulingShifts updated successfully'
GO

-- =============================================
-- SUMMARY OF CHANGES
-- =============================================
PRINT ''
PRINT '========================================='
PRINT 'All updates completed successfully!'
PRINT '========================================='
PRINT ''
PRINT 'Updated Objects:'
PRINT '  1. fn_GetShiftData - Added workCodes and jobCodes subqueries'
PRINT '  2. usp_Shifts_Get - Added shiftGroupAssignments, workCodes, jobCodes to SELECT'
PRINT '  3. usp_Shifts_GetSchedulingShifts - Added a. prefix and workCodes, jobCodes to SELECT'
PRINT ''
PRINT 'Impact:'
PRINT '  - All shift queries now return workCodes array from ShiftWorkCodeAssignment'
PRINT '  - All shift queries now return jobCodes array from ShiftJobCodeAssignment'
PRINT '  - Enables validation of employee work/job codes against shift requirements'
PRINT ''
PRINT 'JSON Structure Added:'
PRINT '  workCodes: [{ id, workCodeName, workCode, colorCode, isActive }]'
PRINT '  jobCodes: [{ id, jobTitle, jobCode, isActive }]'
PRINT ''
PRINT '========================================='
GO

