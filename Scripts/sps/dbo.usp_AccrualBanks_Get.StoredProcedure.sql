USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_Get]    Script Date: 11/19/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/19/2025
-- Description: Get Accrual Banks for a user and accrual profile
--              Joins AccrualRulesSlots, AccrualRules, AccrualBanks, and AccrualTypes
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_Get]
    @UserId INT,
    @AccrualProfileId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Accrual Rule Slot Information (primary table)
        ars.Id AS slotId,
        ars.AccrualRuleId AS accrualRuleId,
        ars.AccrueAmount AS accrueAmount,
        ars.AccrueUnit AS accrueUnit,
        ars.AccrueFrequency AS accrueFrequency,
        ars.AccrueFrequencyValue AS accrueFrequencyValue,
        ars.WorkCodeId AS workCodeId,
        ars.SortOrder AS slotSortOrder,
        ars.CreatedBy AS slotCreatedBy,
        ars.UpdatedBy AS slotUpdatedBy,
        ars.DateCreated AS slotDateCreated,
        ars.DateUpdated AS slotDateUpdated,
        -- Accrual Bank Information
        ab.Id AS id,
        ab.UserId AS userId,
        ab.AccrualProfileId AS accrualProfileId,
        ab.AccrualTrackId AS accrualTrackId,
        ab.AccrualTypeId AS accrualTypeId,
        ab.AccrualRuleId AS bankAccrualRuleId,
        ab.AccrualRulesSlotId AS accrualRulesSlotId,
        ab.CurrentBalance AS currentBalance,
        ab.UsedBalance AS usedBalance,
        ab.DateCreated AS dateCreated,
        ab.CreatedBy AS createdBy,
        ab.DateUpdated AS dateUpdated,
        ab.UpdatedBy AS updatedBy,
        -- Accrual Rule Information
        ar.AccrualProfileId AS ruleAccrualProfileId,
        ar.AccrualTypeId AS ruleAccrualTypeId,
        ar.DeductionMultiplier AS deductionMultiplier,
        ar.IsStopAccruingEnabled AS isStopAccruingEnabled,
        ar.StopAccruingAfterReaching AS stopAccruingAfterReaching,
        -- Accrual Type Information
        at.TypeName AS typeName,
        at.TypeCode AS typeCode,
        at.MaxBalance AS maxBalance
    FROM [dbo].[AccrualRulesSlots] ars
    INNER JOIN [dbo].[AccrualRules] ar ON ars.AccrualRuleId = ar.Id
        AND ar.TenantId = @TenantId
    INNER JOIN [dbo].[AccrualTypes] at ON ar.AccrualTypeId = at.Id
        AND at.TenantId = @TenantId
    LEFT JOIN [dbo].[AccrualBanks] ab ON ars.Id = ab.AccrualRulesSlotId
        AND ab.UserId = @UserId
        AND ab.AccrualProfileId = @AccrualProfileId
        AND ab.TenantId = @TenantId
    WHERE ars.TenantId = @TenantId
        AND ar.AccrualProfileId = @AccrualProfileId
    ORDER BY at.TypeName, ars.SortOrder
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

