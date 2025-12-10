USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_GetForScheduler]    Script Date: 1/15/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 1/15/2025  
-- Description: [usp_TimeOffRequests_GetForScheduler] - Fetch time off requests for scheduler view
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_GetForScheduler]  
    @UserIdsJson NVARCHAR(MAX) = NULL, -- JSON array of user IDs: [1, 2, 3]. If NULL or empty, fetch all users
    @FromDate DATE,
    @ToDate DATE,
    @StatusFilter INT = NULL, -- If NULL, fetch both Pending (1) and Approved (2). If 2, fetch only Approved. If 1, fetch only Pending.
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
    
    -- Parse JSON array of user IDs into a table
    DECLARE @UserIds TABLE (UserId INT);
    
    IF @UserIdsJson IS NOT NULL AND LEN(@UserIdsJson) > 0
    BEGIN
        INSERT INTO @UserIds (UserId)
        SELECT value AS UserId
        FROM OPENJSON(@UserIdsJson);
    END
    
    -- Fetch time off requests that overlap with the date range
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
        toc.BackgroundColor AS TimeOffTypeBackgroundColor,
        toc.TextColor AS TimeOffTypeTextColor,
        at.TypeName AS AccrualTypeName,
        at.TypeCode AS AccrualTypeCode
    FROM TimeOffRequests tor
    INNER JOIN Schedules s ON s.SourceType = 4 AND s.SourceId = tor.Id AND s.TenantId = @TenantId
    LEFT JOIN TimeOffCodes toc ON tor.TimeOffTypeId = toc.Id AND toc.TenantId = @TenantId
    LEFT JOIN AccrualTypes at ON tor.AccrualTypeId = at.Id AND at.TenantId = @TenantId
    WHERE tor.TenantId = @TenantId
      AND (
          -- If StatusFilter is NULL, fetch both Pending (1) and Approved (2)
          (@StatusFilter IS NULL AND tor.Status IN (1, 2))
          OR
          -- If StatusFilter is specified, fetch only that status
          (@StatusFilter IS NOT NULL AND tor.Status = @StatusFilter)
      )
      AND (
          -- Request overlaps with date range if:
          -- StartFrom <= ToDate AND (ValidUntil >= FromDate OR ValidUntil IS NULL)
          s.StartFrom <= @ToDate
          AND (s.ValidUntil >= @FromDate OR s.ValidUntil IS NULL)
      )
      AND (
          -- If UserIdsJson is not specified or empty, don't filter by user IDs
          (@UserIdsJson IS NULL OR LEN(@UserIdsJson) = 0)
          OR
          -- If UserIdsJson is specified, filter by the provided user IDs
          EXISTS (SELECT 1 FROM @UserIds u WHERE u.UserId = tor.UserId)
      )
    ORDER BY s.StartFrom, s.StartTime
    FOR JSON PATH, INCLUDE_NULL_VALUES;
END  
GO

