/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_Delete]    Script Date: 10/28/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/28/2025
DESCRIPTION			: Delete a shift from a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_ColumnShifts_Delete]
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
        DECLARE @ShiftId INT = JSON_VALUE(@Json, '$.shiftId')
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId')

        -- Validate parsed values
        IF @ColumnId IS NULL OR @ColumnId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ColumnId in JSON"}' as Result
            RETURN
        END

        IF @ShiftId IS NULL OR @ShiftId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ShiftId in JSON"}' as Result
            RETURN
        END

        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId in JSON"}' as Result
            RETURN
        END

        -- Check if the column shift exists
        IF NOT EXISTS (
            SELECT 1 
            FROM [dbo].[ColumnShifts] 
            WHERE ColumnId = @ColumnId 
              AND ShiftId = @ShiftId 
              AND LayoutId = @LayoutId 
              AND TenantId = @TenantId
        )
        BEGIN
            SELECT '{"success": false, "message": "Column shift not found"}' as Result
            RETURN
        END

        -- Delete the column shift
        DELETE FROM [dbo].[ColumnShifts]
        WHERE ColumnId = @ColumnId 
          AND ShiftId = @ShiftId 
          AND LayoutId = @LayoutId 
          AND TenantId = @TenantId

        -- Return success message
        SELECT '{"success": true, "message": "Shift successfully removed from column"}' as Result

    END TRY
    BEGIN CATCH
        -- Return error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        SELECT '{"success": false, "message": "Error deleting shift from column: ' + @ErrorMessage + '"}' as Result
    END CATCH
END
GO

