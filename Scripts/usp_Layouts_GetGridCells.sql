CREATE OR ALTER PROCEDURE [dbo].[usp_Layouts_GetGridCells]
    @LayoutId INT,
    @TenantId INT
AS
BEGIN
        -- Get grid cells data grouped by RowNumber and ColumnNumber
        SELECT 
            lg.rowNumber,
            lg.columnNumber,
            lg.columnId,
            lg.displayOrder,
            c.columnName,
            c.backgroundColor
        FROM LayoutGridColumns lg
        LEFT JOIN Columns c ON lg.ColumnId = c.Id AND c.TenantId = @TenantId
        WHERE lg.LayoutId = @LayoutId 
          AND lg.TenantId = @TenantId
        ORDER BY lg.RowNumber, lg.ColumnNumber, lg.DisplayOrder
        FOR JSON PATH, INCLUDE_NULL_VALUES

END
