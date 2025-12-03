USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffCodes_Save]    Script Date: 12/3/2025 2:30:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffCodes_Save] - Save (Create/Update) Time Off Code with duplicate name/code validation
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffCodes_Save]  
    @Json NVARCHAR(MAX),  
    @UserId INT,  
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        DECLARE @Id INT;  
        DECLARE @Name VARCHAR(250);  
        DECLARE @Code NVARCHAR(50);  
        DECLARE @BackgroundColor NVARCHAR(10);  
        DECLARE @TextColor NVARCHAR(10);  
        DECLARE @IsRequestable BIT;  
  
        -- Parse JSON  
        SELECT   
            @Id = id,  
            @Name = name,  
            @Code = code,  
            @BackgroundColor = backgroundColor,  
            @TextColor = textColor,  
            @IsRequestable = ISNULL(isRequestable, 1)  
        FROM OPENJSON(@Json)  
        WITH (  
            id INT,  
            name VARCHAR(250),  
            code NVARCHAR(50),  
            backgroundColor NVARCHAR(10),  
            textColor NVARCHAR(10),  
            isRequestable BIT  
        );  
  
        -- Check for duplicate name (excluding current record if updating)  
        IF EXISTS (  
            SELECT 1   
            FROM TimeOffCodes   
            WHERE Name = @Name   
                AND TenantId = @TenantId   
                AND (@Id IS NULL OR Id != @Id)  
        )  
        BEGIN  
            SELECT  
                CAST(0 AS BIT) AS success,  
                'A time off code with this name already exists.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            RETURN;  
        END  
  
        -- Check for duplicate code (excluding current record if updating)  
        IF EXISTS (  
            SELECT 1   
            FROM TimeOffCodes   
            WHERE Code = @Code   
                AND TenantId = @TenantId   
                AND (@Id IS NULL OR Id != @Id)  
        )  
        BEGIN  
            SELECT  
                CAST(0 AS BIT) AS success,  
                'A time off code with this code already exists.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            RETURN;  
        END  
  
        -- All validations passed, now start transaction  
        BEGIN TRANSACTION;  
  
        -- Insert or Update  
        IF @Id IS NULL OR @Id = 0  
        BEGIN  
            -- Insert new time off code  
            INSERT INTO TimeOffCodes (TenantId, Name, Code, BackgroundColor, TextColor, IsRequestable, CreatedBy, DateCreated)  
            VALUES (@TenantId, @Name, @Code, @BackgroundColor, @TextColor, @IsRequestable, @UserId, SYSDATETIMEOFFSET());  
  
            SET @Id = SCOPE_IDENTITY();  
        END  
        ELSE  
        BEGIN  
            -- Update existing time off code  
            UPDATE TimeOffCodes  
            SET   
                Name = @Name,  
                Code = @Code,  
                BackgroundColor = @BackgroundColor,  
                TextColor = @TextColor,  
                IsRequestable = @IsRequestable,  
                UpdatedBy = @UserId,  
                DateUpdated = SYSDATETIMEOFFSET()  
            WHERE Id = @Id AND TenantId = @TenantId;  
  
            IF @@ROWCOUNT = 0  
            BEGIN  
                ROLLBACK TRANSACTION;  
                SELECT  
                    CAST(0 AS BIT) AS success,  
                    'Time off code not found or unauthorized.' AS message  
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
                RETURN;  
            END  
        END  
  
        COMMIT TRANSACTION;  
  
        -- Return success with the time off code Id  
        SELECT  
            @Id AS id,  
            CAST(1 AS BIT) AS success,  
            'Time off code saved successfully.' AS message  
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

