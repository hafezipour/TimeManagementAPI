USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffCodes_Delete]    Script Date: 12/3/2025 2:30:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: usp_TimeOffCodes_Delete - Delete Time Off Code
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffCodes_Delete]  
    @TimeOffCodeId INT,  
    @UserId INT,  
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        BEGIN TRANSACTION;  
  
        -- Delete the time off code  
        DELETE FROM TimeOffCodes  
        WHERE Id = @TimeOffCodeId  
            AND TenantId = @TenantId;  
  
        -- Check if any rows were affected  
        IF @@ROWCOUNT = 0  
        BEGIN  
            ROLLBACK TRANSACTION;  
            SELECT  
                cast(0 as bit) AS success,  
                'Time off code not found or already deleted.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            RETURN;  
        END  
  
        COMMIT TRANSACTION;  
  
        -- Return success  
        SELECT  
            cast(1 as bit) AS success,  
            'Time off code deleted successfully.' AS message  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
  
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
            ROLLBACK TRANSACTION;  
  
        -- Return error  
        SELECT  
            cast(0 as bit) AS success,  
            ERROR_MESSAGE() AS message  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
    END CATCH  
END  
GO

