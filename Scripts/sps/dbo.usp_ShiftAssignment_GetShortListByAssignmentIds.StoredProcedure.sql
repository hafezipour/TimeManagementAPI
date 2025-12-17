USE [StaffScheduling_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftAssignment_GetShortListByAssignmentIds]    Script Date: 12/15/2025 8:27:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      Auto-generated
-- Create date: 2025-12-15  
-- Description: Get shift assignments short list by assignment IDs (for trade validation)
--              Returns only: id, userId, jobCodes, workCodes
-- =============================================  
CREATE   PROCEDURE [dbo].[usp_ShiftAssignment_GetShortListByAssignmentIds]  
    @AssignmentIds NVARCHAR(MAX),  
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        -- Get shift assignments matching the assignment IDs
        SELECT   
            sa.Id as id,  
            sa.UserId as userId,  
            -- Work Codes array  
            (  
                SELECT   
                    wc.Id as id,  
                    wc.WorkCodeName as workCodeName,  
                    wc.WorkCode as workCode,  
                    wc.ColorCode as colorCode,  
                    wc.IsActive as isActive  
                FROM EmployeeShiftAssignmentWorkCodes eswc  
                INNER JOIN WorkCodes wc ON wc.Id = eswc.WorkCodeId  
                WHERE eswc.ShiftAssignmentId = sa.Id   
                    AND eswc.TenantId = @TenantId  
                FOR JSON PATH  
            ) as workCodes,  
            -- Job Codes array  
            (  
                SELECT   
                    jc.Id as id,  
                    jc.JobTitle as jobTitle,  
                    jc.JobCode as jobCode,  
                    jc.IsActive as isActive  
                FROM EmployeeShiftAssignmentJobCodes esjc  
                INNER JOIN JobCodes jc ON jc.Id = esjc.JobCodeId  
                WHERE esjc.ShiftAssignmentId = sa.Id   
                    AND esjc.TenantId = @TenantId  
                FOR JSON PATH  
            ) as jobCodes
        FROM ShiftAssignment sa  
        WHERE sa.TenantId = @TenantId  
            AND sa.Id IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@AssignmentIds, ','))  
        ORDER BY sa.Id  
        FOR JSON PATH;  
  
    END TRY  
    BEGIN CATCH  
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
          
        SELECT   
            success = CAST(0 AS BIT),  
            message = @ErrorMessage,  
            data = NULL  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
    END CATCH  
END  
GO

