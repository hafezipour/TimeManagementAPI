-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Get short list of labels for employee(s) - returns intersection (common) or union
-- =============================================

USE [TimeManagement_DEV]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeLabelAssignment_GetShortList')
    DROP PROCEDURE [dbo].[usp_EmployeeLabelAssignment_GetShortList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeLabelAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- If Common = 1 and UserIds provided, return labels common to ALL selected users (intersection)
        IF @Common = 1 AND @UserIds IS NOT NULL AND LEN(@UserIds) > 0
        BEGIN
            -- Get count of total users
            DECLARE @UserCount INT = (SELECT COUNT(*) FROM STRING_SPLIT(@UserIds, ',') WHERE RTRIM(value) != '')
            
            -- Return labels that are assigned to ALL users (intersection)
            SELECT 
                l.Id,
                l.LabelName,
                l.LabelCode,
                l.ColorCode,
                l.IsActive
            FROM Labels l
            WHERE l.TenantId = @TenantId
                AND l.IsActive = 1
                AND l.Id IN (
                    SELECT ela.LabelId
                    FROM EmployeeLabelAssignment ela
                    WHERE ela.TenantId = @TenantId
                        AND ela.IsDeleted = 0
                        AND ela.UserId IN (
                            SELECT CAST(value AS INT)
                            FROM STRING_SPLIT(@UserIds, ',')
                            WHERE RTRIM(value) != ''
                        )
                    GROUP BY ela.LabelId
                    HAVING COUNT(DISTINCT ela.UserId) = @UserCount -- All users must have this label
                )
            ORDER BY l.LabelName ASC
            FOR JSON PATH;
        END
        -- If UserId provided, return labels for that specific user
        ELSE IF @UserId IS NOT NULL
        BEGIN
            SELECT 
                l.Id,
                l.LabelName,
                l.LabelCode,
                l.ColorCode,
                l.IsActive
            FROM Labels l
            INNER JOIN EmployeeLabelAssignment ela ON l.Id = ela.LabelId
            WHERE ela.UserId = @UserId
                AND ela.TenantId = @TenantId
                AND ela.IsDeleted = 0
                AND l.IsActive = 1
            ORDER BY l.LabelName ASC
            FOR JSON PATH;
        END
        -- Otherwise, return empty array
        ELSE
        BEGIN
            SELECT 
                Id = NULL,
                LabelName = NULL,
                LabelCode = NULL,
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

PRINT 'usp_EmployeeLabelAssignment_GetShortList created successfully!'
GO

