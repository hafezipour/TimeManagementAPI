USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_CheckOverlap]    Script Date: 12/3/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffRequests_CheckOverlap] - Fetch candidate time off requests that could overlap
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_CheckOverlap]  
    @UserId INT,  
    @FromDate DATE,
    @ExcludeId INT = NULL, -- For update scenarios, exclude current request
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
    
    -- Fetch all pending/approved time off requests for the user
    -- where ValidUntil >= fromDate OR ValidUntil IS NULL
    -- These are candidates for overlap checking
    
    SELECT 
        tor.Id,
        tor.UserId,
        tor.Status,
        tor.TimeOffTypeId,
        tor.AccrualTypeId,
        tor.Notes,
        tor.DateCreated,
        s.StartFrom AS StartFrom,
        s.ValidUntil AS ValidUntil,
        s.StartTime AS StartTime,
        s.EndTime AS EndTime,
        toc.Name AS TimeOffTypeName,
        toc.Code AS TimeOffTypeCode,
        at.TypeName AS AccrualTypeName
    FROM TimeOffRequests tor
    INNER JOIN Schedules s ON s.SourceType = 4 AND s.SourceId = tor.Id AND s.TenantId = @TenantId
    LEFT JOIN TimeOffCodes toc ON tor.TimeOffTypeId = toc.Id AND toc.TenantId = @TenantId
    LEFT JOIN AccrualTypes at ON tor.AccrualTypeId = at.Id AND at.TenantId = @TenantId
    WHERE tor.UserId = @UserId
      AND tor.TenantId = @TenantId
      AND tor.Status IN (1, 2) -- Pending or Approved
      AND (@ExcludeId IS NULL OR tor.Id <> @ExcludeId)
      AND (
          s.ValidUntil >= @FromDate
          OR s.ValidUntil IS NULL
      )
    FOR JSON PATH, INCLUDE_NULL_VALUES;
END  
GO

