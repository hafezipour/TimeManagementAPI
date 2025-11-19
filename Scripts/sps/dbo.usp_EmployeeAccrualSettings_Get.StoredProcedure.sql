USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAccrualSettings_Get]    Script Date: 11/19/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/19/2025
-- Description: Get Employee Accrual Settings by UserId where IsActive = true
-- =============================================
ALTER PROCEDURE [dbo].[usp_EmployeeAccrualSettings_Get]
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE eas.UserId = @UserId
        AND eas.TenantId = @TenantId
        AND eas.IsActive = 1
    FOR JSON PATH;
END
GO

