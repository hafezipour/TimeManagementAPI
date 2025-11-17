USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_Save]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Insert/Update Accrual Types
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_Save]
    @Json VARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @TypeCode VARCHAR(55);
        DECLARE @TypeName VARCHAR(255);
        DECLARE @Description NVARCHAR(MAX);
        DECLARE @CustomTableUnitId INT;
        DECLARE @IsActive BIT;

        SELECT
            @Id = id,
            @TypeCode = typeCode,
            @TypeName = typeName,
            @Description = description,
            @CustomTableUnitId = customTableUnitId,
            @IsActive = ISNULL(isActive, 1)
        FROM OPENJSON(@Json) WITH (
            id INT,
            typeCode VARCHAR(55),
            typeName VARCHAR(255),
            description NVARCHAR(MAX),
            customTableUnitId INT,
            isActive BIT
        );

        IF (@TypeCode IS NULL OR LTRIM(RTRIM(@TypeCode)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Code is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@TypeName IS NULL OR LTRIM(RTRIM(@TypeName)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM AccrualTypes
            WHERE TenantId = @TenantId
              AND TypeCode = @TypeCode
              AND Id <> ISNULL(@Id, 0)
        )
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Code already exists for this tenant.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM AccrualTypes WHERE Id = ISNULL(@Id, 0) AND TenantId = @TenantId)
        BEGIN
            UPDATE AccrualTypes
            SET
                TypeCode = @TypeCode,
                TypeName = @TypeName,
                Description = @Description,
                CustomTableUnitId = @CustomTableUnitId,
                IsActive = @IsActive,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            WHERE Id = @Id AND TenantId = @TenantId;

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual type updated successfully.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        END
        ELSE
        BEGIN
            INSERT INTO AccrualTypes (
                TenantId,
                TypeCode,
                TypeName,
                Description,
                CustomTableUnitId,
                IsActive,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @TypeCode,
                @TypeName,
                @Description,
                @CustomTableUnitId,
                @IsActive,
                @UserId,
                SYSUTCDATETIME()
            );

            SET @Id = SCOPE_IDENTITY();

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual type created successfully.' AS message
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



