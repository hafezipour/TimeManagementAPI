USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualRules_Get]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get Accrual Rules
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualRules_Get]
    @AccrualProfileId INT = NULL,
    @AccrualTypeId INT = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ar.Id AS id,
        ar.AccrualProfileId AS accrualProfileId,
        ar.AccrualTypeId AS accrualTypeId,
        ar.DeductionMultiplier AS deductionMultiplier,
        ar.IsStopAccruingEnabled AS isStopAccruingEnabled,
        ar.StopAccruingAfterReaching AS stopAccruingAfterReaching,
        ar.CreatedBy AS createdBy,
        ar.UpdatedBy AS updatedBy,
        ar.DateCreated AS dateCreated,
        ar.DateUpdated AS dateUpdated,
        (
            SELECT
                ars.Id AS id,
                ars.AccrualRuleId AS accrualRuleId,
                ars.AccrueAmount AS accrueAmount,
                ars.AccrueUnit AS accrueUnit,
                ars.AccrueFrequency AS accrueFrequency,
                ars.SortOrder AS sortOrder,
                ars.CreatedBy AS createdBy,
                ars.UpdatedBy AS updatedBy,
                ars.DateCreated AS dateCreated,
                ars.DateUpdated AS dateUpdated
            FROM AccrualRulesSlots ars
            WHERE ars.AccrualRuleId = ar.Id
            ORDER BY ars.SortOrder
            FOR JSON PATH
        ) AS slots
    FROM AccrualRules ar
    WHERE ar.TenantId = @TenantId
      AND (@AccrualProfileId IS NULL OR ar.AccrualProfileId = @AccrualProfileId)
      AND (@AccrualTypeId IS NULL OR ar.AccrualTypeId = @AccrualTypeId)
    ORDER BY ar.DateCreated DESC
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

