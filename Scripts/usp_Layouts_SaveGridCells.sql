CREATE PROCEDURE [dbo].[usp_Layouts_SaveGridCells]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse JSON data
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId');
        
        -- Validate LayoutId
        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'Error' AS Status, 'Invalid LayoutId' AS Message;
            RETURN;
        END
        
        -- Create temporary table to hold the parsed JSON data
        CREATE TABLE #TempGridCells (
            RowNumber INT,
            ColumnNumber INT,
            ColumnId INT,
            ColumnName NVARCHAR(255),
            BackgroundColor NVARCHAR(50),
            DisplayOrder INT
        );
        
        -- Parse JSON and insert into temp table
        INSERT INTO #TempGridCells (RowNumber, ColumnNumber, ColumnId, ColumnName, BackgroundColor, DisplayOrder)
        SELECT 
            JSON_VALUE(gridCells.value, '$.rowNumber') AS RowNumber,
            JSON_VALUE(gridCells.value, '$.columnNumber') AS ColumnNumber,
            JSON_VALUE(col.value, '$.id') AS ColumnId,
            JSON_VALUE(col.value, '$.columnName') AS ColumnName,
            JSON_VALUE(col.value, '$.backgroundColor') AS BackgroundColor,
            JSON_VALUE(col.value, '$.displayOrder') AS DisplayOrder
        FROM OPENJSON(@Json, '$.gridCells') AS gridCells
        CROSS APPLY OPENJSON(gridCells.value, '$.columns') AS col
        WHERE JSON_VALUE(gridCells.value, '$.rowNumber') IS NOT NULL
          AND JSON_VALUE(gridCells.value, '$.columnNumber') IS NOT NULL
          AND JSON_VALUE(col.value, '$.id') IS NOT NULL;
        
        -- Step 1: DELETE records that exist in table but NOT in JSON
        -- Delete records where RowNumber + ColumnNumber + LayoutId match but ColumnId is not in the JSON
        DELETE FROM LayoutGridColumns 
        WHERE LayoutId = @LayoutId 
          AND TenantId = @TenantId
          AND EXISTS (
              SELECT 1 FROM LayoutGridColumns lg 
              WHERE lg.LayoutId = @LayoutId 
                AND lg.TenantId = @TenantId
                AND lg.RowNumber = LayoutGridColumns.RowNumber
                AND lg.ColumnNumber = LayoutGridColumns.ColumnNumber
                AND lg.ColumnId = LayoutGridColumns.ColumnId
          )
          AND NOT EXISTS (
              SELECT 1 FROM #TempGridCells t 
              WHERE t.RowNumber = LayoutGridColumns.RowNumber
                AND t.ColumnNumber = LayoutGridColumns.ColumnNumber
                AND t.ColumnId = LayoutGridColumns.ColumnId
          );
        
        -- Step 2: INSERT records that exist in JSON but NOT in table
        INSERT INTO LayoutGridColumns (
            ColumnId,
            RowNumber,
            ColumnNumber,
            LayoutId,
            DisplayOrder,
            TenantId,
            CreatedBy,
            UpdatedBy,
            DateCreated,
            DateUpdated
        )
        SELECT 
            t.ColumnId,
            t.RowNumber,
            t.ColumnNumber,
            @LayoutId,
            t.DisplayOrder,
            @TenantId,
            @UserId,
            @UserId,
            GETUTCDATE(),
            GETUTCDATE()
        FROM #TempGridCells t
        WHERE NOT EXISTS (
            SELECT 1 FROM LayoutGridColumns lg 
            WHERE lg.LayoutId = @LayoutId 
              AND lg.TenantId = @TenantId
              AND lg.RowNumber = t.RowNumber
              AND lg.ColumnNumber = t.ColumnNumber
              AND lg.ColumnId = t.ColumnId
        );
        
        -- Step 3: UPDATE DisplayOrder for existing records that might have changed order
        UPDATE lg
        SET DisplayOrder = t.DisplayOrder,
            UpdatedBy = @UserId,
            DateUpdated = GETUTCDATE()
        FROM LayoutGridColumns lg
        INNER JOIN #TempGridCells t ON (
            lg.LayoutId = @LayoutId 
            AND lg.TenantId = @TenantId
            AND lg.RowNumber = t.RowNumber
            AND lg.ColumnNumber = t.ColumnNumber
            AND lg.ColumnId = t.ColumnId
        )
        WHERE lg.DisplayOrder != t.DisplayOrder;
        
        -- Clean up temp table
        DROP TABLE #TempGridCells;
        
        -- Return success response
        SELECT 'Success' AS Status, 'Grid cells saved successfully' AS Message;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Return error information
        SELECT 
            'Error' AS Status,
            'Error saving grid cells: ' + ERROR_MESSAGE() AS Message;
        
        -- Log error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
