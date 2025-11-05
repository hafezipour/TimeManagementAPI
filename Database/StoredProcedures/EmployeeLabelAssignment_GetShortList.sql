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
        SELECT 
            ela.Id AS id,
            ela.UserId AS userId,
            l.Id AS labelId,
            l.LabelName AS labelName,
            l.LabelCode AS labelCode,
            l.ColorCode AS colorCode,
            l.IsActive AS isActive
        FROM Labels l
        INNER JOIN EmployeeLabelAssignment ela ON l.Id = ela.LabelId
        WHERE ela.UserId = ISNULL(@UserId, 0)
            AND ela.TenantId = @TenantId
            AND ela.IsDeleted = 0
            AND l.IsActive = 1
        ORDER BY l.LabelName ASC
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

PRINT 'usp_EmployeeLabelAssignment_GetShortList created successfully!'
GO

