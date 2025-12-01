USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualProfiles_GetByProfileOrTrackIds]    Script Date: 11/27/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Auto Generated
-- Create date: 11/27/2025
-- Description: Get Accrual Profiles by Profile IDs and/or Track IDs
--              Returns all profiles that match the provided profile IDs OR belong to the provided track IDs
--              Returns all profile table columns
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualProfiles_GetByProfileOrTrackIds]
    @AccrualProfileIdsJson NVARCHAR(MAX) = NULL,
    @AccrualTrackIdsJson NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Parse JSON array of profile IDs if provided
    DECLARE @ProfileIds TABLE (AccrualProfileId INT);
    
    IF @AccrualProfileIdsJson IS NOT NULL AND LEN(@AccrualProfileIdsJson) > 0
    BEGIN
        INSERT INTO @ProfileIds (AccrualProfileId)
        SELECT value AS AccrualProfileId
        FROM OPENJSON(@AccrualProfileIdsJson)
        WHERE value IS NOT NULL;
    END

    -- Parse JSON array of track IDs if provided
    DECLARE @TrackIds TABLE (AccrualTrackId INT);
    
    IF @AccrualTrackIdsJson IS NOT NULL AND LEN(@AccrualTrackIdsJson) > 0
    BEGIN
        INSERT INTO @TrackIds (AccrualTrackId)
        SELECT value AS AccrualTrackId
        FROM OPENJSON(@AccrualTrackIdsJson)
        WHERE value IS NOT NULL;
    END

    -- First: Get profiles from tracks (if track IDs are provided)
    -- Select from AccrualTrackProfiles and join AccrualProfiles, include trackId
    -- Second: Get direct profile IDs (if profile IDs are provided)
    -- UNION them together
    SELECT DISTINCT
        ap.Id AS id,
        ap.ProfileName AS profileName,
        ap.IsBaseOnYearsServed AS isBaseOnYearsServed,
        ap.FromYears AS fromYears,
        ap.ToYears AS toYears,
        ap.Description AS description,
        ap.CreatedBy AS createdBy,
        ap.UpdatedBy AS updatedBy,
        ap.DateCreated AS dateCreated,
        ap.DateUpdated AS dateUpdated,
        ap.TenantId AS tenantId,
        atp.AccrualTrackId AS trackId
    FROM AccrualTrackProfiles atp
    INNER JOIN AccrualProfiles ap ON atp.AccrualProfileId = ap.Id
    INNER JOIN @TrackIds t ON atp.AccrualTrackId = t.AccrualTrackId
    WHERE EXISTS (SELECT 1 FROM @TrackIds)

    UNION

    SELECT DISTINCT
        ap.Id AS id,
        ap.ProfileName AS profileName,
        ap.IsBaseOnYearsServed AS isBaseOnYearsServed,
        ap.FromYears AS fromYears,
        ap.ToYears AS toYears,
        ap.Description AS description,
        ap.CreatedBy AS createdBy,
        ap.UpdatedBy AS updatedBy,
        ap.DateCreated AS dateCreated,
        ap.DateUpdated AS dateUpdated,
        ap.TenantId AS tenantId,
        NULL AS trackId
    FROM AccrualProfiles ap
    WHERE EXISTS (SELECT 1 FROM @ProfileIds)
      AND EXISTS (SELECT 1 FROM @ProfileIds WHERE AccrualProfileId = ap.Id)

    ORDER BY profileName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

