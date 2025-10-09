USE [TimeManagement_DEV]
GO

-- =============================================
-- Stored Procedures for HolidayAssignment
-- =============================================

-- =============================================
-- Author: TimeManagement API
-- Create date: 10/9/2025
-- Description: Get Holiday Assignments with filters and paging
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_HolidayAssignment_Get]
    @HolidayIds varchar(max) = NULL,
    @JobCodeId int = NULL,
    @UserId int = NULL,
    @PageNumber int = 1,
    @PageSize int = 10,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset int = (@PageNumber - 1) * @PageSize;
    
    -- Build dynamic WHERE clause
    DECLARE @WhereClause nvarchar(max) = 'WHERE TenantId = @TenantId';
    
    IF @HolidayIds IS NOT NULL AND @HolidayIds != ''
    BEGIN
        SET @WhereClause = @WhereClause + ' AND HolidayId IN (SELECT value FROM STRING_SPLIT(@HolidayIds, '',''))';
    END
    
    IF @JobCodeId IS NOT NULL
    BEGIN
        SET @WhereClause = @WhereClause + ' AND JobCodeId = @JobCodeId';
    END
    
    IF @UserId IS NOT NULL
    BEGIN
        SET @WhereClause = @WhereClause + ' AND UserId = @UserId';
    END
    
    -- Get total count
    DECLARE @TotalCount int;
    DECLARE @CountSql nvarchar(max) = 'SELECT @TotalCount = COUNT(*) FROM HolidayAssignment ' + @WhereClause;
    EXEC sp_executesql @CountSql, N'@TenantId int, @HolidayIds varchar(max), @JobCodeId int, @UserId int, @TotalCount int OUTPUT',
        @TenantId, @HolidayIds, @JobCodeId, @UserId, @TotalCount OUTPUT;
    
    -- Get paginated results
    DECLARE @Sql nvarchar(max) = '
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
            jc.JobCode as jobCode,
            jc.JobTitle as jobTitle,
            u.FirstName + '' '' + u.LastName as userName,
            @TotalCount as totalCount
        FROM HolidayAssignment ha
        LEFT JOIN Holidays h ON ha.HolidayId = h.Id AND h.TenantId = @TenantId
        LEFT JOIN JobCodes jc ON ha.JobCodeId = jc.Id AND jc.TenantId = @TenantId
        LEFT JOIN Users u ON ha.UserId = u.Id AND u.TenantId = @TenantId
        ' + @WhereClause + '
        ORDER BY ha.DateCreated DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY';
    
    EXEC sp_executesql @Sql, 
        N'@TenantId int, @HolidayIds varchar(max), @JobCodeId int, @UserId int, @Offset int, @PageSize int, @TotalCount int',
        @TenantId, @HolidayIds, @JobCodeId, @UserId, @Offset, @PageSize, @TotalCount;
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
