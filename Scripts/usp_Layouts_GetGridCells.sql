CREATE PROCEDURE [dbo].[usp_Layouts_GetGridCells]
    @LayoutId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate LayoutId
        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT 'Error' AS Status, 'Invalid LayoutId' AS Message;
            RETURN;
        END
        
        -- Get grid cells data grouped by RowNumber and ColumnNumber
        SELECT 
            lg.RowNumber,
            lg.ColumnNumber,
            lg.ColumnId,
            lg.DisplayOrder,
            c.ColumnName,
            c.BackgroundColor
        FROM LayoutGridColumns lg
        LEFT JOIN Columns c ON lg.ColumnId = c.Id AND c.TenantId = @TenantId
        WHERE lg.LayoutId = @LayoutId 
          AND lg.TenantId = @TenantId
        ORDER BY lg.RowNumber, lg.ColumnNumber, lg.DisplayOrder;
        
    END TRY
    BEGIN CATCH
        -- Return error information
        SELECT 
            'Error' AS Status,
            'Error retrieving grid cells: ' + ERROR_MESSAGE() AS Message;
        
        -- Log error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
