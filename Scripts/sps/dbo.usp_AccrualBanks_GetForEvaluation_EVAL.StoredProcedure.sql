USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_GetForEvaluation_EVAL]    Script Date: 11/23/2025 1:28:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Auto Generated
-- Create date: 11/23/2025
-- Description: Get all Accrual Banks for evaluation
--              Returns all banks for all tenants and users with AccrualStartDate from EmployeeAccrualSettings
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_GetForEvaluation_EVAL]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ab.Id AS id,
        ab.TenantId AS tenantId,
        ab.UserId AS userId,
        ab.AccrualProfileId AS accrualProfileId,
        ab.AccrualRulesSlotId AS accrualRulesSlotId,
        ab.AccrualTrackId AS accrualTrackId,
        ab.AccrualTypeId AS accrualTypeId,
        ab.AccrualRuleId AS accrualRuleId,
        ab.CurrentBalance AS currentBalance,
        ab.UsedBalance AS usedBalance,
        ab.DateCreated AS dateCreated,
        ab.CreatedBy AS createdBy,
        ab.DateUpdated AS dateUpdated,
        ab.UpdatedBy AS updatedBy,
        eas.AccrualStartDate AS accrualStartDate
    FROM [dbo].[AccrualBanks] ab
    LEFT JOIN [dbo].[EmployeeAccrualSettings] eas 
        ON ab.UserId = eas.UserId 
        AND ab.AccrualProfileId = eas.AccrualProfileId 
        AND ab.TenantId = eas.TenantId
        AND eas.IsActive = 1
    ORDER BY ab.TenantId, ab.UserId, ab.AccrualProfileId
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

