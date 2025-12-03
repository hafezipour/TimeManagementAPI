USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffCodes_Get]    Script Date: 12/3/2025 2:30:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffCodes_Get] - Get all Time Off Codes (client-side pagination)
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffCodes_Get]  
 @TimeOffCodeId int = NULL,  
 @TenantId int  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 SELECT   
  t.Id as id,  
  t.Name as name,  
  t.Code as code,  
  t.BackgroundColor as backgroundColor,  
  t.TextColor as textColor,  
  t.IsRequestable as isRequestable,  
  t.CreatedBy as createdBy,  
  t.UpdatedBy as updatedBy,  
  t.DateCreated as dateCreated,  
  t.DateUpdated as dateUpdated,  
  t.TenantId as tenantId  
 FROM TimeOffCodes t  
 WHERE t.TenantId = @TenantId  
  AND (@TimeOffCodeId IS NULL OR t.Id = @TimeOffCodeId)  
 ORDER BY t.Name ASC  
 FOR JSON PATH, INCLUDE_NULL_VALUES  
END  
GO

