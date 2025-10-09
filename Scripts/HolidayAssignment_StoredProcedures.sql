USE [TimeManagement_DEV]
GO

-- =============================================
-- Stored Procedures for HolidayAssignment
-- =============================================

/*---------------------=========================================================================================================
CREATED BY			: TimeManagement API
CREATED DATE 		: 10/9/2025
DESCRIPTION			: Get Holiday Assignment List with filters and paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	:
EXEC [usp_HolidayAssignment_Get] 0, 10, '1,2,3', 1, 1, 1
---------------------=========================================================================================================+*/
CREATE OR ALTER PROCEDURE [dbo].[usp_HolidayAssignment_Get]
(
    @OffSet int,
    @Limit int,
    @HolidayIds nvarchar(max),
    @JobCodeId int,
    @UserId int,
    @TenantId int
)
AS
BEGIN
    IF(ISNULL(@HolidayIds, '') = '')
    BEGIN
        SET @HolidayIds = '0'
    END
    
    IF(ISNULL(@JobCodeId, 0) = 0)
    BEGIN
        SET @JobCodeId = 0
    END
    
    IF(ISNULL(@UserId, 0) = 0)
    BEGIN
        SET @UserId = 0
    END
    
    ;WITH _rows AS (
        SELECT 
            ha.Id as id,
            ha.TenantId as tenantId,
            ha.HolidayId as holidayId,
            ha.JobCodeId as jobCodeId,
            ha.UserId as userId,
            ha.IsActive as isActive,
            ha.EffectiveDate as effectiveDate,
            ha.ExpiryDate as expiryDate,
            ha.CreatedBy as createdBy,
            ha.UpdatedBy as updatedBy,
            ha.DateCreated as dateCreated,
            ha.DateUpdated as dateUpdated,
            h.HolidayCode as holidayCode,
            h.HolidayName as holidayName,
            h.HolidayDate as holidayDate,
            h.IsObserved as holidayIsObserved,
            h.IsFloating as holidayIsFloating,
            h.IsAppliesToAll as holidayIsAppliesToAll,
            jc.JobCode as jobCode,
            jc.JobTitle as jobTitle,
            jc.Description as jobDescription,
            jc.Category as jobCategory,
            ISNULL(ha.DateUpdated, ha.DateCreated) as sortingDate
        FROM HolidayAssignment ha
        LEFT JOIN Holidays h ON ha.HolidayId = h.Id AND h.TenantId = @TenantId
        LEFT JOIN JobCodes jc ON ha.JobCodeId = jc.Id AND jc.TenantId = @TenantId
        WHERE ha.TenantId = @TenantId
            AND (@HolidayIds = '0' OR ha.HolidayId IN (SELECT value FROM STRING_SPLIT(@HolidayIds, ',')))
            AND (@JobCodeId = 0 OR ha.JobCodeId = @JobCodeId)
            AND (@UserId = 0 OR ha.UserId = @UserId)
    )
    SELECT 
        (SELECT count(_rows.id) from _rows) as totalRecordsCount,
        * 
    FROM _rows
    ORDER BY TRIM(_rows.holidayName) ASC
    OFFSET @OffSet ROWS 
    FETCH NEXT @Limit ROWS ONLY
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

-- =============================================
-- Author: TimeManagement API
-- Create date: 10/9/2025
-- Description: Save (Insert/Update) Holiday Assignment
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_HolidayAssignment_Save]
    @Json varchar(max),
    @UserId int,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN
        
        DECLARE @Id int
        DECLARE @HolidayId int
        DECLARE @JobCodeId int
        DECLARE @UserId int
        DECLARE @IsActive bit
        DECLARE @EffectiveDate datetimeoffset(7)
        DECLARE @ExpiryDate datetimeoffset(7)
        
        -- Parse JSON
        SELECT 
            @Id = id,
            @HolidayId = holidayId,
            @JobCodeId = jobCodeId,
            @UserId = userId,
            @IsActive = ISNULL(isActive, 1),
            @EffectiveDate = effectiveDate,
            @ExpiryDate = expiryDate
        FROM OPENJSON(@Json) WITH (
            id int,
            holidayId int,
            jobCodeId int,
            userId int,
            isActive bit,
            effectiveDate datetimeoffset(7),
            expiryDate datetimeoffset(7)
        )
        
        -- Check if Holiday Assignment exists
        IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            -- Update existing Holiday Assignment
            UPDATE HolidayAssignment SET
                HolidayId = @HolidayId,
                JobCodeId = @JobCodeId,
                UserId = @UserId,
                IsActive = @IsActive,
                EffectiveDate = @EffectiveDate,
                ExpiryDate = @ExpiryDate,
                UpdatedBy = @UserId,
                DateUpdated = GETUTCDATE()
            WHERE Id = @Id AND TenantId = @TenantId
            
            SELECT 
                @Id as id,
                CAST(1 AS bit) as success,
                'Holiday Assignment updated successfully' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        ELSE
        BEGIN
            -- Insert new Holiday Assignment
            INSERT INTO HolidayAssignment (
                TenantId,
                HolidayId,
                JobCodeId,
                UserId,
                IsActive,
                EffectiveDate,
                ExpiryDate,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @HolidayId,
                @JobCodeId,
                @UserId,
                @IsActive,
                @EffectiveDate,
                @ExpiryDate,
                @UserId,
                GETUTCDATE()
            )
            
            SET @Id = SCOPE_IDENTITY()
            
            SELECT 
                @Id as id,
                CAST(1 AS bit) as success,
                'Holiday Assignment created successfully' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN
        
        SELECT 
            CAST(0 AS bit) as success,
            ERROR_MESSAGE() as message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    END CATCH
END
GO

-- =============================================
-- Author: TimeManagement API
-- Create date: 10/9/2025
-- Description: Delete Holiday Assignment
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_HolidayAssignment_Delete]
    @Id int,
    @UserId int,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN
        
        -- Check if Holiday Assignment exists
        IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            -- Delete Holiday Assignment
            DELETE FROM HolidayAssignment 
            WHERE Id = @Id AND TenantId = @TenantId
            
            SELECT 
                CAST(1 AS bit) as success,
                'Holiday Assignment deleted successfully' as message,
                @Id as deletedId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        ELSE
        BEGIN
            SELECT 
                CAST(0 AS bit) as success,
                'Holiday Assignment not found' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN
        
        SELECT 
            CAST(0 AS bit) as success,
            ERROR_MESSAGE() as message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    END CATCH
END
GO
