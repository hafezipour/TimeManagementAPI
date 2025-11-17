USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualRules_Save]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Insert/Update Accrual Rules
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualRules_Save]
    @Json VARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @AccrualProfileId INT;
        DECLARE @AccrualTypeId INT;
        DECLARE @DeductionMultiplier DECIMAL(10, 2);
        DECLARE @IsStopAccruingEnabled BIT;
        DECLARE @StopAccruingAfterReaching DECIMAL(10, 2);

        -- Parse main rule data
        SELECT
            @Id = id,
            @AccrualProfileId = accrualProfileId,
            @AccrualTypeId = accrualTypeId,
            @DeductionMultiplier = ISNULL(deductionMultiplier, 1.00),
            @IsStopAccruingEnabled = ISNULL(isStopAccruingEnabled, 0),
            @StopAccruingAfterReaching = stopAccruingAfterReaching
        FROM OPENJSON(@Json) WITH (
            id INT,
            accrualProfileId INT,
            accrualTypeId INT,
            deductionMultiplier DECIMAL(10, 2),
            isStopAccruingEnabled BIT,
            stopAccruingAfterReaching DECIMAL(10, 2)
        );

        -- Validation
        IF (@AccrualProfileId IS NULL OR @AccrualProfileId <= 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Profile Id is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@AccrualTypeId IS NULL OR @AccrualTypeId <= 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Type Id is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if profile and type exist and belong to tenant
        IF NOT EXISTS (SELECT 1 FROM AccrualProfiles WHERE Id = @AccrualProfileId AND TenantId = @TenantId)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Profile not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM AccrualTypes WHERE Id = @AccrualTypeId AND TenantId = @TenantId)
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Accrual Type not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check for duplicate (same profile + type combination)
        IF EXISTS (
            SELECT 1
            FROM AccrualRules
            WHERE AccrualProfileId = @AccrualProfileId
              AND AccrualTypeId = @AccrualTypeId
              AND TenantId = @TenantId
              AND Id <> ISNULL(@Id, 0)
        )
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'An accrual rule already exists for this profile and type combination.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update or Insert main rule
        IF EXISTS (SELECT 1 FROM AccrualRules WHERE Id = ISNULL(@Id, 0) AND TenantId = @TenantId)
        BEGIN
            UPDATE AccrualRules
            SET
                DeductionMultiplier = @DeductionMultiplier,
                IsStopAccruingEnabled = @IsStopAccruingEnabled,
                StopAccruingAfterReaching = @StopAccruingAfterReaching,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            WHERE Id = @Id AND TenantId = @TenantId;

            -- Delete existing slots
            DELETE FROM AccrualRulesSlots WHERE AccrualRuleId = @Id;
        END
        ELSE
        BEGIN
            INSERT INTO AccrualRules (
                TenantId,
                AccrualProfileId,
                AccrualTypeId,
                DeductionMultiplier,
                IsStopAccruingEnabled,
                StopAccruingAfterReaching,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @AccrualProfileId,
                @AccrualTypeId,
                @DeductionMultiplier,
                @IsStopAccruingEnabled,
                @StopAccruingAfterReaching,
                @UserId,
                SYSUTCDATETIME()
            );

            SET @Id = SCOPE_IDENTITY();
        END

        -- Insert slots
        DECLARE @SlotsJson NVARCHAR(MAX);
        SELECT @SlotsJson = slots FROM OPENJSON(@Json) WITH (slots NVARCHAR(MAX) AS JSON);

        IF @SlotsJson IS NOT NULL
        BEGIN
            INSERT INTO AccrualRulesSlots (
                AccrualRuleId,
                AccrueAmount,
                AccrueUnit,
                AccrueFrequency,
                SortOrder,
                CreatedBy,
                DateCreated
            )
            SELECT
                @Id,
                accrueAmount,
                accrueUnit,
                accrueFrequency,
                ISNULL(sortOrder, 0),
                @UserId,
                SYSUTCDATETIME()
            FROM OPENJSON(@SlotsJson) WITH (
                accrueAmount DECIMAL(10, 2),
                accrueUnit VARCHAR(50),
                accrueFrequency VARCHAR(50),
                sortOrder INT
            );
        END

        SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual rule saved successfully.' AS message
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

