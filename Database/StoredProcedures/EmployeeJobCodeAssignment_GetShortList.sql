-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Get short list of job codes for employee(s) - returns intersection (common) or union
-- =============================================

USE [TimeManagement_DEV]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeJobCodeAssignment_GetShortList')
    DROP PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_GetShortList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            ejca.Id AS id,
            ejca.UserId AS userId,
            jc.Id AS jobCodeId,
            jc.JobTitle AS jobTitle,
            jc.JobCode AS jobCode,
            jc.IsActive AS isActive
        FROM JobCodes jc
        INNER JOIN EmployeeJobCodeAssignment ejca ON jc.Id = ejca.JobCodeId
        WHERE ejca.UserId = ISNULL(@UserId, 0)
            AND ejca.TenantId = @TenantId
            AND ejca.IsActive = 1
            AND jc.IsActive = 1
        ORDER BY jc.JobTitle ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            CAST(0 AS BIT) AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

PRINT 'usp_EmployeeJobCodeAssignment_GetShortList created successfully!'
GO

