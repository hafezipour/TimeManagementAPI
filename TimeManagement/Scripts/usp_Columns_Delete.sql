USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_Columns_Delete]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Delete Column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_Columns_Delete]
    @Id INT,
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Id IS NULL OR @Id <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid Id parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Check if column exists and belongs to tenant
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE [Id] = @Id AND [TenantId] = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found or access denied"}' as Result
            RETURN
        END

        -- Check if column is being used in LayoutGridColumns
        IF EXISTS (SELECT 1 FROM [dbo].[LayoutGridColumns] WHERE [ColumnId] = @Id AND [TenantId] = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Cannot delete column as it is being used in layout grid"}' as Result
            RETURN
        END

        -- Delete the column
        DELETE FROM [dbo].[Columns]
        WHERE [Id] = @Id 
        AND [TenantId] = @TenantId

        SELECT '{"success": true, "message": "Column deleted successfully", "deletedId": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result

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
