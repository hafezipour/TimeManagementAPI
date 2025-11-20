USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualBanks_CheckAndCreate]    Script Date: 11/19/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/19/2025
-- Description: Check and create AccrualBanks records in bulk
--              Takes JSON array of bank records, checks if they exist, creates missing ones
--              Returns array of bank records with their IDs (existing or newly created)
-- =============================================
CREATE PROCEDURE [dbo].[usp_AccrualBanks_CheckAndCreate]
    @Json NVARCHAR(MAX),
    @CreatedBy INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON input
        DECLARE @Banks TABLE (
            TempId INT IDENTITY(1,1),
            UserId INT,
            AccrualProfileId INT,
            AccrualTrackId INT NULL,
            AccrualTypeId INT,
            AccrualRuleId INT,
            AccrualRulesSlotId INT,
            BankId INT NULL,
            IsNew BIT DEFAULT 0
        );

        -- Insert parsed JSON data into temp table
        INSERT INTO @Banks (UserId, AccrualProfileId, AccrualTrackId, AccrualTypeId, AccrualRuleId, AccrualRulesSlotId)
        SELECT 
            UserId,
            AccrualProfileId,
            AccrualTrackId,
            AccrualTypeId,
            AccrualRuleId,
            AccrualRulesSlotId
        FROM OPENJSON(@Json)
        WITH (
            UserId INT '$.userId',
            AccrualProfileId INT '$.accrualProfileId',
            AccrualTrackId INT '$.accrualTrackId',
            AccrualTypeId INT '$.accrualTypeId',
            AccrualRuleId INT '$.accrualRuleId',
            AccrualRulesSlotId INT '$.accrualRulesSlotId'
        );

        -- Check which banks already exist
        UPDATE b
        SET b.BankId = ab.Id
        FROM @Banks b
        INNER JOIN [dbo].[AccrualBanks] ab ON b.UserId = ab.UserId
            AND b.AccrualRulesSlotId = ab.AccrualRulesSlotId
            AND b.AccrualProfileId = ab.AccrualProfileId
            AND ab.TenantId = @TenantId;

        -- Create missing banks
        INSERT INTO [dbo].[AccrualBanks] (
            TenantId,
            UserId,
            AccrualProfileId,
            AccrualTrackId,
            AccrualTypeId,
            AccrualRuleId,
            AccrualRulesSlotId,
            CurrentBalance,
            UsedBalance,
            DateCreated,
            CreatedBy
        )
        SELECT 
            @TenantId,
            b.UserId,
            b.AccrualProfileId,
            b.AccrualTrackId,
            b.AccrualTypeId,
            b.AccrualRuleId,
            b.AccrualRulesSlotId,
            0.00,
            0.00,
            GETUTCDATE(),
            @CreatedBy
        FROM @Banks b
        WHERE b.BankId IS NULL;

        -- Update temp table with newly created bank IDs (get from SCOPE_IDENTITY)
        DECLARE @NewBankIds TABLE (
            TempId INT,
            BankId INT
        );

        -- Get newly created bank IDs by matching on unique combination
        INSERT INTO @NewBankIds (TempId, BankId)
        SELECT b.TempId, ab.Id
        FROM @Banks b
        INNER JOIN [dbo].[AccrualBanks] ab ON b.UserId = ab.UserId
            AND b.AccrualRulesSlotId = ab.AccrualRulesSlotId
            AND b.AccrualProfileId = ab.AccrualProfileId
            AND ab.TenantId = @TenantId
            AND ab.DateCreated >= DATEADD(SECOND, -5, GETUTCDATE())
        WHERE b.BankId IS NULL;

        -- Update temp table with new bank IDs
        UPDATE b
        SET b.BankId = nbi.BankId,
            b.IsNew = 1
        FROM @Banks b
        INNER JOIN @NewBankIds nbi ON b.TempId = nbi.TempId
        WHERE b.BankId IS NULL;

        COMMIT TRANSACTION;

        -- Return results
        SELECT 
            b.UserId AS userId,
            b.AccrualProfileId AS accrualProfileId,
            b.AccrualTrackId AS accrualTrackId,
            b.AccrualTypeId AS accrualTypeId,
            b.AccrualRuleId AS accrualRuleId,
            b.AccrualRulesSlotId AS accrualRulesSlotId,
            b.BankId AS bankId,
            b.IsNew AS isNew,
            ISNULL(ab.CurrentBalance, 0.00) AS currentBalance
        FROM @Banks b
        LEFT JOIN [dbo].[AccrualBanks] ab ON b.BankId = ab.Id
        ORDER BY b.TempId
        FOR JSON PATH, INCLUDE_NULL_VALUES;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            'false' AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

