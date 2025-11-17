USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualProfiles_GetShortList]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get short list of Accrual Profiles
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualProfiles_GetShortList]
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ap.Id AS id,
        ap.ProfileName AS profileName
    FROM AccrualProfiles ap
    WHERE ap.TenantId = @TenantId
    ORDER BY ap.ProfileName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

