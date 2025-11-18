USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTracks_Get]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Get Accrual Tracks
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTracks_Get]
    @AccrualTrackId INT = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        at.Id AS id,
        at.Name AS name,
        at.CreatedBy AS createdBy,
        at.UpdatedBy AS updatedBy,
        at.DateCreated AS dateCreated,
        at.DateUpdated AS dateUpdated,
        (
            SELECT
                atp.Id AS id,
                atp.AccrualTrackId AS accrualTrackId,
                atp.AccrualProfileId AS accrualProfileId,
                atp.SortOrder AS sortOrder,
                ap.ProfileName AS profileName,
                ap.IsBaseOnYearsServed AS isBaseOnYearsServed,
                ap.FromYears AS fromYears,
                ap.ToYears AS toYears,
                atp.CreatedBy AS createdBy,
                atp.UpdatedBy AS updatedBy,
                atp.DateCreated AS dateCreated,
                atp.DateUpdated AS dateUpdated
            FROM AccrualTrackProfiles atp
            INNER JOIN AccrualProfiles ap ON atp.AccrualProfileId = ap.Id
            WHERE atp.AccrualTrackId = at.Id
              AND atp.TenantId = @TenantId
            ORDER BY atp.SortOrder
            FOR JSON PATH
        ) AS profiles
    FROM AccrualTracks at
    WHERE at.TenantId = @TenantId
      AND (@AccrualTrackId IS NULL OR at.Id = @AccrualTrackId)
    ORDER BY at.Name
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

