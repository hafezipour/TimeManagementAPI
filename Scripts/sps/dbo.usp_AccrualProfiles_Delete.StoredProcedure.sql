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
        DELETE FROM AccrualProfiles
        WHERE Id = @AccrualProfileId
          AND TenantId = @TenantId;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Accrual profile not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        SELECT
            CAST(1 AS BIT) AS success,
            'Accrual profile deleted successfully.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        SELECT
            CAST(0 AS BIT) AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

