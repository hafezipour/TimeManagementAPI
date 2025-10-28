/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_BatchUpdateOrder]    Script Date: 10/28/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/28/2025
DESCRIPTION			: Batch update shift display orders for a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_ColumnShifts_BatchUpdateOrder]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Json IS NULL OR @Json = ''
        BEGIN
            SELECT '{"success": false, "message": "Invalid JSON parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Parse JSON and extract values
        DECLARE @ColumnId INT = JSON_VALUE(@Json, '$.columnId')
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId')

        -- Validate parsed values
        IF @ColumnId IS NULL OR @ColumnId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ColumnId in JSON"}' as Result
            RETURN
        END

        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId in JSON"}' as Result
            RETURN
        END

        -- Check if the column exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE Id = @ColumnId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
            RETURN
        END

        -- Check if the layout exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Layouts] WHERE Id = @LayoutId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Layout not found"}' as Result
            RETURN
        END

        -- Create a temporary table to hold the shift updates
        CREATE TABLE #ShiftUpdates (
            ShiftId INT,
            DisplayOrder INT
        )

        -- Parse the shifts array from JSON
        INSERT INTO #ShiftUpdates (ShiftId, DisplayOrder)
        SELECT 
            JSON_VALUE(value, '$.shiftId') as ShiftId,
            JSON_VALUE(value, '$.displayOrder') as DisplayOrder
        FROM OPENJSON(@Json, '$.shifts')

        -- Validate that all shifts exist
        IF EXISTS (
            SELECT 1 
            FROM #ShiftUpdates su
            WHERE NOT EXISTS (
                SELECT 1 
                FROM [dbo].[Shifts] s
                WHERE s.Id = su.ShiftId AND s.TenantId = @TenantId
            )
        )
        BEGIN
            DROP TABLE #ShiftUpdates
            SELECT '{"success": false, "message": "One or more shifts not found"}' as Result
            RETURN
        END

        -- Begin transaction for batch update
        BEGIN TRANSACTION

        -- Update display orders for all shifts in the batch
        UPDATE cs
        SET 
            cs.DisplayOrder = su.DisplayOrder,
            cs.UpdatedBy = @UserId,
            cs.DateUpdated = GETDATE()
        FROM [dbo].[ColumnShifts] cs
        INNER JOIN #ShiftUpdates su ON cs.ShiftId = su.ShiftId
        WHERE cs.ColumnId = @ColumnId
          AND cs.LayoutId = @LayoutId
          AND cs.TenantId = @TenantId

        -- Get the count of updated records
        DECLARE @UpdatedCount INT = @@ROWCOUNT

        COMMIT TRANSACTION

        -- Clean up temporary table
        DROP TABLE #ShiftUpdates

        -- Return success message with count
        SELECT '{"success": true, "message": "Shift orders updated successfully", "updatedCount": ' + CAST(@UpdatedCount AS NVARCHAR(10)) + '}' as Result

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        -- Clean up temporary table if it exists
        IF OBJECT_ID('tempdb..#ShiftUpdates') IS NOT NULL
            DROP TABLE #ShiftUpdates

        -- Return error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        SELECT '{"success": false, "message": "Error updating shift orders: ' + @ErrorMessage + '"}' as Result
    END CATCH
END
GO

