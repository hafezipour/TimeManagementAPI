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
        -- If Common = 1 and UserIds provided, return job codes common to ALL selected users (intersection)
        IF @Common = 1 AND @UserIds IS NOT NULL AND LEN(@UserIds) > 0
        BEGIN
            -- Get count of total users
            DECLARE @UserCount INT = (SELECT COUNT(*) FROM STRING_SPLIT(@UserIds, ',') WHERE RTRIM(value) != '')
            
            -- Return job codes that are assigned to ALL users (intersection)
            SELECT 
                jc.Id,
                jc.JobTitle,
                jc.JobCode,
                jc.IsActive
            FROM JobCodes jc
            WHERE jc.TenantId = @TenantId
                AND jc.IsActive = 1
                AND jc.Id IN (
                    SELECT ejca.JobCodeId
                    FROM EmployeeJobCodeAssignment ejca
                    WHERE ejca.TenantId = @TenantId
                        AND ejca.IsActive = 1
                        AND ejca.UserId IN (
                            SELECT CAST(value AS INT)
                            FROM STRING_SPLIT(@UserIds, ',')
                            WHERE RTRIM(value) != ''
                        )
                    GROUP BY ejca.JobCodeId
                    HAVING COUNT(DISTINCT ejca.UserId) = @UserCount -- All users must have this job code
                )
            ORDER BY jc.JobTitle ASC
            FOR JSON PATH;
        END
        -- If UserId provided, return job codes for that specific user
        ELSE IF @UserId IS NOT NULL
        BEGIN
            SELECT 
                jc.Id,
                jc.JobTitle,
                jc.JobCode,
                jc.IsActive
            FROM JobCodes jc
            INNER JOIN EmployeeJobCodeAssignment ejca ON jc.Id = ejca.JobCodeId
            WHERE ejca.UserId = @UserId
                AND ejca.TenantId = @TenantId
                AND ejca.IsActive = 1
                AND jc.IsActive = 1
            ORDER BY jc.JobTitle ASC
            FOR JSON PATH;
        END
        -- Otherwise, return empty array
        ELSE
        BEGIN
            SELECT 
                Id = NULL,
                JobTitle = NULL,
                JobCode = NULL,
                IsActive = NULL
            WHERE 1 = 0
            FOR JSON PATH;
        END

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

