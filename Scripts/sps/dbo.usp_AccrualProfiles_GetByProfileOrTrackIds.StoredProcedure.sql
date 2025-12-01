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
    @AccrualTrackIdsJson NVARCHAR(MAX) = NULL,
    @TenantId INT
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

    -- Get profiles that match profile IDs OR belong to track IDs
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
        ap.TenantId AS tenantId
    FROM AccrualProfiles ap
    WHERE ap.TenantId = @TenantId
      AND (
          -- Match direct profile IDs
          (EXISTS (SELECT 1 FROM @ProfileIds) AND EXISTS (SELECT 1 FROM @ProfileIds WHERE AccrualProfileId = ap.Id))
          OR
          -- Match profiles from tracks
          (EXISTS (SELECT 1 FROM @TrackIds) AND EXISTS (
              SELECT 1 
              FROM AccrualTrackProfiles atp
              INNER JOIN @TrackIds t ON atp.AccrualTrackId = t.AccrualTrackId
              WHERE atp.AccrualProfileId = ap.Id
                AND atp.TenantId = @TenantId
          ))
      )
    ORDER BY ap.ProfileName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

