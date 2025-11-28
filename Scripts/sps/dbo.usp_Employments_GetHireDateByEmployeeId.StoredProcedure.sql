USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Employments_GetHireDateByEmployeeId]    Script Date: 11/27/2025 5:17:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ali Nafees
-- Create date: 11/19/2025
-- Description:	Used to get the Employee Hire Date by User IDs
--              Accepts JSON array of userIds: [{"userId": 1}, {"userId": 2}, ...]
-- =============================================
ALTER PROCEDURE [dbo].[usp_Employments_GetHireDateByEmployeeId]
	@TenantId INT,
	@Json NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	-- Get default organization
	DECLARE @defaultOrganization INT
	SELECT @defaultOrganization = OrganizationId 
	FROM SystemSettings 
	WHERE TenantId = @TenantId

	-- Get Hired action ID
	DECLARE @HiredActionId INT
	SELECT @HiredActionId = Id 
	FROM CustomTableValues CTV 
	WHERE CTV.TenantId = @TenantId 
		AND CTV.ShortDescription = 'Hired'

	-- Parse JSON to get user IDs
	DECLARE @UserIds TABLE (UserId INT)
	
	INSERT INTO @UserIds (UserId)
	SELECT userId
	FROM OPENJSON(@Json)
	WITH (
		userId INT '$.userId'
	)

	-- Get hire date information by joining Users with Employees and Employments
	SELECT 
		U.Id AS userId,
		E.EmployeeId AS employeeId,
		EMP.ActionDate AS hireDate,
		EMP.ActionCustomTableValueId AS actionCustomTableValueId
	FROM Users U
	INNER JOIN Employees E ON E.EmployeeId = U.PersonId
	INNER JOIN @UserIds UI ON UI.UserId = U.Id
	LEFT JOIN Employments EMP ON EMP.EmployeeId = E.EmployeeId
		AND EMP.OrganizationId = @defaultOrganization
		AND EMP.TenantId = @TenantId
		AND EMP.ActionCustomTableValueID = @HiredActionId
	WHERE U.TenantId = @TenantId
	FOR JSON PATH, INCLUDE_NULL_VALUES

END
GO


