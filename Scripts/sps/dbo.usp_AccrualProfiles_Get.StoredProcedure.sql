USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualProfiles_Get]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get Accrual Profiles
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualProfiles_Get]
    @AccrualProfileId INT = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ap.Id AS id,
        ap.ProfileName AS profileName,
        ap.IsBaseOnYearsServed AS isBaseOnYearsServed,
        ap.FromYears AS fromYears,
        ap.ToYears AS toYears,
        ap.Description AS description,
        ap.CreatedBy AS createdBy,
        ap.UpdatedBy AS updatedBy,
        ap.DateCreated AS dateCreated,
        ap.DateUpdated AS dateUpdated
    FROM AccrualProfiles ap
    WHERE ap.TenantId = @TenantId
      AND (@AccrualProfileId IS NULL OR ap.Id = @AccrualProfileId)
    ORDER BY ap.ProfileName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

