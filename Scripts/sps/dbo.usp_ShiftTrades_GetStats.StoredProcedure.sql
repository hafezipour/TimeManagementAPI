USE [StaffScheduling_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftTrades_GetStats]    Script Date: 12/22/2025 7:30:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================    
-- Author:      Ali Nafees  
-- Create date: 2025-12-22    
-- Description: Get Shift Trades statistics (Open, Approved, Denied) where tradingDate or acceptingDate >= @Date
-- =============================================    
CREATE PROCEDURE [dbo].[usp_ShiftTrades_GetStats]  
    @Date DATE = NULL,
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
    
    -- Default to today's date if not provided
    IF @Date IS NULL
        SET @Date = CAST(SYSUTCDATETIME() AS DATE);
    
    SELECT   
        ISNULL(SUM(CASE WHEN st.StatusCustomTableValueId = 1 THEN 1 ELSE 0 END), 0) AS openCount,
        ISNULL(SUM(CASE WHEN st.StatusCustomTableValueId = 2 THEN 1 ELSE 0 END), 0) AS approvedCount,
        ISNULL(SUM(CASE WHEN st.StatusCustomTableValueId = 3 THEN 1 ELSE 0 END), 0) AS deniedCount
    FROM ShiftTrades st  
    WHERE st.TenantId = @TenantId  
        AND (
            CAST(st.TradingDate AS DATE) >= @Date 
            OR CAST(st.AcceptingDate AS DATE) >= @Date
        )
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END  

GO

