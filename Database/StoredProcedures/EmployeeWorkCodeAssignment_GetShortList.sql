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
        -- If Common = 1 and UserIds provided, return work codes common to ALL selected users (intersection)
        IF @Common = 1 AND @UserIds IS NOT NULL AND LEN(@UserIds) > 0
        BEGIN
            -- Get count of total users
            DECLARE @UserCount INT = (SELECT COUNT(*) FROM STRING_SPLIT(@UserIds, ',') WHERE RTRIM(value) != '')
            
            -- Return work codes that are assigned to ALL users (intersection)
            SELECT 
                wc.Id,
                wc.WorkCodeName,
                wc.WorkCode,
                wc.ColorCode,
                wc.IsActive
            FROM WorkCodes wc
            WHERE wc.TenantId = @TenantId
                AND wc.IsActive = 1
                AND wc.Id IN (
                    SELECT ewca.WorkCodeId
                    FROM EmployeeWorkCodeAssignment ewca
                    WHERE ewca.TenantId = @TenantId
                        AND ewca.IsActive = 1
                        AND ewca.UserId IN (
                            SELECT CAST(value AS INT)
                            FROM STRING_SPLIT(@UserIds, ',')
                            WHERE RTRIM(value) != ''
                        )
                    GROUP BY ewca.WorkCodeId
                    HAVING COUNT(DISTINCT ewca.UserId) = @UserCount -- All users must have this work code
                )
            ORDER BY wc.WorkCodeName ASC
            FOR JSON PATH;
        END
        -- If UserId provided, return work codes for that specific user
        ELSE IF @UserId IS NOT NULL
        BEGIN
            SELECT 
                wc.Id,
                wc.WorkCodeName,
                wc.WorkCode,
                wc.ColorCode,
                wc.IsActive
            FROM WorkCodes wc
            INNER JOIN EmployeeWorkCodeAssignment ewca ON wc.Id = ewca.WorkCodeId
            WHERE ewca.UserId = @UserId
                AND ewca.TenantId = @TenantId
                AND ewca.IsActive = 1
                AND wc.IsActive = 1
            ORDER BY wc.WorkCodeName ASC
            FOR JSON PATH;
        END
        -- Otherwise, return empty array
        ELSE
        BEGIN
            SELECT 
                Id = NULL,
                WorkCodeName = NULL,
                WorkCode = NULL,
                ColorCode = NULL,
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

PRINT 'usp_EmployeeWorkCodeAssignment_GetShortList created successfully!'
GO

