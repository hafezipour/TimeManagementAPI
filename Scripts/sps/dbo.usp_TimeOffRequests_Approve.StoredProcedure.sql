USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_Approve]    Script Date: 12/3/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffRequests_Approve] - Approve Time Off Request
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_Approve]  
    @TimeOffRequestId INT,  
    @UserId INT,  
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        BEGIN TRANSACTION;
        
        -- Update TimeOffRequest status to Approved (2)
        UPDATE TimeOffRequests  
        SET   
            Status = 2, -- Approved
            ApprovedBy = @UserId,
            ApprovedOn = SYSDATETIMEOFFSET(),
            UpdatedBy = @UserId,  
            DateUpdated = SYSDATETIMEOFFSET()  
        WHERE Id = @TimeOffRequestId AND TenantId = @TenantId;  
        
        IF @@ROWCOUNT = 0  
        BEGIN  
            ROLLBACK TRANSACTION;
            SELECT  
                CAST(0 AS BIT) AS success,  
                'Time off request not found or unauthorized.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            RETURN;  
        END
        
        COMMIT TRANSACTION;  
  
        -- Return success
        SELECT  
            @TimeOffRequestId AS id,  
            CAST(1 AS BIT) AS success,  
            'Time off request approved successfully.' AS message  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
  
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
            ROLLBACK TRANSACTION;  
  
        -- Return error  
        SELECT  
            CAST(0 AS BIT) AS success,  
            ERROR_MESSAGE() AS message  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
    END CATCH  
END  
GO

