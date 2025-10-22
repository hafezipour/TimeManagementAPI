USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_Save]    Script Date: 10/22/2025 5:30:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/22/2025
DESCRIPTION			: Save shift assignment to a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ColumnShifts_Save]
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
        DECLARE @DisplayOrder INT = JSON_VALUE(@Json, '$.displayOrder')

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

        -- Check if the column exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE Id = @ColumnId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
            RETURN
        END

        -- Check if the shift exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Shifts] WHERE Id = @ShiftId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Shift not found"}' as Result
            RETURN
        END

        -- Check if the layout exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Layouts] WHERE Id = @LayoutId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Layout not found"}' as Result
            RETURN
        END

        -- Check if this shift is already assigned to any column in this layout
        IF EXISTS (SELECT 1 FROM [dbo].[ColumnShifts] 
                   WHERE ShiftId = @ShiftId 
                     AND LayoutId = @LayoutId 
                     AND TenantId = @TenantId)
        BEGIN
            -- Update existing assignment to new column
            UPDATE [dbo].[ColumnShifts] 
            SET [ColumnId] = @ColumnId,
                [DisplayOrder] = @DisplayOrder,
                [UpdatedBy] = @UserId,
                [DateUpdated] = GETDATE()
            WHERE ShiftId = @ShiftId 
              AND LayoutId = @LayoutId 
              AND TenantId = @TenantId

            SELECT '{"success": true, "message": "Shift successfully moved to new column"}' as Result
        END
        ELSE
        BEGIN
            -- Insert new shift assignment
            INSERT INTO [dbo].[ColumnShifts] (
                [ColumnId],
                [ShiftId],
                [LayoutId],
                [DisplayOrder],
                [TenantId],
                [CreatedBy],
                [DateCreated]
            )
            VALUES (
                @ColumnId,
                @ShiftId,
                @LayoutId,
                @DisplayOrder,
                @TenantId,
                @UserId,
                GETDATE()
            )

            SELECT '{"success": true, "message": "Shift successfully assigned to column"}' as Result
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
