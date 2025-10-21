USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_Layouts_SaveRowsColumns]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Save Layout Rows and Columns
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_Layouts_SaveRowsColumns]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        DECLARE @LayoutId INT = NULL
        DECLARE @Rows INT = NULL
        DECLARE @Columns INT = NULL

        -- Parse JSON parameters
        SELECT 
            @LayoutId = JSON_VALUE(@Json, '$.layoutId'),
            @Rows = JSON_VALUE(@Json, '$.rows'),
            @Columns = JSON_VALUE(@Json, '$.columns')

        -- Validate required parameters
        IF @LayoutId IS NULL
        BEGIN
            SELECT '{"success": false, "message": "LayoutId is required"}' as Result
            RETURN
        END

        -- Update existing layout with rows and columns
        UPDATE [dbo].[Layouts]
        SET 
            [UpdatedBy] = @UserId,
            [DateUpdated] = GETUTCDATE(),
            [Rows] = @Rows,
            [Columns] = @Columns
        WHERE [Id] = @LayoutId 
        AND [TenantId] = @TenantId

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT '{"success": false, "message": "Layout not found or access denied"}' as Result
            RETURN
        END

        SELECT '{"success": true, "message": "Layout rows and columns updated successfully", "layoutId": ' + CAST(@LayoutId AS NVARCHAR(10)) + '}' as Result

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
