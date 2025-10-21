USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_Columns_Save]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Save Column (Insert/Update)
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_Columns_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        DECLARE @Id INT = NULL
        DECLARE @ColumnName NVARCHAR(50) = NULL
        DECLARE @BackgroundColor NVARCHAR(7) = NULL

        -- Parse JSON parameters
        SELECT 
            @Id = JSON_VALUE(@Json, '$.id'),
            @ColumnName = JSON_VALUE(@Json, '$.columnName'),
            @BackgroundColor = JSON_VALUE(@Json, '$.backgroundColor')

        -- Validate required parameters
        IF @ColumnName IS NULL OR LEN(TRIM(@ColumnName)) = 0
        BEGIN
            SELECT '{"success": false, "message": "ColumnName is required"}' as Result
            RETURN
        END

        -- Check if this is an update (Id provided) or insert (Id is null)
        IF @Id IS NOT NULL
        BEGIN
            -- Update existing column
            UPDATE [dbo].[Columns]
            SET 
                [ColumnName] = @ColumnName,
                [BackgroundColor] = @BackgroundColor,
                [UpdatedBy] = @UserId,
                [DateUpdated] = GETUTCDATE()
            WHERE [Id] = @Id 
            AND [TenantId] = @TenantId

            IF @@ROWCOUNT = 0
            BEGIN
                SELECT '{"success": false, "message": "Column not found or access denied"}' as Result
                RETURN
            END

            SELECT '{"success": true, "message": "Column updated successfully", "id": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result
        END
        ELSE
        BEGIN
            -- Insert new column
            INSERT INTO [dbo].[Columns] (
                [ColumnName],
                [BackgroundColor],
                [TenantId],
                [CreatedBy],
                [DateCreated],
                [UpdatedBy],
                [DateUpdated]
            )
            VALUES (
                @ColumnName,
                @BackgroundColor,
                @TenantId,
                @UserId,
                GETUTCDATE(),
                NULL,
                NULL
            )

            SET @Id = SCOPE_IDENTITY()

            SELECT '{"success": true, "message": "Column created successfully", "id": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result
        END

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO
