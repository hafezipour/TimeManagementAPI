USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_GetTimeOffRequestsForUsers]    Script Date: 12/5/2025 3:12:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Ali Nafees
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffRequests_GetTimeOffRequestsForUsers] - Fetch time off requests for users
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_GetTimeOffRequestsForUsers]  
    @UserIdsJson NVARCHAR(MAX) = NULL, -- JSON array of user IDs: [1, 2, 3]. If NULL or empty, don't filter by user IDs
    @FromDate DATE,
    @ExcludeId INT = NULL, -- For update scenarios, exclude current request
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
    
    -- Fetch all pending/approved time off requests for the users (or all users if UserIdsJson is not specified)
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
          -- If StatusFilter is NULL, fetch both Pending (1) and Approved (2) - for overlap checking
          (@StatusFilter IS NULL AND tor.Status IN (1, 2))
          OR
          -- If StatusFilter is specified, fetch only that status - for columns display (2 = Approved only)
          (@StatusFilter IS NOT NULL AND tor.Status = @StatusFilter)
      )
      AND (@ExcludeId IS NULL OR tor.Id <> @ExcludeId)
      AND (
          s.ValidUntil >= @FromDate
          OR s.ValidUntil IS NULL
      )
      AND (
          -- If UserIdsJson is not specified or empty, don't filter by user IDs
          (@UserIdsJson IS NULL OR LEN(@UserIdsJson) = 0)
          OR
          -- If UserIdsJson is specified, filter by the provided user IDs
          EXISTS (SELECT 1 FROM @UserIds u WHERE u.UserId = tor.UserId)
      )
    FOR JSON PATH, INCLUDE_NULL_VALUES;
END  
GO

