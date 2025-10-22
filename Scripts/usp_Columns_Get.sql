USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Columns_Get]    Script Date: 10/22/2025 2:52:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get all columns for a tenant that are NOT already assigned to a specific layout
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
ALTER   PROCEDURE [dbo].[usp_Columns_Get]
    @TenantId INT,
    @LayoutId INT = NULL
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

        -- Get columns for the tenant with their grid cell assignments
        SELECT 
            c.[Id] as [id],
            c.[ColumnName] as [columnName],
            c.[BackgroundColor] as [backgroundColor],
            c.[TenantId] as [tenantId],
            c.[CreatedBy] as [createdBy],
            c.[UpdatedBy] as [updatedBy],
            c.[DateCreated] as [dateCreated],
            c.[DateUpdated] as [dateUpdated],
            (
                SELECT 
                    lg.RowNumber as [rowNumber],
                    lg.ColumnNumber as [columnNumber],
                    lg.DisplayOrder as [displayOrder]
                FROM [dbo].[LayoutGridColumns] lg
                WHERE lg.ColumnId = c.Id
                  AND lg.TenantId = @TenantId
                  AND (@LayoutId IS NULL OR lg.LayoutId = @LayoutId)
                ORDER BY lg.RowNumber, lg.ColumnNumber, lg.DisplayOrder
                FOR JSON PATH
            ) as [gridColumns]
        FROM [dbo].[Columns] c
        WHERE c.[TenantId] = @TenantId
          AND (@LayoutId IS NULL OR c.Id NOT IN (
              SELECT DISTINCT lg.ColumnId 
              FROM [dbo].[LayoutGridColumns] lg 
              WHERE lg.LayoutId = @LayoutId 
                AND lg.TenantId = @TenantId
          ))
        ORDER BY c.[ColumnName]
		FOR JSON PATH, INCLUDE_NULL_VALUES

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
