USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_GetByAccrualType]    Script Date: 12/5/2025 3:12:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Auto Generated
-- Create date: 12/5/2025
-- Description: Get all accrual banks for a specific accrual type and user
--              Returns banks with their current balances and unit information
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_GetByAccrualType]
    @UserId INT,
    @AccrualTypeId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Accrual Bank Information
        ab.Id AS id,
        ab.UserId AS userId,
        ab.AccrualProfileId AS accrualProfileId,
        ab.AccrualTrackId AS accrualTrackId,
        ab.AccrualTypeId AS accrualTypeId,
        ab.AccrualRuleId AS accrualRuleId,
        ab.AccrualRulesSlotId AS accrualRulesSlotId,
        ab.CurrentBalance AS currentBalance,
        ab.UsedBalance AS usedBalance,
        -- Accrual Rule Slot Information (for unit)
        ars.AccrueUnit AS accrueUnit,
        -- Accrual Rule Information
        ar.DeductionMultiplier AS deductionMultiplier
    FROM [dbo].[AccrualBanks] ab
    INNER JOIN [dbo].[AccrualRulesSlots] ars ON ab.AccrualRulesSlotId = ars.Id
        AND ars.TenantId = @TenantId
    INNER JOIN [dbo].[AccrualRules] ar ON ab.AccrualRuleId = ar.Id
        AND ar.TenantId = @TenantId
    WHERE ab.UserId = @UserId
        AND ab.AccrualTypeId = @AccrualTypeId
        AND ab.TenantId = @TenantId
    ORDER BY ab.Id
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO
