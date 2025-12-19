USE [StaffScheduling_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftTrades_CheckApprovedTradeConflict]    Script Date: 12/19/2025 4:06:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Ali Nafees
-- Create date: 2025-12-19
-- Description: Check if an approved trade already exists in ShiftAssignment table
--              for the same user, shift, and date
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftTrades_CheckApprovedTradeConflict]
    @ShiftId INT,
    @Date DATE,
    @ShiftType NVARCHAR(20), -- 'Trading' or 'Accepting'
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HasConflict BIT = 0;
    DECLARE @ConflictMessage NVARCHAR(500) = '';

    -- Simple check: Select from ShiftAssignment where ShiftId = @ShiftId and date = @date and TradeRequestId > 0
    -- Join with trades table to check against approved trades only
    -- If exists for anyone, new trade for same date slot for anyone else cannot be made
    IF EXISTS (
        SELECT 1
        FROM [dbo].[ShiftAssignment] sa
        INNER JOIN [dbo].[Schedules] s ON s.SourceId = sa.Id 
            AND s.SourceType = 3 -- ShiftAssignment
            AND s.TenantId = @TenantId
        INNER JOIN [dbo].[ShiftTrades] st ON st.Id = sa.TradeRequestId 
            AND st.TenantId = @TenantId
            AND st.StatusCustomTableValueId = 2 -- Approved
        WHERE sa.TenantId = @TenantId
            AND sa.ShiftId = @ShiftId
            AND sa.TradeRequestId > 0
            AND CAST(s.StartFrom AS DATE) = @Date
    )
    BEGIN
        SET @HasConflict = 1;
        SET @ConflictMessage = 'An approved trade already exists for the ' + LOWER(@ShiftType) + ' shift and date.';
    END

    -- Return result
    SELECT 
        hasConflict = CAST(@HasConflict AS BIT),
        conflictMessage = @ConflictMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

