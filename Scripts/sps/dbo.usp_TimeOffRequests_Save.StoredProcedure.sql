USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TimeOffRequests_Save]    Script Date: 12/3/2025 8:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Auto Generated
-- Create date: 12/3/2025  
-- Description: [usp_TimeOffRequests_Save] - Save Time Off Request and create Schedule entry
-- =============================================    
CREATE PROCEDURE [dbo].[usp_TimeOffRequests_Save]  
    @Json NVARCHAR(MAX),  
    @UserId INT,  
    @TenantId INT  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        BEGIN TRANSACTION;
        
        DECLARE @Id INT;  
        DECLARE @UserIdParam INT;
        DECLARE @WorkCodeId INT;
        DECLARE @AccrualTypeId INT;
        DECLARE @TimeOffTypeId INT;
        DECLARE @Status INT;
        DECLARE @Notes NVARCHAR(250);
        DECLARE @FromDate DATE;
        DECLARE @FromTime TIME(7);
        DECLARE @ToDate DATE;
        DECLARE @ToTime TIME(7);
        DECLARE @EmployeeIds NVARCHAR(MAX);
        DECLARE @TimeOffRequestId INT;
        DECLARE @startDate DATE;
        DECLARE @EndDate DATE;
        DECLARE @StartTime TIME(7);
        DECLARE @EndTime TIME(7);
        
        -- Parse JSON  
        SELECT   
            @Id = id,
            @UserIdParam = userId,
            @WorkCodeId = workCodeId,
            @AccrualTypeId = accrualTypeId,
            @TimeOffTypeId = timeOffTypeId,
            @Status = ISNULL(status, 1), -- Default to 1 (Pending)
            @Notes = notes,
            @FromDate = fromDate,
            @FromTime = fromTime,
            @ToDate = toDate,
            @ToTime = toTime,
            @EmployeeIds = employeeIds
        FROM OPENJSON(@Json)  
        WITH (  
            id INT,  
            userId INT,
            workCodeId INT,
            accrualTypeId INT,
            timeOffTypeId INT,
            status INT,
            notes NVARCHAR(250),
            fromDate DATE,
            fromTime TIME(7),
            toDate DATE,
            toTime TIME(7),
            employeeIds NVARCHAR(MAX) -- JSON array of employee IDs
        );  
        
        -- Validate required fields
        IF @TimeOffTypeId IS NULL
        BEGIN
            SELECT  
                CAST(0 AS BIT) AS success,  
                'Time off type is required.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            ROLLBACK TRANSACTION;
            RETURN;  
        END
        
        IF @FromDate IS NULL OR @ToDate IS NULL
        BEGIN
            SELECT  
                CAST(0 AS BIT) AS success,  
                'From date and To date are required.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            ROLLBACK TRANSACTION;
            RETURN;  
        END
        
        IF @ToDate < @FromDate
        BEGIN
            SELECT  
                CAST(0 AS BIT) AS success,  
                'To date must be greater than or equal to From date.' AS message  
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
            ROLLBACK TRANSACTION;
            RETURN;  
        END
        
        -- Insert or Update TimeOffRequest
        IF @Id IS NULL OR @Id = 0  
        BEGIN  
            -- Insert new time off request
            IF @UserIdParam IS NOT NULL
            BEGIN
                INSERT INTO TimeOffRequests (
                    TenantId, 
                    UserId, 
                    WorkCodeId, 
                    AccrualTypeId, 
                    TimeOffTypeId, 
                    Status, 
                    Notes, 
                    CreatedBy, 
                    DateCreated
                )  
                VALUES (
                    @TenantId, 
                    @UserIdParam, 
                    @WorkCodeId, 
                    @AccrualTypeId, 
                    @TimeOffTypeId, 
                    @Status, 
                    @Notes, 
                    @UserId, 
                    SYSDATETIMEOFFSET()
                );  
                
                SET @TimeOffRequestId = SCOPE_IDENTITY();
                SET @Id = @TimeOffRequestId;
                
                -- Set date/time variables for schedule
                SET @startDate = @FromDate;
                SET @EndDate = @ToDate;
                SET @StartTime = @FromTime;
                SET @EndTime = @ToTime;
                
                -- Insert Schedule (simple pattern)
                INSERT INTO Schedules (
                    TenantId, 
                    ScheduleName,
                    SourceType,
                    SourceId,
                    StartFrom,
                    ValidUntil,
                    StatusCustomTableValueId,
                    ScheduleType,
                    RepeatEvery,
                    StartTime,
                    EndTime,
                    EndType,
                    Createdby,
                    DateCreated
                )
                VALUES (
                    @TenantId,
                    'Time-Off-Request',
                    4, -- TimeOff
                    @TimeOffRequestId,
                    @startDate,
                    @EndDate,
                    1, -- StatusCustomTableValueId
                    1, -- ScheduleType
                    1, -- RepeatEvery
                    @StartTime,
                    @EndTime,
                    2, -- EndType (on date)
                    @UserId,
                    SYSDATETIMEOFFSET()
                );
            END
            ELSE IF @EmployeeIds IS NOT NULL
            BEGIN
                -- Handle multiple employees - create a request for each
                DECLARE @EmployeeId INT;
                DECLARE @FirstId INT = NULL;
                
                -- Insert for each employee
                DECLARE employee_cursor CURSOR FOR
                SELECT CAST(value AS INT)
                FROM OPENJSON(@EmployeeIds)
                
                OPEN employee_cursor;
                FETCH NEXT FROM employee_cursor INTO @EmployeeId;
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    INSERT INTO TimeOffRequests (
                        TenantId, 
                        UserId, 
                        WorkCodeId, 
                        AccrualTypeId, 
                        TimeOffTypeId, 
                        Status, 
                        Notes, 
                        CreatedBy, 
                        DateCreated
                    )  
                    VALUES (
                        @TenantId, 
                        @EmployeeId, 
                        @WorkCodeId, 
                        @AccrualTypeId, 
                        @TimeOffTypeId, 
                        @Status, 
                        @Notes, 
                        @UserId, 
                        SYSDATETIMEOFFSET()
                    );
                    
                    SET @TimeOffRequestId = SCOPE_IDENTITY();
                    
                    IF @FirstId IS NULL
                        SET @FirstId = @TimeOffRequestId;
                    
                    -- Set date/time variables for schedule
                    SET @startDate = @FromDate;
                    SET @EndDate = @ToDate;
                    SET @StartTime = @FromTime;
                    SET @EndTime = @ToTime;
                    
                    -- Insert Schedule (simple pattern)
                    INSERT INTO Schedules (
                        TenantId, 
                        ScheduleName,
                        SourceType,
                        SourceId,
                        StartFrom,
                        ValidUntil,
                        StatusCustomTableValueId,
                        ScheduleType,
                        RepeatEvery,
                        StartTime,
                        EndTime,
                        EndType,
                        Createdby,
                        DateCreated
                    )
                    VALUES (
                        @TenantId,
                        'Time-Off-Request',
                        4, -- TimeOff
                        @TimeOffRequestId,
                        @startDate,
                        @EndDate,
                        1, -- StatusCustomTableValueId
                        1, -- ScheduleType
                        1, -- RepeatEvery
                        @StartTime,
                        @EndTime,
                        2, -- EndType (on date)
                        @UserId,
                        SYSDATETIMEOFFSET()
                    );
                    
                    FETCH NEXT FROM employee_cursor INTO @EmployeeId;
                END
                
                CLOSE employee_cursor;
                DEALLOCATE employee_cursor;
                
                SET @Id = @FirstId; -- Return the first ID created
            END
            ELSE
            BEGIN
                SELECT  
                    CAST(0 AS BIT) AS success,  
                    'User ID or Employee IDs are required.' AS message  
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END  
        ELSE  
        BEGIN  
            -- Update existing time off request
            UPDATE TimeOffRequests  
            SET   
                UserId = ISNULL(@UserIdParam, UserId),
                WorkCodeId = @WorkCodeId,
                AccrualTypeId = @AccrualTypeId,
                TimeOffTypeId = @TimeOffTypeId,
                Status = @Status,
                Notes = @Notes,
                UpdatedBy = @UserId,  
                DateUpdated = SYSDATETIMEOFFSET()  
            WHERE Id = @Id AND TenantId = @TenantId;  
            
            IF @@ROWCOUNT = 0  
            BEGIN  
                ROLLBACK TRANSACTION;
                SELECT  
                    CAST(0 AS BIT) AS success,  
                    'Time off request not found or unauthorized.' AS message  
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;  
                RETURN;  
            END
            
            -- Set date/time variables for schedule
            SET @startDate = @FromDate;
            SET @EndDate = @ToDate;
            SET @StartTime = @FromTime;
            SET @EndTime = @ToTime;
            
            -- Update existing Schedule by SourceType & SourceId, or insert if not exists
            IF EXISTS (
                SELECT 1 
                FROM Schedules 
                WHERE SourceType = 4 AND SourceId = @Id AND TenantId = @TenantId
            )
            BEGIN
                UPDATE Schedules
                SET StartFrom = @startDate,
                    ValidUntil = @EndDate,
                    StartTime = @StartTime,
                    EndTime = @EndTime,
                    UpdatedBy = @UserId,
                    DateUpdated = SYSDATETIMEOFFSET()
                WHERE SourceType = 4 
                  AND SourceId = @Id 
                  AND TenantId = @TenantId;
            END
            ELSE
            BEGIN
                INSERT INTO Schedules (
                    TenantId, 
                    ScheduleName,
                    SourceType,
                    SourceId,
                    StartFrom,
                    ValidUntil,
                    StatusCustomTableValueId,
                    ScheduleType,
                    RepeatEvery,
                    StartTime,
                    EndTime,
                    EndType,
                    Createdby,
                    DateCreated
                )
                VALUES (
                    @TenantId,
                    'Time-Off-Request',
                    4, -- TimeOff
                    @Id,
                    @startDate,
                    @EndDate,
                    1, -- StatusCustomTableValueId
                    1, -- ScheduleType
                    1, -- RepeatEvery
                    @StartTime,
                    @EndTime,
                    2, -- EndType (on date)
                    @UserId,
                    SYSDATETIMEOFFSET()
                );
            END
        END  
        
        COMMIT TRANSACTION;  
  
        -- Return success with the time off request Id  
        SELECT  
            @Id AS id,  
            CAST(1 AS BIT) AS success,  
            'Time off request saved successfully.' AS message  
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
