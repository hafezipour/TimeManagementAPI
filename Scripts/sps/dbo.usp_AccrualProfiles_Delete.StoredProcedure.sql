USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualProfiles_Delete]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Delete Accrual Profile
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualProfiles_Delete]
    @AccrualProfileId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation: Check if profile exists
        IF NOT EXISTS (SELECT 1 FROM AccrualProfiles WHERE Id = @AccrualProfileId AND TenantId = @TenantId)
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Accrual profile not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if profile is used in Accrual Tracks
        IF EXISTS (
            SELECT 1 
            FROM AccrualTrackProfiles atp
            INNER JOIN AccrualTracks at ON atp.AccrualTrackId = at.Id
            WHERE atp.AccrualProfileId = @AccrualProfileId
              AND atp.TenantId = @TenantId
        )
        BEGIN
            DECLARE @TrackNames NVARCHAR(MAX);
            SELECT @TrackNames = STRING_AGG(at.Name, ', ')
            FROM AccrualTrackProfiles atp
            INNER JOIN AccrualTracks at ON atp.AccrualTrackId = at.Id
            WHERE atp.AccrualProfileId = @AccrualProfileId
              AND atp.TenantId = @TenantId;

            SELECT
                CAST(0 AS BIT) AS success,
                'Cannot delete accrual profile. It is currently being used in the following accrual track(s): ' + ISNULL(@TrackNames, '') + '. Please remove it from the track(s) before deleting.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if profile is used in Accrual Rules
        IF EXISTS (
            SELECT 1 
            FROM AccrualRules ar
            WHERE ar.AccrualProfileId = @AccrualProfileId
              AND ar.TenantId = @TenantId
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Cannot delete accrual profile. It is currently being used in accrual rules. Please remove all associated accrual rules before deleting.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Delete the profile
        DELETE FROM AccrualProfiles
        WHERE Id = @AccrualProfileId
          AND TenantId = @TenantId;

        SELECT
            CAST(1 AS BIT) AS success,
            'Accrual profile deleted successfully.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

