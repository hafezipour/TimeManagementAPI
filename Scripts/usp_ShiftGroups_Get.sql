USE [TimeManagementService]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Get Shift Groups with server-side paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ShiftGroups_Get]
	@GroupId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'GroupName',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	;WITH _rows AS (
		SELECT 
			g.Id as id,
			g.GroupName as groupName,
			g.GroupTypeCustomTableValueId as groupTypeCustomTableValueId,
			g.Description as description,
			g.ColorCode as colorCode,
			g.IsActive as isActive,
			g.CreatedBy as createdBy,
			g.UpdatedBy as updatedBy,
			g.DateCreated as dateCreated,
			g.DateUpdated as dateUpdated
		FROM ShiftGroups g
		WHERE g.TenantId = @TenantId
			AND (@GroupId IS NULL OR g.Id = @GroupId)
			AND (
				@SearchTerm IS NULL OR 
				g.GroupName LIKE '%' + @SearchTerm + '%' OR 
				g.Description LIKE '%' + @SearchTerm + '%'
			)
	)
	SELECT 
		_rows.id,
		_rows.groupName,
		_rows.groupTypeCustomTableValueId,
		_rows.description,
		_rows.colorCode,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		(SELECT count(_rows.id) from _rows) as totalCount
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'GroupName' AND @SortDirection = 'ASC' THEN _rows.groupName END ASC,
		CASE WHEN @SortColumn = 'GroupName' AND @SortDirection = 'DESC' THEN _rows.groupName END DESC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'ASC' THEN _rows.description END ASC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'DESC' THEN _rows.description END DESC,
		_rows.groupName ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO


