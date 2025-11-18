USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTracks_Save]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Insert/Update Accrual Tracks with Profiles
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTracks_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @Name VARCHAR(255);

        -- Parse main track data
        SELECT
            @Id = id,
            @Name = name
        FROM OPENJSON(@Json) WITH (
            id INT,
            name VARCHAR(255)
        );

        -- Validation
        IF (@Name IS NULL OR LTRIM(RTRIM(@Name)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Track Name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check for duplicate name (same tenant, different id)
        IF EXISTS (
            SELECT 1
            FROM AccrualTracks
            WHERE TenantId = @TenantId
              AND Name = @Name
              AND Id <> ISNULL(@Id, 0)
        )
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Track Name already exists for this tenant.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update or Insert main track
        IF EXISTS (SELECT 1 FROM AccrualTracks WHERE Id = ISNULL(@Id, 0) AND TenantId = @TenantId)
        BEGIN
            UPDATE AccrualTracks
            SET
                Name = @Name,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            WHERE Id = @Id AND TenantId = @TenantId;
        END
        ELSE
        BEGIN
            INSERT INTO AccrualTracks (
                TenantId,
                Name,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @Name,
                @UserId,
                SYSUTCDATETIME()
            );

            SET @Id = SCOPE_IDENTITY();
        END

        -- Process profiles: Insert, Update, and Delete
        -- Create temporary table to hold incoming profiles
        CREATE TABLE #IncomingProfiles (
            Id INT NULL,
            AccrualProfileId INT,
            SortOrder INT
        );

        -- Extract and populate profiles directly from JSON using OPENJSON
        INSERT INTO #IncomingProfiles (Id, AccrualProfileId, SortOrder)
        SELECT
            CASE WHEN id IS NULL THEN NULL ELSE id END AS id,
            accrualProfileId,
            ISNULL(sortOrder, 0) AS sortOrder
        FROM OPENJSON(@Json, '$.profiles') WITH (
            id INT,
            accrualProfileId INT,
            sortOrder INT
        );

        -- Process profiles if any were found
        IF EXISTS (SELECT 1 FROM #IncomingProfiles)
        BEGIN
            -- Capture existing profile IDs BEFORE we insert new ones
            CREATE TABLE #ExistingProfileIds (
                Id INT PRIMARY KEY
            );
            
            INSERT INTO #ExistingProfileIds (Id)
            SELECT Id 
            FROM AccrualTrackProfiles 
            WHERE AccrualTrackId = @Id 
              AND TenantId = @TenantId
              AND Id IS NOT NULL 
              AND Id > 0;

            -- Validate that all incoming profile IDs exist and belong to tenant
            IF EXISTS (
                SELECT 1 
                FROM #IncomingProfiles ins
                WHERE ins.AccrualProfileId IS NOT NULL
                  AND NOT EXISTS (
                      SELECT 1 
                      FROM AccrualProfiles ap 
                      WHERE ap.Id = ins.AccrualProfileId 
                        AND ap.TenantId = @TenantId
                  )
            )
            BEGIN
                SELECT CAST(0 AS BIT) AS success, 'One or more accrual profiles not found or do not belong to this tenant.' AS message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Update existing profiles (those with id > 0 that exist in database)
            UPDATE atp
            SET
                AccrualProfileId = ins.AccrualProfileId,
                SortOrder = ins.SortOrder,
                TenantId = @TenantId,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            FROM AccrualTrackProfiles atp
            INNER JOIN #IncomingProfiles ins ON atp.Id = ins.Id
            WHERE atp.AccrualTrackId = @Id
              AND atp.TenantId = @TenantId
              AND ins.Id IS NOT NULL
              AND ins.Id > 0;

            -- Insert new profiles (those without id or id is null/0, or id not found in existing)
            INSERT INTO AccrualTrackProfiles (
                AccrualTrackId,
                AccrualProfileId,
                SortOrder,
                TenantId,
                CreatedBy,
                DateCreated
            )
            SELECT
                @Id,
                ins.AccrualProfileId,
                ins.SortOrder,
                @TenantId,
                @UserId,
                SYSUTCDATETIME()
            FROM #IncomingProfiles ins
            WHERE (ins.Id IS NULL OR ins.Id = 0)
               OR (ins.Id IS NOT NULL AND ins.Id > 0 AND NOT EXISTS (
                   SELECT 1 
                   FROM AccrualTrackProfiles atp 
                   WHERE atp.Id = ins.Id 
                     AND atp.AccrualTrackId = @Id
                     AND atp.TenantId = @TenantId
               ));

            -- Delete profiles that existed BEFORE but are not in incoming list
            DELETE FROM AccrualTrackProfiles
            WHERE AccrualTrackId = @Id
              AND TenantId = @TenantId
              AND Id IN (SELECT Id FROM #ExistingProfileIds)
              AND Id NOT IN (
                  SELECT Id 
                  FROM #IncomingProfiles 
                  WHERE Id IS NOT NULL 
                    AND Id > 0
              );
            
            -- Drop temporary table for existing IDs
            DROP TABLE #ExistingProfileIds;

            -- Drop temporary table
            DROP TABLE #IncomingProfiles;
        END
        ELSE
        BEGIN
            -- If no profiles found in JSON, check if profiles array exists and is empty
            DECLARE @ProfilesJson NVARCHAR(MAX) = JSON_QUERY(@Json, '$.profiles');
            IF @ProfilesJson IS NOT NULL AND @ProfilesJson = '[]'
            BEGIN
                -- If profiles array is explicitly empty, delete all existing profiles
                DELETE FROM AccrualTrackProfiles 
                WHERE AccrualTrackId = @Id 
                  AND TenantId = @TenantId;
            END
            -- If profiles property doesn't exist in JSON, don't modify existing profiles
        END

        SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual track saved successfully.' AS message
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

