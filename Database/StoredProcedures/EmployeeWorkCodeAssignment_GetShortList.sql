-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Get short list of work codes for employee(s) - returns intersection (common) or union
-- =============================================

USE [TimeManagement_DEV]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeWorkCodeAssignment_GetShortList')
    DROP PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_GetShortList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            ewca.Id AS id,
            ewca.UserId AS userId,
            wc.Id AS workCodeId,
            wc.WorkCodeName AS workCodeName,
            wc.WorkCode AS workCode,
            wc.ColorCode AS colorCode,
            wc.IsActive AS isActive
        FROM WorkCodes wc
        INNER JOIN EmployeeWorkCodeAssignment ewca ON wc.Id = ewca.WorkCodeId
        WHERE ewca.UserId = ISNULL(@UserId, 0)
            AND ewca.TenantId = @TenantId
            AND ewca.IsActive = 1
            AND wc.IsActive = 1
        ORDER BY wc.WorkCodeName ASC
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

PRINT 'usp_EmployeeWorkCodeAssignment_GetShortList created successfully!'
GO

