USE [StaffScheduling_DEV]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      System
-- Create date: 2025-12-19
-- Description: Save a shift trade request
-- =============================================

CREATE PROCEDURE [dbo].[usp_ShiftTrades_SendTradeRequest]
    @JsonData NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TradingEmployeeId INT;
    DECLARE @TradingShiftId INT;
    DECLARE @TradingAssignmentId INT;
    DECLARE @TradingDate DATE;
    DECLARE @IsSwap BIT;
    DECLARE @AcceptingEmployeeId INT;
    DECLARE @AcceptingShiftId INT;
    DECLARE @AcceptingAssignmentId INT;
    DECLARE @AcceptingDate DATE;
    DECLARE @TradeRequestId INT;
    DECLARE @CurrentDateTime DATETIMEOFFSET = SYSDATETIMEOFFSET();

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON data
        SELECT 
            @TradingEmployeeId = JSON_VALUE(@JsonData, '$.tradingEmployeeId'),
            @TradingShiftId = JSON_VALUE(@JsonData, '$.tradingShiftId'),
            @TradingAssignmentId = JSON_VALUE(@JsonData, '$.tradingAssignmentId'),
            @TradingDate = CAST(JSON_VALUE(@JsonData, '$.tradingDate') AS DATE),
            @IsSwap = CAST(JSON_VALUE(@JsonData, '$.isSwap') AS BIT),
            @AcceptingEmployeeId = JSON_VALUE(@JsonData, '$.acceptingEmployeeId'),
            @AcceptingShiftId = JSON_VALUE(@JsonData, '$.acceptingShiftId'),
            @AcceptingAssignmentId = JSON_VALUE(@JsonData, '$.acceptingAssignmentId'),
            @AcceptingDate = CAST(JSON_VALUE(@JsonData, '$.acceptingDate') AS DATE);

        -- Validate required fields
        IF @TradingEmployeeId IS NULL OR @TradingShiftId IS NULL OR @TradingAssignmentId IS NULL OR @TradingDate IS NULL
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Trading employee, shift, assignment, and date are required.',
                tradeRequestId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        IF @IsSwap = 1 AND (@AcceptingEmployeeId IS NULL OR @AcceptingShiftId IS NULL OR @AcceptingAssignmentId IS NULL OR @AcceptingDate IS NULL)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'For swap trades, accepting employee, shift, assignment, and date are required.',
                tradeRequestId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Insert trade request into ShiftTrades table
        -- Note: The ShiftTrades table structure uses FromUserId/ToUserId and FromAssignmentId/ToAssignmentId
        INSERT INTO [dbo].[ShiftTrades] (
            TenantId,
            FromUserId,
            ToUserId,
            FromAssignmentId,
            ToAssignmentId,
            RequestedAt,
            Approvedby,
            CreatedBy,
            DateCreated
        )
        VALUES (
            @TenantId,
            @TradingEmployeeId,
            @AcceptingEmployeeId,
            @TradingAssignmentId,
            @AcceptingAssignmentId,
            @CurrentDateTime,
            @UserId,
            @UserId,
            @CurrentDateTime
        );

        SET @TradeRequestId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        -- Return success response
        SELECT 
            success = CAST(1 AS BIT),
            message = 'Trade request sent successfully',
            tradeRequestId = @TradeRequestId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        SELECT 
            success = CAST(0 AS BIT),
            message = @ErrorMessage,
            tradeRequestId = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

