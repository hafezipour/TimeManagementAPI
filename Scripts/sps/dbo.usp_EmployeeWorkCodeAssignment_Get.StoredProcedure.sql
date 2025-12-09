USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkCodeAssignment_Get]    Script Date: 12/8/2025 4:11:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*==================================================================================
CREATED BY             : Auto Generated
CREATED DATE           : 12/8/2025
DESCRIPTION            : Get Employee Work Code Assignment List with SERVER-SIDE PAGINATION and SORTING
LAST UPDATED BY        : Auto Generated
DATE LAST UPDATED     : 12/8/2025
CHANGE DESCRIPTION    : Initial creation

EXEC [usp_EmployeeWorkCodeAssignment_Get] 0, 0, '', 1, 1, 10, 'effectiveDate', 'desc'
==================================================================================*/

CREATE PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_Get]
(
    @WorkCodeId int,
    @UserId int,
    @SearchStr nvarchar(max),
    @TenantId int,
    @PageNumber int = 1,
    @PageSize int = 10,
    @SortColumn nvarchar(50) = 'effectiveDate',
    @SortDirection nvarchar(4) = 'desc'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle null parameters
    IF(ISNULL(@WorkCodeId, 0) = 0)
    BEGIN
        SET @WorkCodeId = 0
    END

    IF(ISNULL(@UserId, 0) = 0)
    BEGIN
        SET @UserId = 0
    END

    IF(ISNULL(@SearchStr, '') = '')
    BEGIN
        SET @SearchStr = ''
    END

    -- Default pagination values
    IF(ISNULL(@PageNumber, 0) <= 0)
    BEGIN
        SET @PageNumber = 1
    END

    IF(ISNULL(@PageSize, 0) <= 0)
    BEGIN
        SET @PageSize = 10
    END

    -- Validate and sanitize sort column to prevent SQL injection
    DECLARE @ValidSortColumn NVARCHAR(100);
    SET @ValidSortColumn = CASE LOWER(@SortColumn)
        WHEN 'workcode' THEN 'workCode'
        WHEN 'workcodename' THEN 'workCodeName'
        WHEN 'effectivedate' THEN 'effectiveDate'
        WHEN 'expirydate' THEN 'expiryDate'
        ELSE 'effectiveDate'  -- Default
    END;

    -- Validate sort direction
    DECLARE @ValidSortDirection NVARCHAR(4);
    SET @ValidSortDirection = CASE LOWER(@SortDirection)
        WHEN 'asc' THEN 'ASC'
        WHEN 'desc' THEN 'DESC'
        ELSE 'DESC'  -- Default
    END;

    ;WITH _rows AS (
        SELECT
            ewca.Id as id,
            ewca.WorkCodeId as workCodeId,
            ewca.UserId as userId,
            ewca.IsActive as isActive,
            ewca.EffectiveDate as effectiveDate,
            ewca.ExpiryDate as expiryDate,
            ewca.CreatedBy as createdBy,
            ewca.UpdatedBy as updatedBy,
            ewca.DateCreated as dateCreated,
            ewca.DateUpdated as dateUpdated,
            wc.WorkCode as workCode,
            wc.WorkCodeName as workCodeName,
            wc.ColorCode as colorCode
        FROM EmployeeWorkCodeAssignment ewca
        LEFT JOIN WorkCodes wc ON ewca.WorkCodeId = wc.Id AND wc.TenantId = @TenantId
        WHERE ewca.TenantId = @TenantId
            AND ISNULL(ewca.IsDeleted, 0) = 0
            AND (@WorkCodeId = 0 OR ewca.WorkCodeId = @WorkCodeId)
            AND (@UserId = 0 OR ewca.UserId = @UserId)
            AND (
                @SearchStr = ''
                OR wc.WorkCode LIKE '%' + @SearchStr + '%'
                OR wc.WorkCodeName LIKE '%' + @SearchStr + '%'
            )
    )
    SELECT
        _rows.id,
        _rows.workCodeId,
        _rows.userId,
        _rows.isActive,
        _rows.effectiveDate,
        _rows.expiryDate,
        _rows.createdBy,
        _rows.updatedBy,
        _rows.dateCreated,
        _rows.dateUpdated,
        _rows.workCode,
        _rows.workCodeName,
        _rows.colorCode,
        (SELECT count(_rows.id) from _rows) as totalCount
    FROM _rows
    ORDER BY
        CASE WHEN @ValidSortColumn = 'workCode' AND @ValidSortDirection = 'ASC' THEN _rows.workCode END ASC,
        CASE WHEN @ValidSortColumn = 'workCode' AND @ValidSortDirection = 'DESC' THEN _rows.workCode END DESC,
        CASE WHEN @ValidSortColumn = 'workCodeName' AND @ValidSortDirection = 'ASC' THEN _rows.workCodeName END ASC,
        CASE WHEN @ValidSortColumn = 'workCodeName' AND @ValidSortDirection = 'DESC' THEN _rows.workCodeName END DESC,
        CASE WHEN @ValidSortColumn = 'effectiveDate' AND @ValidSortDirection = 'ASC' THEN _rows.effectiveDate END ASC,
        CASE WHEN @ValidSortColumn = 'effectiveDate' AND @ValidSortDirection = 'DESC' THEN _rows.effectiveDate END DESC,
        CASE WHEN @ValidSortColumn = 'expiryDate' AND @ValidSortDirection = 'ASC' THEN _rows.expiryDate END ASC,
        CASE WHEN @ValidSortColumn = 'expiryDate' AND @ValidSortDirection = 'DESC' THEN _rows.expiryDate END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

