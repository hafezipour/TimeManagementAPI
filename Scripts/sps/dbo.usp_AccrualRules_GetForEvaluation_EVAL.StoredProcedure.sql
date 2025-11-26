USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualRules_GetForEvaluation_EVAL]    Script Date: 11/23/2025 1:28:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Auto Generated
-- Create date: 11/23/2025
-- Description: Get all Accrual Rule Slots with Rule and Type information for evaluation
--              Returns comprehensive slot data for all tenants without employee filtering
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualRules_GetForEvaluation_EVAL]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Accrual Rule Slot Information (primary)
        ars.Id AS id,
        ars.AccrualRuleId AS accrualRuleId,
        ars.AccrueAmount AS accrueAmount,
        ars.AccrueUnit AS accrueUnit,
        ars.AccrueFrequency AS accrueFrequency,
        ars.AccrueFrequencyValue AS accrueFrequencyValue,
        ars.WorkCodeId AS workCodeId,
        ars.SortOrder AS sortOrder,
        ars.CreatedBy AS createdBy,
        ars.UpdatedBy AS updatedBy,
        ars.DateCreated AS dateCreated,
        ars.DateUpdated AS dateUpdated,
        ars.TenantId AS tenantId,
        -- Accrual Rule Information
        ar.Id AS ruleId,
        ar.AccrualProfileId AS accrualProfileId,
        ar.AccrualTypeId AS accrualTypeId,
        ar.DeductionMultiplier AS deductionMultiplier,
        ar.IsStopAccruingEnabled AS isStopAccruingEnabled,
        ar.StopAccruingAfterReaching AS stopAccruingAfterReaching,
        ar.CreatedBy AS ruleCreatedBy,
        ar.UpdatedBy AS ruleUpdatedBy,
        ar.DateCreated AS ruleDateCreated,
        ar.DateUpdated AS ruleDateUpdated,
        -- Accrual Type Information
        at.Id AS typeId,
        at.TypeCode AS typeCode,
        at.TypeName AS typeName,
        at.Description AS typeDescription,
        at.CustomTableUnitId AS customTableUnitId,
        at.MaxBalance AS maxBalance,
        at.MaxCarryOver AS maxCarryOver,
        at.CarryOverExpiryMonths AS carryOverExpiryMonths,
        at.IsActive AS typeIsActive
    FROM AccrualRulesSlots ars
    INNER JOIN AccrualRules ar ON ars.AccrualRuleId = ar.Id
    INNER JOIN AccrualTypes at ON ar.AccrualTypeId = at.Id
    ORDER BY ars.TenantId, at.TypeName, ars.SortOrder
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

