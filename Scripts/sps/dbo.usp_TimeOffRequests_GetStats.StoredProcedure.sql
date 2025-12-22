USE [StaffScheduling_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_GetStats]    Script Date: 12/22/2025 7:30:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================    
-- Author:      Ali Nafees  
-- Create date: 2025-12-22    
-- Description: Get Time Off Requests statistics (Open, Approved, Denied) where validUntil >= @Date
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_GetStats]  
    @Date DATE = NULL,
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
    
    -- Default to today's date if not provided
    IF @Date IS NULL
        SET @Date = CAST(SYSUTCDATETIME() AS DATE);
    
    SELECT   
        ISNULL(SUM(CASE WHEN tor.Status = 1 THEN 1 ELSE 0 END), 0) AS openCount,
        ISNULL(SUM(CASE WHEN tor.Status = 2 THEN 1 ELSE 0 END), 0) AS approvedCount,
        ISNULL(SUM(CASE WHEN tor.Status = 3 THEN 1 ELSE 0 END), 0) AS deniedCount
    FROM TimeOffRequests tor  
    LEFT JOIN Schedules s ON s.SourceType = 4 AND s.SourceId = tor.Id AND s.TenantId = @TenantId
    WHERE tor.TenantId = @TenantId  
        AND s.ValidUntil IS NOT NULL
        AND CAST(s.ValidUntil AS DATE) >= @Date
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END  

GO

