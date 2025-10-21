USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_Columns_GetById]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get column by ID
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_Columns_GetById]
    @Id INT,
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

        -- Get column by ID and tenant
        SELECT 
            [Id] as [id],
            [ColumnName] as [columnName],
            [BackgroundColor] as [backgroundColor],
            [TenantId] as [tenantId],
            [CreatedBy] as [createdBy],
            [UpdatedBy] as [updatedBy],
            [DateCreated] as [dateCreated],
            [DateUpdated] as [dateUpdated]
        FROM [dbo].[Columns]
        WHERE [Id] = @Id AND [TenantId] = @TenantId

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
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
