USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_Layouts_GetShortList]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get short list of layouts for a tenant
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_Layouts_GetShortList]
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameter
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Get layouts for the tenant
        SELECT 
            [Id] as [id],
            [TenantId] as [tenantId],
            [LayoutName] as [layoutName],
            [Type] as [type],
            [Description] as [description],
            [Rows] as [rows],
            [Columns] as [columns],
            [CreatedBy] as [createdBy],
            [UpdatedBy] as [updatedBy],
            [DateCreated] as [dateCreated],
            [DateUpdated] as [dateUpdated]
        FROM [dbo].[Layouts]
        WHERE [TenantId] = @TenantId
        ORDER BY [Type], [LayoutName]

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
