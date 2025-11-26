USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAccrualSettings_GetForEvaluation_EVAL]    Script Date: 11/23/2025 1:28:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Auto Generated
-- Create date: 11/23/2025
-- Description: Get Employee Accrual Settings for evaluation
--              Accepts JSON array of AccrualProfileIds and returns matching settings for all tenants
-- =============================================
CREATE PROCEDURE [dbo].[usp_EmployeeAccrualSettings_GetForEvaluation_EVAL]
    @ProfileIdsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Parse JSON array of profile IDs
    DECLARE @ProfileIds TABLE (AccrualProfileId INT);

    INSERT INTO @ProfileIds (AccrualProfileId)
    SELECT value AS AccrualProfileId
    FROM OPENJSON(@ProfileIdsJson)
    WHERE value IS NOT NULL;

    -- Return Employee Accrual Settings matching the profile IDs for all tenants
    SELECT 
        eas.Id AS id,
        eas.UserId AS userId,
        eas.AccrualTrackId AS accrualTrackId,
        eas.AccrualProfileId AS accrualProfileId,
        eas.AccrualStartDate AS accrualStartDate,
        eas.IsActive AS isActive,
        eas.TenantId AS tenantId,
        eas.CreatedBy AS createdBy,
        eas.UpdatedBy AS updatedBy,
        eas.DateCreated AS dateCreated,
        eas.DateUpdated AS dateUpdated
    FROM [dbo].[EmployeeAccrualSettings] eas
    INNER JOIN @ProfileIds p ON eas.AccrualProfileId = p.AccrualProfileId
    WHERE eas.IsActive = 1
    ORDER BY eas.TenantId, eas.UserId
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

