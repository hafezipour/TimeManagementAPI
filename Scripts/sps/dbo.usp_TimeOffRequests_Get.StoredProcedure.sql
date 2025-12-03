USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_Get]    Script Date: 12/3/2025 6:35:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffRequests_Get] - Get Time Off Requests with server-side pagination, sorting, and search
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_Get]  
 @TimeOffRequestId int = NULL,  
 @TenantId int,  
 @PageNumber int = 1,  
 @PageSize int = 10,  
 @SortColumn varchar(50) = 'DateCreated',  
 @SortDirection varchar(4) = 'DESC',  
 @SearchTerm varchar(255) = NULL  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @Offset int = (@PageNumber - 1) * @PageSize;  
  
 ;WITH _rows AS (  
  SELECT   
   tor.Id as id,  
   tor.TenantId as tenantId,  
   tor.UserId as userId,  
   tor.AccrualTypeId as accrualTypeId,  
   tor.TimeOffTypeId as timeOffTypeId,  
   tor.Status as status,  
   tor.ApprovedBy as approvedBy,  
   tor.ApprovedOn as approvedOn,  
   tor.RejectedBy as rejectedBy,  
   tor.RejectedOn as rejectedOn,  
   tor.Notes as notes,  
   tor.CreatedBy as createdBy,  
   tor.DateCreated as dateCreated,  
  tor.UpdatedBy as updatedBy,  
  tor.DateUpdated as dateUpdated,  
  -- Time Off Type information
  toc.Name as timeOffTypeName,  
  toc.Code as timeOffTypeCode,  
  toc.BackgroundColor as timeOffTypeBackgroundColor,  
  toc.TextColor as timeOffTypeTextColor,  
  -- Accrual Type information
  at.TypeName as accrualTypeName  
 FROM TimeOffRequests tor  
 LEFT JOIN TimeOffCodes toc ON tor.TimeOffTypeId = toc.Id AND toc.TenantId = @TenantId  
 LEFT JOIN AccrualTypes at ON tor.AccrualTypeId = at.Id AND at.TenantId = @TenantId
  WHERE tor.TenantId = @TenantId  
   AND (@TimeOffRequestId IS NULL OR tor.Id = @TimeOffRequestId)  
   AND (  
    @SearchTerm IS NULL OR   
    toc.Name LIKE '%' + @SearchTerm + '%' OR   
    at.TypeName LIKE '%' + @SearchTerm + '%' OR   
    tor.Notes LIKE '%' + @SearchTerm + '%'  
   )  
 )  
 SELECT   
  _rows.id,  
  _rows.tenantId,  
  _rows.userId,  
  _rows.accrualTypeId,  
  _rows.timeOffTypeId,  
  _rows.status,  
  _rows.approvedBy,  
  _rows.approvedOn,  
  _rows.rejectedBy,  
  _rows.rejectedOn,  
  _rows.notes,  
  _rows.createdBy,  
  _rows.dateCreated,  
  _rows.updatedBy,  
  _rows.dateUpdated,  
  _rows.timeOffTypeName,  
  _rows.timeOffTypeCode,  
  _rows.timeOffTypeBackgroundColor,  
  _rows.timeOffTypeTextColor,  
  _rows.accrualTypeName,  
  (SELECT count(_rows.id) from _rows) as totalCount  
 FROM _rows  
 ORDER BY   
  CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'ASC' THEN _rows.dateCreated END ASC,  
  CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'DESC' THEN _rows.dateCreated END DESC,  
  CASE WHEN @SortColumn = 'TimeOffTypeName' AND @SortDirection = 'ASC' THEN _rows.timeOffTypeName END ASC,  
  CASE WHEN @SortColumn = 'TimeOffTypeName' AND @SortDirection = 'DESC' THEN _rows.timeOffTypeName END DESC,  
  CASE WHEN @SortColumn = 'Status' AND @SortDirection = 'ASC' THEN _rows.status END ASC,  
  CASE WHEN @SortColumn = 'Status' AND @SortDirection = 'DESC' THEN _rows.status END DESC,  
  _rows.dateCreated DESC  
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY  
 FOR JSON PATH, INCLUDE_NULL_VALUES  
END  
GO

