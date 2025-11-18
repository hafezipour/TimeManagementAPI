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
        -- Create temporary table to hold incoming slots
        CREATE TABLE #IncomingSlots (
            Id INT NULL,
            AccrueAmount DECIMAL(10, 2),
            AccrueUnit VARCHAR(50),
            AccrueFrequency VARCHAR(50),
            AccrueFrequencyValue INT NULL,
            SortOrder INT
        );

        -- Extract and populate slots directly from JSON using OPENJSON
        INSERT INTO #IncomingSlots (Id, AccrueAmount, AccrueUnit, AccrueFrequency, AccrueFrequencyValue, SortOrder)
        SELECT
            CASE WHEN id IS NULL THEN NULL ELSE id END AS id,
            accrueAmount,
            accrueUnit,
            accrueFrequency,
            accrueFrequencyValue,
            ISNULL(sortOrder, 0) AS sortOrder
        FROM OPENJSON(@Json, '$.slots') WITH (
            id INT,
            accrueAmount DECIMAL(10, 2),
            accrueUnit VARCHAR(50),
            accrueFrequency VARCHAR(50),
            accrueFrequencyValue INT,
            sortOrder INT
        );

        -- Process slots if any were found
        IF EXISTS (SELECT 1 FROM #IncomingSlots)
        BEGIN
            -- Capture existing slot IDs BEFORE we insert new ones
            CREATE TABLE #ExistingSlotIds (
                Id INT PRIMARY KEY
            );
            
            INSERT INTO #ExistingSlotIds (Id)
            SELECT Id 
            FROM AccrualRulesSlots 
            WHERE AccrualRuleId = @Id 
              AND Id IS NOT NULL 
              AND Id > 0;

            -- Update existing slots (those with id > 0 that exist in database)
            UPDATE ars
            SET
                AccrueAmount = ins.AccrueAmount,
                AccrueUnit = ins.AccrueUnit,
                AccrueFrequency = ins.AccrueFrequency,
                AccrueFrequencyValue = ins.AccrueFrequencyValue,
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
                AccrueFrequencyValue,
                SortOrder,
                CreatedBy,
                DateCreated
            )
            SELECT
                @Id,
                ins.AccrueAmount,
                ins.AccrueUnit,
                ins.AccrueFrequency,
                ins.AccrueFrequencyValue,
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

            -- Delete slots that existed BEFORE but are not in incoming list
            -- Only delete slots that were in the database before we started (captured in #ExistingSlotIds)
            DELETE FROM AccrualRulesSlots
            WHERE AccrualRuleId = @Id
              AND Id IN (SELECT Id FROM #ExistingSlotIds)
              AND Id NOT IN (
                  SELECT Id 
                  FROM #IncomingSlots 
                  WHERE Id IS NOT NULL 
                    AND Id > 0
              );
            
            -- Drop temporary table for existing IDs
            DROP TABLE #ExistingSlotIds;

            -- Drop temporary table
            DROP TABLE #IncomingSlots;
        END
        ELSE
        BEGIN
            -- If no slots found in JSON, check if slots array exists and is empty
            DECLARE @SlotsJson NVARCHAR(MAX) = JSON_QUERY(@Json, '$.slots');
            IF @SlotsJson IS NOT NULL AND @SlotsJson = '[]'
            BEGIN
                -- If slots array is explicitly empty, delete all existing slots
                DELETE FROM AccrualRulesSlots WHERE AccrualRuleId = @Id;
            END
            -- If slots property doesn't exist in JSON, don't modify existing slots
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

