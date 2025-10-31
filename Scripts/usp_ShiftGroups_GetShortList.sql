USE [TimeManagementService]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Get Shift Groups Short List for dropdowns/lookups
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ShiftGroups_GetShortList]
(
	@TenantId int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		g.Id as id,
		g.GroupName as groupName,
		g.ColorCode as colorCode,
		g.IsActive as isActive
	FROM ShiftGroups g
	WHERE g.TenantId = @TenantId
		AND ISNULL(g.IsActive, 1) = 1
	ORDER BY g.GroupName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO


