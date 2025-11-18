USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTracks_Delete]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Delete Accrual Track
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTracks_Delete]
    @AccrualTrackId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF (@AccrualTrackId IS NULL OR @AccrualTrackId <= 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Track Id is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if track exists and belongs to tenant
        IF NOT EXISTS (SELECT 1 FROM AccrualTracks WHERE Id = @AccrualTrackId AND TenantId = @TenantId)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Track not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Delete the track (AccrualTrackProfiles will be deleted automatically due to CASCADE)
        DELETE FROM AccrualTracks
        WHERE Id = @AccrualTrackId AND TenantId = @TenantId;

        SELECT CAST(1 AS BIT) AS success, 'Accrual track deleted successfully.' AS message
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

