USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualProfiles_Save]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Insert/Update Accrual Profiles
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualProfiles_Save]
    @Json VARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @ProfileName VARCHAR(255);
        DECLARE @IsBaseOnYearsServed BIT;
        DECLARE @FromYears DECIMAL(10, 2);
        DECLARE @ToYears DECIMAL(10, 2);
        DECLARE @Description NVARCHAR(MAX);

        SELECT
            @Id = id,
            @ProfileName = profileName,
            @IsBaseOnYearsServed = ISNULL(isBaseOnYearsServed, 0),
            @FromYears = fromYears,
            @ToYears = toYears,
            @Description = description
        FROM OPENJSON(@Json) WITH (
            id INT,
            profileName VARCHAR(255),
            isBaseOnYearsServed BIT,
            fromYears DECIMAL(10, 2),
            toYears DECIMAL(10, 2),
            description NVARCHAR(MAX)
        );

        IF (@ProfileName IS NULL OR LTRIM(RTRIM(@ProfileName)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Profile Name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM AccrualProfiles
            WHERE TenantId = @TenantId
              AND ProfileName = @ProfileName
              AND Id <> ISNULL(@Id, 0)
        )
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Profile Name already exists for this tenant.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM AccrualProfiles WHERE Id = ISNULL(@Id, 0) AND TenantId = @TenantId)
        BEGIN
            UPDATE AccrualProfiles
            SET
                ProfileName = @ProfileName,
                IsBaseOnYearsServed = @IsBaseOnYearsServed,
                FromYears = @FromYears,
                ToYears = @ToYears,
                Description = @Description,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            WHERE Id = @Id AND TenantId = @TenantId;

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual profile updated successfully.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        END
        ELSE
        BEGIN
            INSERT INTO AccrualProfiles (
                TenantId,
                ProfileName,
                IsBaseOnYearsServed,
                FromYears,
                ToYears,
                Description,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @ProfileName,
                @IsBaseOnYearsServed,
                @FromYears,
                @ToYears,
                @Description,
                @UserId,
                SYSUTCDATETIME()
            );

            SET @Id = SCOPE_IDENTITY();

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual profile created successfully.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        END

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

