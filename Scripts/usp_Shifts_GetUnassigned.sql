CREATE OR ALTER PROCEDURE [dbo].[usp_Shifts_GetUnassigned]
    @TenantId INT,
    @LayoutId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate TenantId
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Validate LayoutId
        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId parameter"}' as Result
            RETURN
        END

        -- Get shifts that are NOT assigned to ANY column within the specific layout
        SELECT 
            s.[Id] as [id],
            s.[ShiftName] as [shiftName],
            s.[ShiftCode] as [shiftCode],
            s.[BackgroundColour] as [backgroundColour],
            s.[MinimumPositions] as [minimumPositions],
            s.[MaxTimeoffs] as [maxTimeoffs],
            s.[IsWorkShift] as [isWorkShift],
            s.[IsSelfSchedulingEnabled] as [isSelfSchedulingEnabled]
        FROM [dbo].[Shifts] s
        WHERE s.[TenantId] = @TenantId
          AND s.[IsWorkShift] = 1  -- Only work shifts
          AND s.Id NOT IN (
              SELECT DISTINCT cs.ShiftId 
              FROM [dbo].[ColumnShifts] cs 
              WHERE cs.TenantId = @TenantId
                AND cs.LayoutId = @LayoutId
          )
        ORDER BY s.[ShiftName]
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
