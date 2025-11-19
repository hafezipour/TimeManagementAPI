USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAccrualSettings_Save]    Script Date: 11/19/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/19/2025
-- Description: Insert/Update Employee Accrual Settings
-- =============================================
ALTER PROCEDURE [dbo].[usp_EmployeeAccrualSettings_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @EmployeeUserId INT;
        DECLARE @AccrualTrackId INT;
        DECLARE @AccrualProfileId INT;
        DECLARE @AccrualStartDate DATE;

        -- Parse JSON data
        SELECT 
            @Id = id,
            @EmployeeUserId = userId,
            @AccrualTrackId = accrualTrackId,
            @AccrualProfileId = accrualProfileId,
            @AccrualStartDate = accrualStartDate
        FROM OPENJSON(@Json) WITH (
            id INT,
            userId INT,
            accrualTrackId INT,
            accrualProfileId INT,
            accrualStartDate DATE
        );

        -- Validation
        IF (@EmployeeUserId IS NULL OR @EmployeeUserId <= 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'User Id is required.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@AccrualStartDate IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Start Date is required.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@AccrualTrackId IS NULL AND @AccrualProfileId IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Either Accrual Track or Accrual Profile must be selected.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validation: Cannot have both Track and Profile at the same time
        IF (@AccrualTrackId IS NOT NULL AND @AccrualTrackId > 0 AND @AccrualProfileId IS NOT NULL AND @AccrualProfileId > 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Cannot select both Accrual Track and Accrual Profile. Please select only one.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate AccrualTrackId if provided
        IF (@AccrualTrackId IS NOT NULL AND @AccrualTrackId > 0)
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM AccrualTracks WHERE Id = @AccrualTrackId AND TenantId = @TenantId)
            BEGIN
                SELECT CAST(0 AS BIT) AS success, 'Accrual Track not found.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Validate AccrualProfileId if provided
        IF (@AccrualProfileId IS NOT NULL AND @AccrualProfileId > 0)
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM AccrualProfiles WHERE Id = @AccrualProfileId AND TenantId = @TenantId)
            BEGIN
                SELECT CAST(0 AS BIT) AS success, 'Accrual Profile not found.' AS message FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Step 1: Deactivate ALL existing active settings for this user (both tracks and profiles)
        -- Only one can be active at a time - either a track OR a profile, not both
        UPDATE [dbo].[EmployeeAccrualSettings]
        SET IsActive = 0,
            UpdatedBy = @UserId,
            DateUpdated = SYSUTCDATETIME()
        WHERE UserId = @EmployeeUserId
            AND TenantId = @TenantId
            AND IsActive = 1;

        -- Step 2: Determine if we're saving a Track or Profile, and find/update or insert accordingly
        -- Reset @Id to check for existing records based on TrackId or ProfileId
        SET @Id = NULL;

        IF (@AccrualTrackId IS NOT NULL AND @AccrualTrackId > 0)
        BEGIN
            -- Saving/Updating an Accrual Track
            -- Check if a record with this AccrualTrackId already exists for this user
            SELECT @Id = Id
            FROM [dbo].[EmployeeAccrualSettings]
            WHERE UserId = @EmployeeUserId
                AND TenantId = @TenantId
                AND AccrualTrackId = @AccrualTrackId
                AND AccrualProfileId IS NULL;

            IF (@Id IS NOT NULL AND @Id > 0)
            BEGIN
                -- Update existing track record
                UPDATE [dbo].[EmployeeAccrualSettings]
                SET AccrualStartDate = @AccrualStartDate,
                    IsActive = 1,
                    UpdatedBy = @UserId,
                    DateUpdated = SYSUTCDATETIME()
                WHERE Id = @Id
                    AND TenantId = @TenantId;
            END
            ELSE
            BEGIN
                -- Insert new track record
                INSERT INTO [dbo].[EmployeeAccrualSettings] (
                    UserId,
                    AccrualTrackId,
                    AccrualProfileId,
                    AccrualStartDate,
                    IsActive,
                    TenantId,
                    CreatedBy,
                    DateCreated
                )
                VALUES (
                    @EmployeeUserId,
                    @AccrualTrackId,
                    NULL,  -- Profile must be NULL when saving a track
                    @AccrualStartDate,
                    1,  -- New record is always active
                    @TenantId,
                    @UserId,
                    SYSUTCDATETIME()
                );

                SET @Id = SCOPE_IDENTITY();
            END
        END
        ELSE IF (@AccrualProfileId IS NOT NULL AND @AccrualProfileId > 0)
        BEGIN
            -- Saving/Updating an Accrual Profile
            -- Reset @Id to check for existing profile record
            SET @Id = NULL;
            
            -- Check if a record with this AccrualProfileId already exists for this user
            SELECT @Id = Id
            FROM [dbo].[EmployeeAccrualSettings]
            WHERE UserId = @EmployeeUserId
                AND TenantId = @TenantId
                AND AccrualProfileId = @AccrualProfileId
                AND AccrualTrackId IS NULL;

            IF (@Id IS NOT NULL AND @Id > 0)
            BEGIN
                -- Update existing profile record
                UPDATE [dbo].[EmployeeAccrualSettings]
                SET AccrualStartDate = @AccrualStartDate,
                    IsActive = 1,
                    UpdatedBy = @UserId,
                    DateUpdated = SYSUTCDATETIME()
                WHERE Id = @Id
                    AND TenantId = @TenantId;
            END
            ELSE
            BEGIN
                -- Insert new profile record
                INSERT INTO [dbo].[EmployeeAccrualSettings] (
                    UserId,
                    AccrualTrackId,
                    AccrualProfileId,
                    AccrualStartDate,
                    IsActive,
                    TenantId,
                    CreatedBy,
                    DateCreated
                )
                VALUES (
                    @EmployeeUserId,
                    NULL,  -- Track must be NULL when saving a profile
                    @AccrualProfileId,
                    @AccrualStartDate,
                    1,  -- New record is always active
                    @TenantId,
                    @UserId,
                    SYSUTCDATETIME()
                );

                SET @Id = SCOPE_IDENTITY();
            END
        END

        SELECT 
            @Id AS id,
            CAST(1 AS BIT) AS success,
            'Employee accrual settings saved successfully.' AS message
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

