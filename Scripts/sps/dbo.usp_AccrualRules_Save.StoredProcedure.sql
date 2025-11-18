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
    @Json NVARCHAR(MAX),
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

        -- Process slots: Insert, Update, and Delete
        DECLARE @SlotsJson NVARCHAR(MAX);
        
        -- Extract slots array from JSON using JSON_QUERY
        SET @SlotsJson = JSON_QUERY(@Json, '$.slots');

        -- Process slots if they exist and are valid JSON
        IF @SlotsJson IS NOT NULL AND @SlotsJson <> 'null' AND LEN(@SlotsJson) > 0 AND ISJSON(@SlotsJson) = 1
        BEGIN
            -- Create temporary table to hold incoming slots
            CREATE TABLE #IncomingSlots (
                Id INT NULL,
                AccrueAmount DECIMAL(10, 2),
                AccrueUnit VARCHAR(50),
                AccrueFrequency VARCHAR(50),
                SortOrder INT
            );

            -- Populate temporary table with incoming slots
            INSERT INTO #IncomingSlots (Id, AccrueAmount, AccrueUnit, AccrueFrequency, SortOrder)
            SELECT
                id,
                accrueAmount,
                accrueUnit,
                accrueFrequency,
                ISNULL(sortOrder, 0)
            FROM OPENJSON(@SlotsJson) WITH (
                id INT,
                accrueAmount DECIMAL(10, 2),
                accrueUnit VARCHAR(50),
                accrueFrequency VARCHAR(50),
                sortOrder INT
            );

            -- Update existing slots (those with id > 0 that exist in database)
            UPDATE ars
            SET
                AccrueAmount = ins.AccrueAmount,
                AccrueUnit = ins.AccrueUnit,
                AccrueFrequency = ins.AccrueFrequency,
                SortOrder = ins.SortOrder,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            FROM AccrualRulesSlots ars
            INNER JOIN #IncomingSlots ins ON ars.Id = ins.Id
            WHERE ars.AccrualRuleId = @Id
              AND ins.Id IS NOT NULL
              AND ins.Id > 0;

            -- Insert new slots (those without id or id is null/0, or id not found in existing)
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
                ins.AccrueAmount,
                ins.AccrueUnit,
                ins.AccrueFrequency,
                ins.SortOrder,
                @UserId,
                SYSUTCDATETIME()
            FROM #IncomingSlots ins
            WHERE (ins.Id IS NULL OR ins.Id = 0)
               OR (ins.Id IS NOT NULL AND ins.Id > 0 AND NOT EXISTS (
                   SELECT 1 
                   FROM AccrualRulesSlots ars 
                   WHERE ars.Id = ins.Id 
                     AND ars.AccrualRuleId = @Id
               ));

            -- Delete slots that exist in DB but not in incoming list
            DELETE FROM AccrualRulesSlots
            WHERE AccrualRuleId = @Id
              AND Id NOT IN (
                  SELECT Id 
                  FROM #IncomingSlots 
                  WHERE Id IS NOT NULL 
                    AND Id > 0
              )
              AND Id IS NOT NULL;

            -- Drop temporary table
            DROP TABLE #IncomingSlots;
        END
        ELSE
        BEGIN
            -- If no slots provided, delete all existing slots
            DELETE FROM AccrualRulesSlots WHERE AccrualRuleId = @Id;
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

