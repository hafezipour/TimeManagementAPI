/* ----- dbo.Create_Insert_Script_Of.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO

/* ----- dbo.usp_AccrualTypes_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_Get]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get Accrual Types
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_Get]
    @AccrualTypeId INT = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Id AS id,
        a.TypeCode AS typeCode,
        a.TypeName AS typeName,
        a.Description AS description,
        a.CustomTableUnitId AS customTableUnitId,
        unit.CustomTableID AS customTableId,
        unit.LongDescription AS customTableUnitName,
        unit.ShortDescription AS customTableUnitShortName,
        a.IsActive AS isActive,
        a.CreatedBy AS createdBy,
        a.UpdatedBy AS updatedBy,
        a.DateCreated AS dateCreated,
        a.DateUpdated AS dateUpdated
    FROM AccrualTypes a
    LEFT JOIN CustomTableValues unit WITH (NOLOCK) ON unit.CustomTableValueID = a.CustomTableUnitId
    WHERE a.TenantId = @TenantId
      AND (@AccrualTypeId IS NULL OR a.Id = @AccrualTypeId)
    ORDER BY a.TypeName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_AccrualTypes_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_Save]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Insert/Update Accrual Types
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_Save]
    @Json VARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Id INT;
        DECLARE @TypeCode VARCHAR(55);
        DECLARE @TypeName VARCHAR(255);
        DECLARE @Description NVARCHAR(MAX);
        DECLARE @CustomTableUnitId INT;
        DECLARE @IsActive BIT;

        SELECT
            @Id = id,
            @TypeCode = typeCode,
            @TypeName = typeName,
            @Description = description,
            @CustomTableUnitId = customTableUnitId,
            @IsActive = ISNULL(isActive, 1)
        FROM OPENJSON(@Json) WITH (
            id INT,
            typeCode VARCHAR(55),
            typeName VARCHAR(255),
            description NVARCHAR(MAX),
            customTableUnitId INT,
            isActive BIT
        );

        IF (@TypeCode IS NULL OR LTRIM(RTRIM(@TypeCode)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Code is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@TypeName IS NULL OR LTRIM(RTRIM(@TypeName)) = '')
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM AccrualTypes
            WHERE TenantId = @TenantId
              AND TypeCode = @TypeCode
              AND Id <> ISNULL(@Id, 0)
        )
        BEGIN
            SELECT CAST(0 AS BIT) AS success, 'Type Code already exists for this tenant.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM AccrualTypes WHERE Id = ISNULL(@Id, 0) AND TenantId = @TenantId)
        BEGIN
            UPDATE AccrualTypes
            SET
                TypeCode = @TypeCode,
                TypeName = @TypeName,
                Description = @Description,
                CustomTableUnitId = @CustomTableUnitId,
                IsActive = @IsActive,
                UpdatedBy = @UserId,
                DateUpdated = SYSUTCDATETIME()
            WHERE Id = @Id AND TenantId = @TenantId;

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual type updated successfully.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        END
        ELSE
        BEGIN
            INSERT INTO AccrualTypes (
                TenantId,
                TypeCode,
                TypeName,
                Description,
                CustomTableUnitId,
                IsActive,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @TypeCode,
                @TypeName,
                @Description,
                @CustomTableUnitId,
                @IsActive,
                @UserId,
                SYSUTCDATETIME()
            );

            SET @Id = SCOPE_IDENTITY();

            SELECT @Id AS id, CAST(1 AS BIT) AS success, 'Accrual type created successfully.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_AccrualTypes_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_Delete]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Delete Accrual Type
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_Delete]
    @AccrualTypeId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM AccrualTypes
        WHERE Id = @AccrualTypeId
          AND TenantId = @TenantId;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Accrual type not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        SELECT
            CAST(1 AS BIT) AS success,
            'Accrual type deleted successfully.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        SELECT
            CAST(0 AS BIT) AS success,
            ERROR_MESSAGE() AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_AccrualTypes_UpdateActiveStatus.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_UpdateActiveStatus]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Update active flag for Accrual Type
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_UpdateActiveStatus]
    @AccrualTypeId INT,
    @IsActive BIT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE AccrualTypes
    SET
        IsActive = @IsActive,
        UpdatedBy = @UserId,
        DateUpdated = SYSUTCDATETIME()
    WHERE Id = @AccrualTypeId
      AND TenantId = @TenantId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS success,
            'Accrual type not found.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        RETURN;
    END

    SELECT
        CAST(1 AS BIT) AS success,
        CONCAT('Accrual type ', CASE WHEN @IsActive = 1 THEN 'activated' ELSE 'deactivated' END, ' successfully.') AS message
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

/* ----- dbo.usp_CustomTableValues_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_CustomTableValues_GetShortList]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get short list of custom table values
-- =============================================
CREATE   PROCEDURE [dbo].[usp_CustomTableValues_GetShortList]
    @CustomTableId INT = NULL,
    @TenantId INT,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.CustomTableValueID AS id,
        v.CustomTableID AS customTableId,
        t.Name AS customTableName,
        v.Code AS code,
        v.ShortDescription AS shortDescription,
        v.LongDescription AS longDescription,
        v.IsActive AS isActive
    FROM CustomTableValues v
    INNER JOIN CustomTables t ON t.CustomTableID = v.CustomTableID
    WHERE (@CustomTableId IS NULL OR v.CustomTableID = @CustomTableId)
      AND (@IncludeInactive = 1 OR ISNULL(v.IsActive, 1) = 1)
      AND (t.TenantId IS NULL OR t.TenantId = @TenantId)
      AND (v.TenantId IS NULL OR v.TenantId = @TenantId)
    ORDER BY t.Name, v.LongDescription, v.ShortDescription
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO
/****** Object:  StoredProcedure [dbo].[Create_Insert_Script_Of]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[Create_Insert_Script_Of] 
(@schema varchar(50), @tableName varchar(100), @condition as nvarchar(2000)) as
--Declare a cursor to retrieve column specific information 

--for the specified table
--SET CONCAT_NULL_YIELDS_NULL  OFF 

DECLARE cursCol CURSOR FAST_FORWARD FOR 
SELECT column_name, data_type FROM information_schema.columns 
    WHERE table_name = @tableName and Table_Schema = @schema
OPEN cursCol
DECLARE @string nvarchar(3000) --for storing the first half 

                               --of INSERT statement

DECLARE @stringData nvarchar(3000) --for storing the data 

                                   --(VALUES) related statement

DECLARE @dataType nvarchar(1000) --data types returned 

                                 --for respective columns

SET @string='INSERT ['+ @schema + '].[' + @tableName+']('
SET @stringData=''

DECLARE @colName nvarchar(50)

FETCH NEXT FROM cursCol INTO @colName, @dataType

IF @@fetch_status <> 0
    begin
    print 'Table [' + @schema + '].[' + @tableName + '] not found, processing skipped.'
    close curscol
    deallocate curscol
    return
END

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @dataType in ('varchar','char','nchar','nvarchar')
		BEGIN
			SET @stringData = @stringData + ''''''''' + isnull(' + @colName + ',''null'')+'''''',''+'
		END
	ELSE IF @dataType in ('text','ntext') --if the datatype 
		BEGIN
			SET @stringData = @stringData + ''''''''' + IsNull(cast(' + @colName + ' as varchar(2000)),''null'')+'''''',''+'
		END
	ELSE IF @dataType = 'money' --because money doesn't get converted  --from varchar implicitly
		BEGIN
			SET @stringData = @stringData + '''convert(money,''''''+ isnull(cast(' + @colName + ' as varchar(200)),''null'')+''''''),''+'
		END
	ELSE IF @dataType='datetime'
		BEGIN
			SET @stringData = @stringData+'''convert(datetime,'''''' + IsNull(Cast(' + @colName + ' AS VARCHAR(200)),''null'')+''''''),''+'
		END
	ELSE IF @dataType='image' 
		BEGIN
			SET @stringData = @stringData + '''''''''+ IsNull(cast(convert(varbinary,' + @colName + ') AS VARCHAR(6)),''null'')+'''''',''+'
		END
	ELSE --presuming the data type is int,bit,numeric,decimal 
		BEGIN
			SET @stringData = @stringData + '''''''''+ IsNull(Cast(' + @colName + ' AS VARCHAR(200)),''null'')+'''''',''+'
		END

	SET @string = @string + @colName + ','

	FETCH NEXT FROM cursCol INTO @colName,@dataType
END
DECLARE @Query nvarchar(4000) -- provide for the whole query, 

                              -- you may increase the size


SET @query ='SELECT ''' + Substring(@string, 0, Len(@string)) + ') 
    VALUES(''+ ' + Substring(@stringData, 0, Len(@stringData) - 2) + '''+'')'' 
    FROM ['+ @schema + '].[' + @tableName + '] ' + @condition
--print @query
exec sp_executesql @query --load and run the built query
CLOSE cursCol
DEALLOCATE cursCol

--SET CONCAT_NULL_YIELDS_NULL  ON
GO

/* ----- dbo.fn_GetShiftData.UserDefinedFunction.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetShiftData]    Script Date: 11/11/2025 7:54:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. UPDATE FUNCTION: fn_GetShiftData
-- =============================================
-- Add workCodes and jobCodes subqueries to return arrays of assigned codes
-- =============================================

CREATE FUNCTION [dbo].[fn_GetShiftData]
(
    @TenantId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.Id as id,
        s.ShiftName as shiftName,
        s.ShiftCode as shiftCode,
        s.MinimumPositions as minimumPositions,
        s.MaxTimeOffs as maxTimeOffs,
        s.Location as location,
        s.IsWorkShift as isWorkShift,
        s.IsSelfSchedulingEnabled as isSelfSchedulingEnabled,
        s.IsSelfSchedulingRequiresAdminApprovals as isSelfSchedulingRequiresAdminApprovals,
        s.IsHideOpenSlots as isHideOpenSlots,
        s.ShiftLabelId as shiftLabelId,
        l.labelName,
        l.labelCode,
        l.colorCode,
        s.BackgroundColour as backgroundColour,
        s.IsActive as isActive,
        s.CreatedBy as createdBy,
        s.UpdatedBy as updatedBy,
        s.DateCreated as dateCreated,
        s.DateUpdated as dateUpdated,
        s.DisplayOrder as displayOrder,
        s.StatusCustomTableValueId as statusCustomTableValueId,
        ss.id as scheduleId,
        ss.scheduleWithoutTimes,
        ss.startFrom as scheduleStartFrom,
        ss.startTime as scheduleStartTime,
        ss.scheduleType,
        -- ShiftGroupAssignments subquery (existing)
        (
            select 
                a.id,
                a.shiftId,
                a.groupId,
                g.groupName,
                g.colorCode
            from ShiftGroupAssignment a
            inner join Groups g on g.Id = a.groupId and g.isActive = 1
            where 
                    a.ShiftId = s.Id 
                and a.TenantId = @TenantId
            for json path, include_null_values
        ) as shiftGroupAssignments,
        -- *** NEW: WorkCodes subquery ***
        (
            select 
                wc.Id as id,
                wc.WorkCodeName as workCodeName,
                wc.WorkCode as workCode,
                wc.ColorCode as colorCode,
                wc.IsActive as isActive
            from ShiftWorkCodeAssignment swca
            inner join WorkCodes wc on wc.Id = swca.WorkCodeId and wc.IsActive = 1
            where 
                    swca.ShiftId = s.Id 
                and swca.TenantId = @TenantId
            for json path, include_null_values
        ) as workCodes,
        -- *** NEW: JobCodes subquery ***
        (
            select 
                jc.Id as id,
                jc.JobTitle as jobTitle,
                jc.JobCode as jobCode,
                jc.IsActive as isActive
            from ShiftJobCodeAssignment sjca
            inner join JobCodes jc on jc.Id = sjca.JobCodeId and jc.IsActive = 1
            where 
                    sjca.ShiftId = s.Id 
                and sjca.TenantId = @TenantId
            for json path, include_null_values
        ) as jobCodes
        -- *** END NEW ***
    FROM Shifts s
    Left Join Labels l on l.id = s.ShiftLabelId
    LEFT JOIN Schedules ss on ss.SourceId = s.Id and ss.SourceType = 1
    WHERE s.TenantId = @TenantId
)
GO

/* ----- dbo.Sp_SaveDbOperationsAnalytics.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[Sp_SaveDbOperationsAnalytics]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ali Nafees
-- Create date: 8/30/2023
-- Description:	This is used to save the logging of query db operations going on
-- =============================================
CREATE   PROCEDURE [dbo].[Sp_SaveDbOperationsAnalytics] 
	@Json varchar(max)
AS
BEGIN
	INSERT INTO DbOperationsAnalytics(StoredProcedureName,TimeSpent,Query,ProcParams,AdditionalQuery,Project,StartedOn,FinishedOn,UserId,RoleId,TenantId,
	IsWindowService)
	SELECT StoredProcedureName,TimeSpent,Query,ProcParams,AdditionalQuery,Project,StartedOn,FinishedOn,UserId,RoleId,TenantId,IsWindowService 
	FROM OPENJSON(@Json) WITH (
		 StoredProcedureName nvarchar(500)
		,TimeSpent time(7)
		,Query nvarchar(MAX)
		,ProcParams nvarchar(MAX)
		,AdditionalQuery nvarchar(MAX)
		,Project nvarchar(MAX)
		,StartedOn datetimeOFFSET(7)
		,FinishedOn datetimeOFFSET(7)
		,UserId int
		,RoleId int
		,TenantId int
		,IsWindowService bit
	) J
	select cast(1 AS bit) Success
END
GO

/* ----- dbo.Sp_SearchInsideStoredProcedures.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[Sp_SearchInsideStoredProcedures]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Nafees
-- Create date: 11/17/2023
-- Description:	To search text inside stored procedures
-- =============================================
CREATE   PROCEDURE [dbo].[Sp_SearchInsideStoredProcedures] --'ResidentDiagnosis' 
	@string AS NVARCHAR(500)
AS
BEGIN
	SELECT	DISTINCT
			o.name AS Object_Name,
			o.type_desc
	FROM	sys.sql_modules m
			INNER JOIN sys.objects o ON m.object_id = o.object_id
	WHERE	m.definition Like '%'+@string+'%' ESCAPE '\'
END
GO

/* ----- dbo.usp_AssistantQualifiers_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AssistantQualifiers_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AssistantQualifiers_Delete]
    @Id INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete the assistant qualifier
        DELETE FROM AssisstantQualifiers
        WHERE Id = @Id
            AND TenantId = @TenantId;

        -- Check if any rows were affected
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT
                CAST(0 AS BIT) AS success,
                'Assistant qualifier not found or already deleted.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            CAST(1 AS BIT) AS success,
            'Assistant qualifier deleted successfully.' AS message
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

/* ----- dbo.usp_AssistantQualifiers_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AssistantQualifiers_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AssistantQualifiers_Get]
	@Id int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'Name',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	;WITH _rows AS (
		SELECT 
			aq.Id as id,
			aq.TenantId as tenantId,
			aq.Name as name,
			aq.Code as code,
			aq.Description as description,
			aq.BackgroundColor as backgroundColor,
			aq.TextColor as textColor,
			aq.IsActive as isActive,
			aq.CreatedBy as createdBy,
			aq.UpdatedBy as updatedBy,
			aq.DateCreated as dateCreated,
			aq.DateUpdated as dateUpdated
		FROM AssisstantQualifiers aq
		WHERE aq.TenantId = @TenantId
			AND (@Id IS NULL OR aq.Id = @Id)
			AND (
				@SearchTerm IS NULL OR 
				aq.Name LIKE '%' + @SearchTerm + '%' OR 
				aq.Code LIKE '%' + @SearchTerm + '%' OR 
				aq.Description LIKE '%' + @SearchTerm + '%'
			)
	)
	SELECT 
		_rows.id,
		_rows.tenantId,
		_rows.name,
		_rows.code,
		_rows.description,
		_rows.backgroundColor,
		_rows.textColor,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		(SELECT count(_rows.id) from _rows) as totalCount
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'ASC' THEN _rows.name END ASC,
		CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'DESC' THEN _rows.name END DESC,
		CASE WHEN @SortColumn = 'Code' AND @SortDirection = 'ASC' THEN _rows.code END ASC,
		CASE WHEN @SortColumn = 'Code' AND @SortDirection = 'DESC' THEN _rows.code END DESC,
		_rows.name ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_AssistantQualifiers_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AssistantQualifiers_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AssistantQualifiers_GetShortList]
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            aq.id,
            aq.name,
            aq.code,
            aq.backgroundColor,
            aq.textColor,
            aq.isActive
        FROM AssisstantQualifiers aq
        WHERE aq.TenantId = @TenantId
            AND ISNULL(aq.IsActive, 1) = 1
        ORDER BY aq.Name ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            CAST(0 AS BIT) AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_AssistantQualifiers_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AssistantQualifiers_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AssistantQualifiers_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Id INT;
        DECLARE @Name VARCHAR(100);
        DECLARE @Code VARCHAR(55);
        DECLARE @Description NVARCHAR(MAX);
        DECLARE @BackgroundColor VARCHAR(7);
        DECLARE @TextColor VARCHAR(7);
        DECLARE @IsActive BIT;

        -- Parse JSON
        SELECT 
            @Id = Id,
            @Name = Name,
            @Code = Code,
            @Description = Description,
            @BackgroundColor = BackgroundColor,
            @TextColor = TextColor,
            @IsActive = ISNULL(IsActive, 1)
        FROM OPENJSON(@Json)
        WITH (
            id INT,
            name VARCHAR(100),
            code VARCHAR(55),
            description NVARCHAR(MAX),
            backgroundColor VARCHAR(7),
            textColor VARCHAR(7),
            isActive BIT
        );

        -- Validate required fields (BEFORE starting transaction)
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        IF @Code IS NULL OR LTRIM(RTRIM(@Code)) = ''
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Code is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check for duplicate name (excluding current record if updating)
        IF EXISTS (
            SELECT 1 
            FROM AssisstantQualifiers 
            WHERE Name = @Name 
                AND TenantId = @TenantId 
                AND (@Id IS NULL OR Id != @Id)
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'An assistant qualifier with this name already exists.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check for duplicate code (excluding current record if updating)
        IF EXISTS (
            SELECT 1 
            FROM AssisstantQualifiers 
            WHERE Code = @Code 
                AND TenantId = @TenantId 
                AND (@Id IS NULL OR Id != @Id)
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'An assistant qualifier with this code already exists.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- All validations passed, now start transaction
        BEGIN TRANSACTION;

        -- Insert or Update
        IF @Id IS NULL OR @Id = 0
        BEGIN
            -- Insert new qualifier
            INSERT INTO AssisstantQualifiers (TenantId, Name, Code, Description, BackgroundColor, TextColor, IsActive, CreatedBy, DateCreated)
            VALUES (@TenantId, @Name, @Code, @Description, @BackgroundColor, @TextColor, @IsActive, @UserId, SYSDATETIMEOFFSET());

            SET @Id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Update existing qualifier
            UPDATE AssisstantQualifiers
            SET 
                Name = @Name,
                Code = @Code,
                Description = @Description,
                BackgroundColor = @BackgroundColor,
                TextColor = @TextColor,
                IsActive = @IsActive,
                UpdatedBy = @UserId,
                DateUpdated = SYSDATETIMEOFFSET()
            WHERE Id = @Id AND TenantId = @TenantId;

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT
                    CAST(0 AS BIT) AS success,
                    'Assistant qualifier not found or unauthorized.' AS message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                RETURN;
            END
        END

        COMMIT TRANSACTION;

        -- Return success with the qualifier Id
        SELECT
            @Id AS id,
            CAST(1 AS BIT) AS success,
            'Assistant qualifier saved successfully.' AS message
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

/* ----- dbo.usp_Columns_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Columns_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Delete Column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Columns_Delete]
    @Id INT,
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Id IS NULL OR @Id <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid Id parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Check if column exists and belongs to tenant
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE [Id] = @Id AND [TenantId] = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found or access denied"}' as Result
            RETURN
        END

        -- Check if column is being used in LayoutGridColumns
        IF EXISTS (SELECT 1 FROM [dbo].[LayoutGridColumns] WHERE [ColumnId] = @Id AND [TenantId] = @TenantId)
        BEGIN
            Delete from [LayoutGridColumns] where [ColumnId] = @Id AND [TenantId] = @TenantId
            --SELECT '{"success": false, "message": "Cannot delete column as it is being used in layout grid"}' as Result
            --RETURN
        END

        -- Delete the column
        DELETE FROM [dbo].[Columns]
        WHERE [Id] = @Id 
        AND [TenantId] = @TenantId

        SELECT '{"success": true, "message": "Column deleted successfully", "deletedId": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_Columns_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Columns_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get all columns for a tenant that are NOT already assigned to a specific layout
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Columns_Get]
    @TenantId INT,
    @LayoutId INT = NULL
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameter
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Get columns for the tenant that are NOT already assigned to the specified layout
        SELECT 
            [Id] as [id],
            [ColumnName] as [columnName],
            [BackgroundColor] as [backgroundColor],
            [TenantId] as [tenantId],
            [CreatedBy] as [createdBy],
            [UpdatedBy] as [updatedBy],
            [DateCreated] as [dateCreated],
            [DateUpdated] as [dateUpdated],
			(
				SELECT 
					lg.rowNumber,
					lg.columnNumber,
					lg.columnId,
					lg.displayOrder,
					cc.columnName,
					cc.backgroundColor
				FROM LayoutGridColumns lg
				INNER JOIN Columns cc ON lg.ColumnId = cc.Id AND cc.TenantId = @TenantId AND lg.ColumnId = c.Id
				WHERE lg.LayoutId = @LayoutId 
				  AND lg.TenantId = @TenantId
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) as gridColumns,
            (
				SELECT 
					cs.Id as columnShiftId,
                    cs.shiftId,
                    cs.columnId,
                    cs.displayOrder
				FROM ColumnShifts cs
				WHERE cs.LayoutId = @LayoutId 
				  AND cs.TenantId = @TenantId
                  AND cs.ColumnId = c.Id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) as columnShifts
        FROM [dbo].[Columns] c
        WHERE [TenantId] = @TenantId
        ORDER BY [ColumnName]
		FOR JSON PATH, INCLUDE_NULL_VALUES

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_Columns_GetById.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Columns_GetById]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get column by ID
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Columns_GetById]
    @Id INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Id IS NULL OR @Id <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid Id parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Get column by ID and tenant
        SELECT 
            [Id] as [id],
            [ColumnName] as [columnName],
            [BackgroundColor] as [backgroundColor],
            [TenantId] as [tenantId],
            [CreatedBy] as [createdBy],
            [UpdatedBy] as [updatedBy],
            [DateCreated] as [dateCreated],
            [DateUpdated] as [dateUpdated]
        FROM [dbo].[Columns]
        WHERE [Id] = @Id AND [TenantId] = @TenantId
		FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
        END

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_Columns_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Columns_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Save Column (Insert/Update)
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Columns_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        DECLARE @Id INT = NULL
        DECLARE @ColumnName NVARCHAR(50) = NULL
        DECLARE @BackgroundColor NVARCHAR(7) = NULL

        -- Parse JSON parameters
        SELECT 
            @Id = JSON_VALUE(@Json, '$.id'),
            @ColumnName = JSON_VALUE(@Json, '$.columnName'),
            @BackgroundColor = JSON_VALUE(@Json, '$.backgroundColor')

        -- Validate required parameters
        IF @ColumnName IS NULL OR LEN(TRIM(@ColumnName)) = 0
        BEGIN
            SELECT '{"success": false, "message": "ColumnName is required"}' as Result
            RETURN
        END

        -- Check if this is an update (Id provided) or insert (Id is null)
        IF @Id IS NOT NULL
        BEGIN
            -- Update existing column
            UPDATE [dbo].[Columns]
            SET 
                [ColumnName] = @ColumnName,
                [BackgroundColor] = @BackgroundColor,
                [UpdatedBy] = @UserId,
                [DateUpdated] = GETUTCDATE()
            WHERE [Id] = @Id 
            AND [TenantId] = @TenantId

            IF @@ROWCOUNT = 0
            BEGIN
                SELECT '{"success": false, "message": "Column not found or access denied"}' as Result
                RETURN
            END

            SELECT '{"success": true, "message": "Column updated successfully", "id": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result
        END
        ELSE
        BEGIN
            -- Insert new column
            INSERT INTO [dbo].[Columns] (
                [ColumnName],
                [BackgroundColor],
                [TenantId],
                [CreatedBy],
                [DateCreated],
                [UpdatedBy],
                [DateUpdated]
            )
            VALUES (
                @ColumnName,
                @BackgroundColor,
                @TenantId,
                @UserId,
                GETUTCDATE(),
                NULL,
                NULL
            )

            SET @Id = SCOPE_IDENTITY()

            SELECT '{"success": true, "message": "Column created successfully", "id": ' + CAST(@Id AS NVARCHAR(10)) + '}' as Result
        END

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_ColumnShifts_BatchUpdateOrder.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_BatchUpdateOrder]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/28/2025
DESCRIPTION			: Batch update shift display orders for a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_ColumnShifts_BatchUpdateOrder]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Json IS NULL OR @Json = ''
        BEGIN
            SELECT '{"success": false, "message": "Invalid JSON parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Parse JSON and extract values
        DECLARE @ColumnId INT = JSON_VALUE(@Json, '$.columnId')
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId')

        -- Validate parsed values
        IF @ColumnId IS NULL OR @ColumnId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ColumnId in JSON"}' as Result
            RETURN
        END

        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId in JSON"}' as Result
            RETURN
        END

        -- Check if the column exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE Id = @ColumnId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
            RETURN
        END

        -- Check if the layout exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Layouts] WHERE Id = @LayoutId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Layout not found"}' as Result
            RETURN
        END

        -- Create a temporary table to hold the shift updates
        CREATE TABLE #ShiftUpdates (
            ShiftId INT,
            DisplayOrder INT
        )

        -- Parse the shifts array from JSON
        INSERT INTO #ShiftUpdates (ShiftId, DisplayOrder)
        SELECT 
            JSON_VALUE(value, '$.shiftId') as ShiftId,
            JSON_VALUE(value, '$.displayOrder') as DisplayOrder
        FROM OPENJSON(@Json, '$.shifts')

        -- Validate that all shifts exist
        IF EXISTS (
            SELECT 1 
            FROM #ShiftUpdates su
            WHERE NOT EXISTS (
                SELECT 1 
                FROM [dbo].[Shifts] s
                WHERE s.Id = su.ShiftId AND s.TenantId = @TenantId
            )
        )
        BEGIN
            DROP TABLE #ShiftUpdates
            SELECT '{"success": false, "message": "One or more shifts not found"}' as Result
            RETURN
        END

        -- Begin transaction for batch update
        BEGIN TRANSACTION

        -- Update display orders for all shifts in the batch
        UPDATE cs
        SET 
            cs.DisplayOrder = su.DisplayOrder,
            cs.UpdatedBy = @UserId,
            cs.DateUpdated = GETDATE()
        FROM [dbo].[ColumnShifts] cs
        INNER JOIN #ShiftUpdates su ON cs.ShiftId = su.ShiftId
        WHERE cs.ColumnId = @ColumnId
          AND cs.LayoutId = @LayoutId
          AND cs.TenantId = @TenantId

        -- Get the count of updated records
        DECLARE @UpdatedCount INT = @@ROWCOUNT

        COMMIT TRANSACTION

        -- Clean up temporary table
        DROP TABLE #ShiftUpdates

        -- Return success message with count
        SELECT '{"success": true, "message": "Shift orders updated successfully", "updatedCount": ' + CAST(@UpdatedCount AS NVARCHAR(10)) + '}' as Result

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        -- Clean up temporary table if it exists
        IF OBJECT_ID('tempdb..#ShiftUpdates') IS NOT NULL
            DROP TABLE #ShiftUpdates

        -- Return error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        SELECT '{"success": false, "message": "Error updating shift orders: ' + @ErrorMessage + '"}' as Result
    END CATCH
END
GO

/* ----- dbo.usp_ColumnShifts_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/28/2025
DESCRIPTION			: Delete a shift from a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_ColumnShifts_Delete]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Json IS NULL OR @Json = ''
        BEGIN
            SELECT '{"success": false, "message": "Invalid JSON parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Parse JSON and extract values
        DECLARE @ColumnId INT = JSON_VALUE(@Json, '$.columnId')
        DECLARE @ShiftId INT = JSON_VALUE(@Json, '$.shiftId')
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId')

        -- Validate parsed values
        IF @ColumnId IS NULL OR @ColumnId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ColumnId in JSON"}' as Result
            RETURN
        END

        IF @ShiftId IS NULL OR @ShiftId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ShiftId in JSON"}' as Result
            RETURN
        END

        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId in JSON"}' as Result
            RETURN
        END

        -- Check if the column shift exists
        IF NOT EXISTS (
            SELECT 1 
            FROM [dbo].[ColumnShifts] 
            WHERE ColumnId = @ColumnId 
              AND ShiftId = @ShiftId 
              AND LayoutId = @LayoutId 
              AND TenantId = @TenantId
        )
        BEGIN
            SELECT '{"success": false, "message": "Column shift not found"}' as Result
            RETURN
        END

        -- Delete the column shift
        DELETE FROM [dbo].[ColumnShifts]
        WHERE ColumnId = @ColumnId 
          AND ShiftId = @ShiftId 
          AND LayoutId = @LayoutId 
          AND TenantId = @TenantId

        -- Return success message
        SELECT '{"success": true, "message": "Shift successfully removed from column"}' as Result

    END TRY
    BEGIN CATCH
        -- Return error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        SELECT '{"success": false, "message": "Error deleting shift from column: ' + @ErrorMessage + '"}' as Result
    END CATCH
END
GO

/* ----- dbo.usp_ColumnShifts_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ColumnShifts_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/22/2025
DESCRIPTION			: Save shift assignment to a column
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_ColumnShifts_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameters
        IF @Json IS NULL OR @Json = ''
        BEGIN
            SELECT '{"success": false, "message": "Invalid JSON parameter"}' as Result
            RETURN
        END

        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Parse JSON and extract values
        DECLARE @ColumnId INT = JSON_VALUE(@Json, '$.columnId')
        DECLARE @ShiftId INT = JSON_VALUE(@Json, '$.shiftId')
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId')
        DECLARE @DisplayOrder INT = ISNULL(JSON_VALUE(@Json, '$.displayOrder'), 0)

        -- Validate parsed values
        IF @ColumnId IS NULL OR @ColumnId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ColumnId in JSON"}' as Result
            RETURN
        END

        IF @ShiftId IS NULL OR @ShiftId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid ShiftId in JSON"}' as Result
            RETURN
        END

        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId in JSON"}' as Result
            RETURN
        END

        -- Check if the column exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Columns] WHERE Id = @ColumnId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Column not found"}' as Result
            RETURN
        END

        -- Check if the shift exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Shifts] WHERE Id = @ShiftId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Shift not found"}' as Result
            RETURN
        END

        -- Check if the layout exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Layouts] WHERE Id = @LayoutId AND TenantId = @TenantId)
        BEGIN
            SELECT '{"success": false, "message": "Layout not found"}' as Result
            RETURN
        END

        -- Check if this shift is already assigned to any column in this layout
        IF EXISTS (SELECT 1 FROM [dbo].[ColumnShifts] 
                   WHERE ShiftId = @ShiftId 
                     AND LayoutId = @LayoutId 
                     AND TenantId = @TenantId)
        BEGIN
            -- Update existing assignment to new column
            UPDATE [dbo].[ColumnShifts] 
            SET [ColumnId] = @ColumnId,
                [DisplayOrder] = @DisplayOrder,
                [UpdatedBy] = @UserId,
                [DateUpdated] = GETDATE()
            WHERE ShiftId = @ShiftId 
              AND LayoutId = @LayoutId 
              AND TenantId = @TenantId

            SELECT '{"success": true, "message": "Shift successfully moved to new column"}' as Result
        END
        ELSE
        BEGIN
            -- Insert new shift assignment
            INSERT INTO [dbo].[ColumnShifts] (
                [ColumnId],
                [ShiftId],
                [LayoutId],
                [DisplayOrder],
                [TenantId],
                [CreatedBy],
                [DateCreated]
            )
            VALUES (
                @ColumnId,
                @ShiftId,
                @LayoutId,
                @DisplayOrder,
                @TenantId,
                @UserId,
                GETDATE()
            )

            SELECT '{"success": true, "message": "Shift successfully assigned to column"}' as Result
        END

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

/* ----- dbo.usp_EmployeeAvailability_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAvailability_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeAvailability_Get]
    @UserId INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Id AS id,
        s.ScheduleName AS scheduleName,
        @UserId AS userId,
        s.StartDate AS [date],
        DATENAME(WEEKDAY, s.StartDate) AS dayOfWeek,
        CONVERT(VARCHAR(8), s.StartTime, 100) AS startTime,
        CONVERT(VARCHAR(8), s.EndTime, 100) AS endTime,
        CASE WHEN s.StatusCustomTableValueId = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS isAvailable,
        s.Notes AS notes,
        s.CreatedBy AS createdBy,
        s.UpdatedBy AS updatedBy,
        s.DateCreated AS dateCreated,
        s.DateUpdated AS dateUpdated,
        (
            SELECT
                aps.ShiftId AS shiftId,
                sh.ShiftName AS shiftName,
                sh.ShiftCode AS shiftCode,
                sh.BackgroundColour AS backgroundColour
            FROM AvailabilityPeriodShifts aps
            INNER JOIN Shifts sh ON aps.ShiftId = sh.Id
            WHERE aps.ScheduleId = s.Id
                AND aps.UserId = @UserId
                AND sh.DateDeleted IS NULL
            FOR JSON PATH
        ) AS assignments
    FROM Schedules s
    WHERE s.TenantId = @TenantId
        AND s.ScheduleType = 1  -- Availability schedule type
        AND EXISTS (
            SELECT 1
            FROM AvailabilityPeriodShifts aps
            WHERE aps.ScheduleId = s.Id
                AND aps.UserId = @UserId
        )
        AND (@StartDate IS NULL OR s.StartDate >= @StartDate)
        AND (@EndDate IS NULL OR s.StartDate <= @EndDate)
    ORDER BY s.StartDate, s.StartTime

    FOR JSON PATH;
END
GO

/* ----- dbo.usp_EmployeeAvailability_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAvailability_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeAvailability_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON input
        DECLARE @Id INT;
        DECLARE @RequestUserId INT;
        DECLARE @Date DATE;
        DECLARE @StartTime TIME;
        DECLARE @EndTime TIME;
        DECLARE @IsAvailable BIT;
        DECLARE @Notes NVARCHAR(MAX);
        DECLARE @Assignments NVARCHAR(MAX);

        SELECT
            @Id = CASE WHEN JSON_VALUE(@Json, '$.id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(@Json, '$.id') AS INT) END,
            @RequestUserId = CAST(JSON_VALUE(@Json, '$.userId') AS INT),
            @Date = CAST(JSON_VALUE(@Json, '$.date') AS DATE),
            @StartTime = CAST(JSON_VALUE(@Json, '$.startTime') AS TIME),
            @EndTime = CAST(JSON_VALUE(@Json, '$.endTime') AS TIME),
            @IsAvailable = CAST(JSON_VALUE(@Json, '$.isAvailable') AS BIT),
            @Notes = JSON_VALUE(@Json, '$.notes'),
            @Assignments = JSON_QUERY(@Json, '$.assignments');

        DECLARE @ScheduleId INT;
        DECLARE @StatusId INT = CASE WHEN @IsAvailable = 1 THEN 1 ELSE 2 END; -- 1=Available, 2=Unavailable

        -- Update existing schedule
        IF @Id IS NOT NULL AND @Id > 0
        BEGIN
            UPDATE Schedules
            SET
                StartDate = @Date,
                StartTime = @StartTime,
                EndDate = @Date,
                EndTime = @EndTime,
                StatusCustomTableValueId = @StatusId,
                Notes = @Notes,
                UpdatedBy = @UserId,
                DateUpdated = GETDATE()
            WHERE Id = @Id AND TenantId = @TenantId;

            SET @ScheduleId = @Id;

            -- Delete existing shift assignments
            DELETE FROM AvailabilityPeriodShifts
            WHERE ScheduleId = @ScheduleId AND UserId = @RequestUserId;
        END
        ELSE
        BEGIN
            -- Insert new schedule
            INSERT INTO Schedules (
                TenantId,
                ScheduleName,
                SourceType,
                SourceId,
                StartDate,
                StartTime,
                EndDate,
                EndTime,
                StatusCustomTableValueId,
                Notes,
                ScheduleType,
                RepeatEvery,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                'Availability - ' + FORMAT(@Date, 'yyyy-MM-dd') + ' ' + CAST(@StartTime AS VARCHAR(8)),
                1, -- SourceType for availability
                1, -- Default SourceId
                @Date,
                @StartTime,
                @Date,
                @EndTime,
                @StatusId,
                @Notes,
                1, -- ScheduleType = 1 (as per requirement)
                1, -- RepeatEvery = 1 (as per requirement)
                @UserId,
                GETDATE()
            );

            SET @ScheduleId = SCOPE_IDENTITY();
        END

        -- Insert shift assignments from the assignments array
        IF @Assignments IS NOT NULL
        BEGIN
            INSERT INTO AvailabilityPeriodShifts (ScheduleId, ShiftId, UserId)
            SELECT
                @ScheduleId,
                CAST(JSON_VALUE(value, '$.shiftId') AS INT),
                @RequestUserId
            FROM OPENJSON(@Assignments);
        END

        -- Return the saved schedule with assignments
        SELECT
            s.Id AS id,
            s.ScheduleName AS scheduleName,
            @RequestUserId AS userId,
            s.StartDate AS [date],
            DATENAME(WEEKDAY, s.StartDate) AS dayOfWeek,
            CONVERT(VARCHAR(8), s.StartTime, 100) AS startTime,
            CONVERT(VARCHAR(8), s.EndTime, 100) AS endTime,
            CASE WHEN s.StatusCustomTableValueId = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS isAvailable,
            s.Notes AS notes,
            s.CreatedBy AS createdBy,
            s.UpdatedBy AS updatedBy,
            s.DateCreated AS dateCreated,
            s.DateUpdated AS dateUpdated,
            (
                SELECT
                    aps.ShiftId AS shiftId,
                    sh.ShiftName AS shiftName,
                    sh.ShiftCode AS shiftCode,
                    sh.BackgroundColour AS backgroundColour
                FROM AvailabilityPeriodShifts aps
                INNER JOIN Shifts sh ON aps.ShiftId = sh.Id
                WHERE aps.ScheduleId = s.Id
                    AND aps.UserId = @RequestUserId
                FOR JSON PATH
            ) AS assignments
        FROM Schedules s
        WHERE s.Id = @ScheduleId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

/* ----- dbo.usp_EmployeeJobCodeAssignment_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeJobCodeAssignment_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Ankur
-- Create date: 18/10/2025
-- Description: Delete Employee Job Code Assignment
-- =============================================
CREATE   PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_Delete]
      @Id int,
      @UserId int,
      @TenantId int
  AS
  BEGIN
      SET NOCOUNT ON;
      BEGIN TRY
          BEGIN TRAN

          -- Check if Employee Job Code Assignment exists and is active
          IF EXISTS (SELECT 1 FROM EmployeeJobCodeAssignment WHERE Id = @Id AND TenantId = @TenantId AND
  ISNULL(IsActive, 1) = 1)
          BEGIN
              -- Soft Delete Employee Job Code Assignment
              UPDATE EmployeeJobCodeAssignment
              SET IsActive = 0,
                  UpdatedBy = @UserId,
                  DateUpdated = GETUTCDATE()
              WHERE Id = @Id AND TenantId = @TenantId

              SELECT
                  CAST(1 AS bit) as success,
                  'Employee Job Code Assignment deleted successfully' as message,
                  @Id as deletedId
              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
          END
          ELSE
          BEGIN
              SELECT
                  CAST(0 AS bit) as success,
                  'Employee Job Code Assignment not found or already deleted' as message
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

/* ----- dbo.usp_EmployeeJobCodeAssignment_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeJobCodeAssignment_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*==================================================================================
CREATED BY             : Ankur
CREATED DATE           : 18/10/2025
DESCRIPTION            : Get Employee Job Code Assignment List with SERVER-SIDE PAGINATION and SORTING
LAST UPDATED BY        : Ankur
DATE LAST UPDATED     : 03/11/2025
CHANGE DESCRIPTION    : Added Sorting Parameters (SortColumn, SortDirection)

EXEC [usp_EmployeeJobCodeAssignment_Get] 0, 0, '', 1, 1, 10, 'effectiveDate', 'desc'
==================================================================================*/

CREATE PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_Get]
(
    @JobCodeId int,
    @UserId int,
    @SearchStr nvarchar(max),
    @TenantId int,
    @PageNumber int = 1,
    @PageSize int = 10,
    @SortColumn nvarchar(50) = 'effectiveDate',
    @SortDirection nvarchar(4) = 'desc'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle null parameters
    IF(ISNULL(@JobCodeId, 0) = 0)
    BEGIN
        SET @JobCodeId = 0
    END

    IF(ISNULL(@UserId, 0) = 0)
    BEGIN
        SET @UserId = 0
    END

    IF(ISNULL(@SearchStr, '') = '')
    BEGIN
        SET @SearchStr = ''
    END

    -- Default pagination values
    IF(ISNULL(@PageNumber, 0) <= 0)
    BEGIN
        SET @PageNumber = 1
    END

    IF(ISNULL(@PageSize, 0) <= 0)
    BEGIN
        SET @PageSize = 10
    END

    -- Validate and sanitize sort column to prevent SQL injection
    -- NOTE: employeeName sorting removed because Users table is in different database
    DECLARE @ValidSortColumn NVARCHAR(100);
    SET @ValidSortColumn = CASE LOWER(@SortColumn)
        WHEN 'jobcode' THEN 'jc.JobCode'
        WHEN 'effectivedate' THEN 'ejca.EffectiveDate'
        WHEN 'expirydate' THEN 'ejca.ExpiryDate'
        ELSE 'ejca.EffectiveDate'  -- Default
    END;

    -- Validate sort direction
    DECLARE @ValidSortDirection NVARCHAR(4);
    SET @ValidSortDirection = CASE LOWER(@SortDirection)
        WHEN 'asc' THEN 'ASC'
        WHEN 'desc' THEN 'DESC'
        ELSE 'DESC'  -- Default
    END;

    -- Calculate total count BEFORE pagination
    DECLARE @TotalCount INT;

    SELECT @TotalCount = COUNT(*)
    FROM EmployeeJobCodeAssignment ejca
    LEFT JOIN JobCodes jc ON ejca.JobCodeId = jc.Id AND jc.TenantId = @TenantId
    WHERE ejca.TenantId = @TenantId
        AND ISNULL(ejca.IsActive, 1) = 1
        AND (@JobCodeId = 0 OR ejca.JobCodeId = @JobCodeId)
        AND (@UserId = 0 OR ejca.UserId = @UserId)
        AND (
            @SearchStr = ''
            OR jc.JobCode LIKE '%' + @SearchStr + '%'
            OR jc.JobTitle LIKE '%' + @SearchStr + '%'
        );

    -- Get paginated data with total count and sorting
    SELECT
        ejca.Id as id,
        ejca.JobCodeId as jobCodeId,
        ejca.UserId as userId,
        ejca.IsActive as isActive,
        ejca.EffectiveDate as effectiveDate,
        ejca.ExpiryDate as expiryDate,
        ejca.CreatedBy as createdBy,
        ejca.UpdatedBy as updatedBy,
        ejca.DateCreated as dateCreated,
        ejca.DateUpdated as dateUpdated,
        jc.JobCode as jobCode,
        jc.JobTitle as jobTitle,
        jc.Description as jobDescription,
        jc.Category as jobCategory,
        @TotalCount as totalCount
    FROM EmployeeJobCodeAssignment ejca
    LEFT JOIN JobCodes jc ON ejca.JobCodeId = jc.Id AND jc.TenantId = @TenantId
    WHERE ejca.TenantId = @TenantId
        AND ISNULL(ejca.IsActive, 1) = 1
        AND (@JobCodeId = 0 OR ejca.JobCodeId = @JobCodeId)
        AND (@UserId = 0 OR ejca.UserId = @UserId)
        AND (
            @SearchStr = ''
            OR jc.JobCode LIKE '%' + @SearchStr + '%'
            OR jc.JobTitle LIKE '%' + @SearchStr + '%'
        )
    ORDER BY
        CASE WHEN @ValidSortColumn = 'jc.JobCode' AND @ValidSortDirection = 'ASC' THEN jc.JobCode END ASC,
        CASE WHEN @ValidSortColumn = 'jc.JobCode' AND @ValidSortDirection = 'DESC' THEN jc.JobCode END DESC,
        CASE WHEN @ValidSortColumn = 'ejca.EffectiveDate' AND @ValidSortDirection = 'ASC' THEN ejca.EffectiveDate END ASC,
        CASE WHEN @ValidSortColumn = 'ejca.EffectiveDate' AND @ValidSortDirection = 'DESC' THEN ejca.EffectiveDate END DESC,
        CASE WHEN @ValidSortColumn = 'ejca.ExpiryDate' AND @ValidSortDirection = 'ASC' THEN ejca.ExpiryDate END ASC,
        CASE WHEN @ValidSortColumn = 'ejca.ExpiryDate' AND @ValidSortDirection = 'DESC' THEN ejca.ExpiryDate END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_EmployeeJobCodeAssignment_GetById.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeJobCodeAssignment_GetById]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*---------------------=========================================================================================================
CREATED BY			: Ankur
CREATED DATE 		: 18/10/2025
DESCRIPTION			: Get Employee Job Code Assignment by Id
PROCEDURE NAME		: usp_EmployeeJobCodeAssignment_GetById
LAST UPDATED BY 	:
DATE LAST UPDATED 	:
EXEC [usp_EmployeeJobCodeAssignment_GetById] 0, 0
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_GetById]
(
    @Id int,
    @TenantId int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ejca.Id as id,
        ejca.JobCodeId as jobCodeId,
        ejca.UserId as userId,
        ejca.IsActive as isActive,
        ejca.EffectiveDate as effectiveDate,
        ejca.ExpiryDate as expiryDate,
        ejca.CreatedBy as createdBy,
        ejca.UpdatedBy as updatedBy,
        ejca.DateCreated as dateCreated,
        ejca.DateUpdated as dateUpdated,
        jc.JobCode as jobCode,
        jc.JobTitle as jobTitle,
        jc.Description as jobDescription,
        jc.Category as jobCategory
    FROM EmployeeJobCodeAssignment ejca
    LEFT JOIN JobCodes jc ON ejca.JobCodeId = jc.Id AND jc.TenantId = @TenantId
    WHERE ejca.Id = @Id
        AND ejca.TenantId = @TenantId
        AND ISNULL(ejca.IsActive, 1) = 1
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_EmployeeJobCodeAssignment_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeJobCodeAssignment_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            ejca.Id AS id,
            ejca.UserId AS userId,
            jc.Id AS jobCodeId,
            jc.JobTitle AS jobTitle,
            jc.JobCode AS jobCode,
            jc.IsActive AS isActive
        FROM JobCodes jc
        INNER JOIN EmployeeJobCodeAssignment ejca ON jc.Id = ejca.JobCodeId
        WHERE ejca.UserId = ISNULL(@UserId, 0)
            AND ejca.TenantId = @TenantId
            AND ejca.IsActive = 1
            AND jc.IsActive = 1
        ORDER BY jc.JobTitle ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            CAST(0 AS BIT) AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_EmployeeJobCodeAssignment_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeJobCodeAssignment_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Ankur
-- Create date: 18/10/2025
-- Update date: 02/11/2025
-- Update by: Ankur 
-- Description: Save (Insert/Update) Employee Job Code Assignment
-- =============================================
CREATE   PROCEDURE [dbo].[usp_EmployeeJobCodeAssignment_Save]
    @Json varchar(max),
    @UserId int,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN

        DECLARE @Id int
        DECLARE @JobCodeId int
        DECLARE @AssignmentUserId int
        DECLARE @IsActive bit
        DECLARE @EffectiveDate datetimeoffset(7)
        DECLARE @ExpiryDate datetimeoffset(7)

        -- Parse JSON
        SELECT
            @Id = id,
            @JobCodeId = jobCodeId,
            @AssignmentUserId = userId,
            @IsActive = isActive,
            @EffectiveDate = effectiveDate,
            @ExpiryDate = expiryDate
        FROM OPENJSON(@Json) WITH (
            id int,
            jobCodeId int,
            userId int,
            isActive bit,
            effectiveDate datetimeoffset(7),
            expiryDate datetimeoffset(7)
        )

        -- Validate required fields
        IF @JobCodeId IS NULL OR @JobCodeId = 0
        BEGIN
            SELECT
                CAST(0 AS bit) as success,
                'Job Code is required' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END

        IF @AssignmentUserId IS NULL OR @AssignmentUserId = 0
        BEGIN
            SELECT
                CAST(0 AS bit) as success,
                'Employee is required' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END

        -- Validate dates if provided
        IF @EffectiveDate IS NOT NULL AND @ExpiryDate IS NOT NULL
        BEGIN
            IF @ExpiryDate <= @EffectiveDate
            BEGIN
                SELECT
                    CAST(0 AS bit) as success,
                    'Expiry date must be greater than effective date' as message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ROLLBACK TRAN
                RETURN
            END
        END

        -- Check for duplicate assignment (same job code and user, overlapping dates)
        IF EXISTS (
            SELECT 1
            FROM EmployeeJobCodeAssignment
            WHERE TenantId = @TenantId
                AND JobCodeId = @JobCodeId
                AND UserId = @AssignmentUserId
                AND Id != ISNULL(@Id, 0)
                AND IsActive = 1
                AND (
                    (@EffectiveDate IS NULL AND @ExpiryDate IS NULL)
                    OR (@EffectiveDate IS NULL AND EffectiveDate IS NULL)
                    OR (@ExpiryDate IS NULL AND ExpiryDate IS NULL)
                    OR (
                        (@EffectiveDate IS NOT NULL AND @ExpiryDate IS NOT NULL)
                        AND (EffectiveDate IS NOT NULL AND ExpiryDate IS NOT NULL)
                        AND (
                            (@EffectiveDate BETWEEN EffectiveDate AND ExpiryDate)
                            OR (@ExpiryDate BETWEEN EffectiveDate AND ExpiryDate)
                            OR (EffectiveDate BETWEEN @EffectiveDate AND @ExpiryDate)
                            OR (ExpiryDate BETWEEN @EffectiveDate AND @ExpiryDate)
                        )
                    )
                )
        )
        BEGIN
            SELECT
                CAST(0 AS bit) as success,
                'This employee already has an assignment for this job code in the specified date range' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END

        -- Check if Employee Job Code Assignment exists
        IF EXISTS (SELECT 1 FROM EmployeeJobCodeAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            -- Update existing Employee Job Code Assignment
            UPDATE EmployeeJobCodeAssignment SET
                JobCodeId = @JobCodeId,
                UserId = @AssignmentUserId,
                IsActive = ISNULL(@IsActive, 1),
                EffectiveDate = @EffectiveDate,
                ExpiryDate = @ExpiryDate,
                UpdatedBy = @UserId,
                DateUpdated = GETUTCDATE()
            WHERE Id = @Id AND TenantId = @TenantId

            SELECT
                @Id as id,
                CAST(1 AS bit) as success,
                'Employee Job Code Assignment updated successfully' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        ELSE
        BEGIN
            -- Insert new Employee Job Code Assignment
            INSERT INTO EmployeeJobCodeAssignment (
                TenantId,
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
                @JobCodeId,
                @AssignmentUserId,
                ISNULL(@IsActive, 1),
                @EffectiveDate,
                @ExpiryDate,
                @UserId,
                GETUTCDATE()
            )

            SET @Id = SCOPE_IDENTITY()

            SELECT
                @Id as id,
                CAST(1 AS bit) as success,
                'Employee Job Code Assignment created successfully' as message
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

/* ----- dbo.usp_EmployeeLabelAssignment_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeLabelAssignment_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Delete]
    @Id INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Soft delete the assignment
        UPDATE EmployeeLabelAssignment
        SET 
            IsDeleted = 1,
            DeletedBy = @UserId,
            DeletedOn = SYSDATETIMEOFFSET()
        WHERE Id = @Id
            AND TenantId = @TenantId
            AND IsDeleted = 0;

        -- Check if any rows were affected
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT
                CAST(0 AS BIT) AS success,
                'Assignment not found or already deleted.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            CAST(1 AS BIT) AS success,
            'Employee label assignment deleted successfully.' AS message
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

/* ----- dbo.usp_EmployeeLabelAssignment_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeLabelAssignment_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Get]
	@Id int = NULL,
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
			ela.Id as id,
			ela.TenantId as tenantId,
			ela.LabelId as labelId,
			l.LabelName as labelName,
			l.LabelCode as labelCode,
			l.ColorCode as colorCode,
			ela.UserId as userId,
			ela.EffectiveDate as effectiveDate,
			ela.ExpiryDate as expiryDate,
			ela.CreatedBy as createdBy,
			ela.UpdatedBy as updatedBy,
			ela.DateCreated as dateCreated,
			ela.DateUpdated as dateUpdated
		FROM EmployeeLabelAssignment ela
		INNER JOIN Labels l ON ela.LabelId = l.Id
		WHERE ela.TenantId = @TenantId
			AND ela.IsDeleted = 0
			AND (@Id IS NULL OR ela.Id = @Id)
			AND (
				@SearchTerm IS NULL OR 
				l.LabelName LIKE '%' + @SearchTerm + '%' OR 
				l.LabelCode LIKE '%' + @SearchTerm + '%'
			)
	)
	SELECT 
		_rows.id,
		_rows.tenantId,
		_rows.labelId,
		_rows.labelName,
		_rows.labelCode,
		_rows.colorCode,
		_rows.userId,
		_rows.effectiveDate,
		_rows.expiryDate,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		(SELECT count(_rows.id) from _rows) as totalCount
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'ASC' THEN _rows.dateCreated END ASC,
		CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'DESC' THEN _rows.dateCreated END DESC,
		CASE WHEN @SortColumn = 'LabelName' AND @SortDirection = 'ASC' THEN _rows.labelName END ASC,
		CASE WHEN @SortColumn = 'LabelName' AND @SortDirection = 'DESC' THEN _rows.labelName END DESC,
		_rows.dateCreated DESC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_EmployeeLabelAssignment_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeLabelAssignment_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeLabelAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            ela.Id AS id,
            ela.UserId AS userId,
            l.Id AS labelId,
            l.LabelName AS labelName,
            l.LabelCode AS labelCode,
            l.ColorCode AS colorCode,
            l.IsActive AS isActive
        FROM Labels l
        INNER JOIN EmployeeLabelAssignment ela ON l.Id = ela.LabelId
        WHERE ela.UserId = ISNULL(@UserId, 0)
            AND ela.TenantId = @TenantId
            AND ela.IsDeleted = 0
            AND l.IsActive = 1
        ORDER BY l.LabelName ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            CAST(0 AS BIT) AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_EmployeeLabelAssignment_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeLabelAssignment_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Id INT;
        DECLARE @LabelId INT;
        DECLARE @EmployeeUserId INT;
        DECLARE @EffectiveDate DATETIMEOFFSET;
        DECLARE @ExpiryDate DATETIMEOFFSET;

        -- Parse JSON
        SELECT 
            @Id = Id,
            @LabelId = LabelId,
            @EmployeeUserId = UserId,
            @EffectiveDate = EffectiveDate,
            @ExpiryDate = ExpiryDate
        FROM OPENJSON(@Json)
        WITH (
            id INT,
            labelId INT,
            userId INT,
            effectiveDate DATETIMEOFFSET,
            expiryDate DATETIMEOFFSET
        );

        -- Validate required fields (BEFORE starting transaction)
        IF @LabelId IS NULL OR @LabelId = 0
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Label is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        IF @EmployeeUserId IS NULL OR @EmployeeUserId = 0
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Employee is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check if label exists
        IF NOT EXISTS (SELECT 1 FROM Labels WHERE Id = @LabelId AND TenantId = @TenantId)
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Label not found.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check for duplicate assignment (excluding current record if updating)
        IF EXISTS (
            SELECT 1 
            FROM EmployeeLabelAssignment 
            WHERE LabelId = @LabelId 
                AND UserId = @EmployeeUserId
                AND TenantId = @TenantId 
                AND IsDeleted = 0
                AND (ISNULL(@Id, 0) = 0 OR Id != @Id)
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'This employee is already assigned to this label.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- All validations passed, now start transaction
        BEGIN TRANSACTION;

        -- Insert or Update
        IF @Id IS NULL OR @Id = 0
        BEGIN
            -- Insert new assignment
            INSERT INTO EmployeeLabelAssignment (
                TenantId, LabelId, UserId, EffectiveDate, ExpiryDate, 
                IsDeleted, CreatedBy, DateCreated
            )
            VALUES (
                @TenantId, @LabelId, @EmployeeUserId, @EffectiveDate, @ExpiryDate,
                0, @UserId, SYSDATETIMEOFFSET()
            );

            SET @Id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Update existing assignment
            UPDATE EmployeeLabelAssignment
            SET 
                LabelId = @LabelId,
                UserId = @EmployeeUserId,
                EffectiveDate = @EffectiveDate,
                ExpiryDate = @ExpiryDate,
                UpdatedBy = @UserId,
                DateUpdated = SYSDATETIMEOFFSET()
            WHERE Id = @Id AND TenantId = @TenantId;

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT
                    CAST(0 AS BIT) AS success,
                    'Assignment not found or unauthorized.' AS message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                RETURN;
            END
        END

        COMMIT TRANSACTION;

        -- Return success with the assignment Id
        SELECT
            @Id AS id,
            CAST(1 AS BIT) AS success,
            'Employee label assignment saved successfully.' AS message
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

/* ----- dbo.usp_EmployeeWorkCodeAssignment_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkCodeAssignment_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_GetShortList]
    @UserId INT = NULL,
    @Common BIT = 0,
    @UserIds VARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            ewca.Id AS id,
            ewca.UserId AS userId,
            wc.Id AS workCodeId,
            wc.WorkCodeName AS workCodeName,
            wc.WorkCode AS workCode,
            wc.ColorCode AS colorCode,
            wc.IsActive AS isActive
        FROM WorkCodes wc
        INNER JOIN EmployeeWorkCodeAssignment ewca ON wc.Id = ewca.WorkCodeId
        WHERE ewca.UserId = ISNULL(@UserId, 0)
            AND ewca.TenantId = @TenantId
            AND ewca.IsActive = 1
            AND wc.IsActive = 1
        ORDER BY wc.WorkCodeName ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            CAST(0 AS BIT) AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_Groups_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Groups_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Ali Nafees
-- Create date: 11-03-2025
-- Description: Delete a Group with validation
-- =============================================
CREATE PROCEDURE [dbo].[usp_Groups_Delete]
    @GroupId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the group is assigned to any shifts
        IF EXISTS (
            SELECT 1 
            FROM ShiftGroupAssignment 
            WHERE GroupId = @GroupId 
                AND TenantId = @TenantId
        )
        BEGIN
            -- Return error message without deleting
            SELECT
                cast(0 as bit) AS success,
                'Cannot delete this group because it is assigned to one or more shifts. Please remove the shift assignments first.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Delete the group
        DELETE FROM Groups
        WHERE Id = @GroupId
            AND TenantId = @TenantId;

        -- Check if any rows were affected
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT
                cast(0 as bit) AS success,
                'Group not found or already deleted.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            cast(1 as bit) AS success,
            'Group deleted successfully.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Return error
        SELECT
            0 AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_Groups_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Groups_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Get Shift Groups with server-side paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
Create PROCEDURE [dbo].[usp_Groups_Get]
	@GroupId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'GroupName',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	;WITH _rows AS (
		SELECT 
			g.Id as id,
			g.GroupName as groupName,
			g.GroupTypeCustomTableValueId as groupTypeCustomTableValueId,
			g.Description as description,
			g.ColorCode as colorCode,
			g.IsActive as isActive,
			g.CreatedBy as createdBy,
			g.UpdatedBy as updatedBy,
			g.DateCreated as dateCreated,
			g.DateUpdated as dateUpdated
		FROM Groups g
		WHERE g.TenantId = @TenantId
			AND (@GroupId IS NULL OR g.Id = @GroupId)
			AND (
				@SearchTerm IS NULL OR 
				g.GroupName LIKE '%' + @SearchTerm + '%' OR 
				g.Description LIKE '%' + @SearchTerm + '%'
			)
	)
	SELECT 
		_rows.id,
		_rows.groupName,
		_rows.groupTypeCustomTableValueId,
		_rows.description,
		_rows.colorCode,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		(SELECT count(_rows.id) from _rows) as totalCount
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'GroupName' AND @SortDirection = 'ASC' THEN _rows.groupName END ASC,
		CASE WHEN @SortColumn = 'GroupName' AND @SortDirection = 'DESC' THEN _rows.groupName END DESC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'ASC' THEN _rows.description END ASC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'DESC' THEN _rows.description END DESC,
		_rows.groupName ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Groups_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Groups_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Get Shift Groups Short List for dropdowns/lookups
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
Create  PROCEDURE [dbo].[usp_Groups_GetShortList]
(
	@TenantId int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		g.Id as id,
		g.GroupName as groupName,
		g.ColorCode as colorCode,
		g.IsActive as isActive
	FROM Groups g
	WHERE g.TenantId = @TenantId
		AND ISNULL(g.IsActive, 1) = 1
	ORDER BY g.GroupName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Groups_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Groups_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Groups_Save]
	@Json VARCHAR(MAX),
	@UserId INT,
	@TenantId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @Id INT
		DECLARE @GroupName VARCHAR(255)
		DECLARE @GroupTypeCustomTableValueId INT
		DECLARE @Description NVARCHAR(MAX)
		DECLARE @ColorCode VARCHAR(7)
		DECLARE @IsActive BIT

		-- Parse JSON
		SELECT 
			@Id = id,
			@GroupName = groupName,
			@GroupTypeCustomTableValueId = groupTypeCustomTableValueId,
			@Description = description,
			@ColorCode = colorCode,
			@IsActive = ISNULL(isActive, 1)
		FROM OPENJSON(@Json) WITH (
			id INT,
			groupName VARCHAR(255),
			groupTypeCustomTableValueId INT,
			description NVARCHAR(MAX),
			colorCode VARCHAR(7),
			isActive BIT
		)

		-- Validate required fields
		IF @GroupName IS NULL OR LTRIM(RTRIM(@GroupName)) = ''
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT 
				CAST(0 AS BIT) AS success,
				'Group name is required.' AS message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
			RETURN;
		END

		-- Check if GroupName already exists for another group
		IF EXISTS (
			SELECT 1 
			FROM Groups 
			WHERE GroupName = @GroupName 
				AND TenantId = @TenantId 
				AND (ISNULL(@Id, 0) = 0 OR Id != @Id)
		)
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT 
				CAST(0 AS BIT) AS success,
				'A group with this name already exists.' AS message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
			RETURN;
		END

		-- Insert or Update
		IF @Id IS NOT NULL AND @Id > 0 AND EXISTS (SELECT 1 FROM Groups WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Group
			UPDATE Groups
			SET 
				GroupName = @GroupName,
				GroupTypeCustomTableValueId = @GroupTypeCustomTableValueId,
				Description = @Description,
				ColorCode = @ColorCode,
				IsActive = @IsActive,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId;

			IF @@ROWCOUNT = 0
			BEGIN
				ROLLBACK TRANSACTION;
				SELECT 
					CAST(0 AS BIT) AS success,
					'Group not found or unauthorized.' AS message
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
				RETURN;
			END

			COMMIT TRANSACTION;

			SELECT 
				@Id AS id, 
				CAST(1 AS BIT) AS success, 
				'Group updated successfully.' AS message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
		END
		ELSE
		BEGIN
			-- Insert new Group
			INSERT INTO Groups (
				TenantId,
				GroupName,
				GroupTypeCustomTableValueId,
				Description,
				ColorCode,
				IsActive,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@GroupName,
				@GroupTypeCustomTableValueId,
				@Description,
				@ColorCode,
				@IsActive,
				@UserId,
				GETUTCDATE()
			);

			SET @Id = SCOPE_IDENTITY();

			COMMIT TRANSACTION;

			SELECT 
				@Id AS id, 
				CAST(1 AS BIT) AS success, 
				'Group created successfully.' AS message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
		END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT 
			CAST(0 AS BIT) AS success,
			ERROR_MESSAGE() AS message
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END CATCH
END
GO

/* ----- dbo.usp_HolidayAssignment_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_HolidayAssignment_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: TimeManagement API
-- Create date: 10/15/2025
-- Description: Soft Delete Holiday Assignment
-- =============================================
CREATE   PROCEDURE [dbo].[usp_HolidayAssignment_Delete]
    @Id int,
    @UserId int,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN
        
        -- Check if Holiday Assignment exists
        IF NOT EXISTS (SELECT 1 FROM HolidayAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            SELECT 
                CAST(0 AS bit) as success,
                'Holiday Assignment not found' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END
        
        -- Check if already deleted
        IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE Id = @Id AND TenantId = @TenantId AND IsDeleted = 1)
        BEGIN
            SELECT 
                CAST(0 AS bit) as success,
                'Holiday Assignment is already deleted' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END
        
        -- Soft Delete: Mark as deleted instead of removing the record
        UPDATE HolidayAssignment SET
            IsDeleted = 1,
            DeletedBy = @UserId,
            DeletedOn = GETUTCDATE()
        WHERE Id = @Id AND TenantId = @TenantId
        
        SELECT 
            @Id as deletedId,
            CAST(1 AS bit) as success,
            'Holiday Assignment deleted successfully' as message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        
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

/* ----- dbo.usp_HolidayAssignment_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_HolidayAssignment_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: TimeManagement API
CREATED DATE 		: 10/9/2025
DESCRIPTION			: Get Holiday Assignment List with filters and paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	:
EXEC [usp_HolidayAssignment_Get] 0, 10, '1,2,3', 1, 1, 'Christmas', 'both', 1
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_HolidayAssignment_Get]
(
    @OffSet int,
    @Limit int,
    @HolidayIds nvarchar(max),
    @JobCodeId int,
    @UserId int,
    @SearchStr nvarchar(max),
    @AssignmentBy nvarchar(50),
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
    
    IF(ISNULL(@SearchStr, '') = '')
    BEGIN
        SET @SearchStr = ''
    END
    
    IF(ISNULL(@AssignmentBy, '') = '')
    BEGIN
        SET @AssignmentBy = ''
    END
    
    ;WITH _rows AS (
        SELECT 
            ha.Id as id,
            ha.HolidayId as holidayId,
            ha.JobCodeId as jobCodeId,
            ha.UserId as userId,
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
			AND ISNULL(ha.IsDeleted, 0) = 0
            AND (
                @SearchStr = '' 
                OR h.HolidayName LIKE '%' + @SearchStr + '%'
                OR h.HolidayCode LIKE '%' + @SearchStr + '%'
                --OR jc.JobCode LIKE '%' + @SearchStr + '%'
                --OR jc.JobTitle LIKE '%' + @SearchStr + '%'
                --OR jc.Description LIKE '%' + @SearchStr + '%'
            )
            AND (
                @AssignmentBy = ''
                OR (@AssignmentBy = 'jobcode' AND ha.JobCodeId IS NOT NULL AND ha.UserId IS NULL)
                OR (@AssignmentBy = 'user' AND ha.UserId IS NOT NULL AND ha.JobCodeId IS NULL)
                OR (@AssignmentBy = 'both' AND ha.JobCodeId IS NOT NULL OR ha.UserId IS NOT NULL)
            )
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

/* ----- dbo.usp_HolidayAssignment_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_HolidayAssignment_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: TimeManagement API
-- Create date: 10/9/2025
-- Description: Save (Insert/Update) Holiday Assignment
-- Modified: Added duplicate validation for job code and user assignments
-- =============================================
CREATE   PROCEDURE [dbo].[usp_HolidayAssignment_Save]
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
        DECLARE @AssignmentUserId int
        DECLARE @EffectiveDate datetimeoffset(7)
        DECLARE @ExpiryDate datetimeoffset(7)
        
        -- Parse JSON
        SELECT 
            @Id = ISNULL(id, 0),
            @HolidayId = holidayId,
            @JobCodeId = jobCodeId,
            @AssignmentUserId = userId,
            @EffectiveDate = effectiveDate,
            @ExpiryDate = expiryDate
        FROM OPENJSON(@Json) WITH (
            id int,
            holidayId int,
            jobCodeId int,
            userId int,
            effectiveDate datetimeoffset(7),
            expiryDate datetimeoffset(7)
        )
        
        -- Validate: Check for duplicate assignment for Job Code
        IF @JobCodeId IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM HolidayAssignment 
                WHERE HolidayId = @HolidayId 
                    AND JobCodeId = @JobCodeId 
                    AND TenantId = @TenantId 
                    AND Id != @Id
            )
            BEGIN
                SELECT 
                    CAST(0 AS bit) as success,
                    'Holiday assignment already exists for this Job Code' as message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ROLLBACK TRAN
                RETURN
            END
        END
        
        -- Validate: Check for duplicate assignment for User
        IF @AssignmentUserId IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM HolidayAssignment 
                WHERE HolidayId = @HolidayId 
                    AND UserId = @AssignmentUserId 
                    AND TenantId = @TenantId 
                    AND Id != @Id
            )
            BEGIN
                SELECT 
                    CAST(0 AS bit) as success,
                    'Holiday assignment already exists for this User' as message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ROLLBACK TRAN
                RETURN
            END
        END
        
        -- Check if Holiday Assignment exists (Update scenario)
        IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            -- Update existing Holiday Assignment
            UPDATE HolidayAssignment SET
                HolidayId = @HolidayId,
                JobCodeId = @JobCodeId,
                UserId = @AssignmentUserId,
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
                EffectiveDate,
                ExpiryDate,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @HolidayId,
                @JobCodeId,
                @AssignmentUserId,
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

/* ----- dbo.usp_Holidays_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Holidays_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Delete Holiday
-- =============================================
CREATE   PROCEDURE [dbo].[usp_Holidays_Delete]
	@HolidayId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Holiday exists
		IF NOT EXISTS (SELECT 1 FROM Holidays WHERE Id = @HolidayId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Holiday not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Holiday has assignments
		IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE HolidayId = @HolidayId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Cannot delete as Holiday Assignment exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the Holiday
		DELETE FROM Holidays 
		WHERE Id = @HolidayId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Holiday deleted successfully' as message,
			@HolidayId as deletedId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_Holidays_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Holidays_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Get Holidays
-- =============================================
CREATE   PROCEDURE [dbo].[usp_Holidays_Get]
	@HolidayId int = NULL,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		h.id,
		h.HolidayCode as holidayCode,
		h.HolidayName as holidayName,
		h.HolidayDate as holidayDate,
		h.IsObserved as isObserved,
		h.IsFloating as isFloating,
		h.IsAppliesToAll as isAppliesToAll,
		h.CreatedBy as createdBy,
		h.UpdatedBy as updatedBy,
		h.DateCreated as dateCreated,
		h.DateUpdated as dateUpdated,
		h.ObservedDate as observedDate
	FROM Holidays h
	WHERE h.TenantId = @TenantId
		AND (@HolidayId IS NULL OR h.Id = @HolidayId)
	ORDER BY h.HolidayDate
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Holidays_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Holidays_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: TimeManagement API
CREATED DATE 		: 10/10/2025
DESCRIPTION			: Get short list of Holidays for dropdowns/lookups
LAST UPDATED BY 	:
DATE LAST UPDATED 	:
EXEC [usp_Holidays_GetShortList] 1
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Holidays_GetShortList]
(
    @TenantId int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Id as id,
        h.HolidayCode as holidayCode,
        h.HolidayName as holidayName,
        h.HolidayDate as holidayDate
    FROM Holidays h
    WHERE h.TenantId = @TenantId
		AND ISNULL(h.IsAppliesToAll, 0) = 0
    ORDER BY h.HolidayDate ASC
    FOR JSON PATH, INCLUDE_NULL_VALUES
END

GO

/* ----- dbo.usp_Holidays_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Holidays_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Save (Insert/Update) Holiday
-- =============================================
CREATE   PROCEDURE [dbo].[usp_Holidays_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @HolidayCode varchar(50)
		DECLARE @HolidayName varchar(255)
		DECLARE @HolidayDate date
		DECLARE @ObservedDate date
		DECLARE @IsObserved bit
		DECLARE @IsFloating bit
		DECLARE @IsAppliesToAll bit

		-- Parse JSON
		SELECT 
			@Id = Id,
			@HolidayCode = holidayCode,
			@HolidayName = holidayName,
			@HolidayDate = holidayDate,
			@ObservedDate = observedDate,
			@IsObserved = ISNULL(isObserved, 0),
			@IsFloating = ISNULL(isFloating, 0),
			@IsAppliesToAll = ISNULL(isAppliesToAll, 0)
		FROM OPENJSON(@Json) WITH (
			id int,
			holidayCode varchar(50),
			holidayName varchar(255),
			holidayDate date,
			observedDate date,
			isObserved bit,
			isFloating bit,
			isAppliesToAll bit
		)


		-- Check if HolidayCode already exists for another holiday
		IF EXISTS (
			SELECT 1 FROM Holidays 
			WHERE HolidayCode = @HolidayCode 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Holiday Code already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if HolidayDate already exists for another holiday
		IF EXISTS (
			SELECT 1 FROM Holidays 
			WHERE HolidayDate = @HolidayDate 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Holiday Date already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if ObservedDate already exists for another holiday (only if ObservedDate is provided)
		IF @ObservedDate IS NOT NULL AND EXISTS (
			SELECT 1 FROM Holidays 
			WHERE ObservedDate = @ObservedDate 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Observed Date already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Holiday exists
		IF EXISTS (SELECT 1 FROM Holidays WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Holiday
			UPDATE Holidays
			SET 
				HolidayCode = @HolidayCode,
				HolidayName = @HolidayName,
				HolidayDate = @HolidayDate,
				ObservedDate = @ObservedDate,
				IsObserved = @IsObserved,
				IsFloating = @IsFloating,
				IsAppliesToAll = @IsAppliesToAll,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			SELECT @Id as id, CAST(1 AS bit) as success, 'Holiday updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new Holiday
			INSERT INTO Holidays (
				TenantId,
				HolidayCode,
				HolidayName,
				HolidayDate,
				ObservedDate,
				IsObserved,
				IsFloating,
				IsAppliesToAll,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@HolidayCode,
				@HolidayName,
				@HolidayDate,
				@ObservedDate,
				@IsObserved,
				@IsFloating,
				@IsAppliesToAll,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()

			SELECT @Id as id, CAST(1 AS bit) as success, 'Holiday created successfully' as message
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

/* ----- dbo.usp_InitializeLayouts.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_InitializeLayouts]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Initialize default layouts (Daily, Weekly, Monthly) for a tenant if they don't exist
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_InitializeLayouts]
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameter
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            RAISERROR('Invalid TenantId parameter. TenantId must be a positive integer.', 16, 1)
            RETURN
        END

        -- Insert all layouts in a single statement
        INSERT INTO [dbo].[Layouts] (
            [TenantId], 
            [LayoutName], 
            [Type], 
            [Description], 
            [CreatedBy], 
            [DateCreated], 
            [UpdatedBy], 
            [DateUpdated], 
            [Rows], 
            [Columns]
        )
        SELECT * 
        FROM 
        (
            SELECT 
                @TenantId as [TenantId],
                'Daily Layout' as [LayoutName],
                1 as [Type], -- 1 for Daily
                'Default daily scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy], -- Using TenantId as CreatedBy for system initialization
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                4 as [Rows], -- 24 hours in a day
                5 as [Columns] -- 7 days in a week
            UNION 
            SELECT 
                @TenantId as [TenantId],
                'Weekly Layout' as [LayoutName],
                2 as [Type], -- 2 for Weekly
                'Default weekly scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy],
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                NULL as [Rows], -- Will be set by user
                NULL as [Columns] -- Will be set by user
            UNION 
            SELECT 
                @TenantId as [TenantId],
                'Monthly Layout' as [LayoutName],
                3 as [Type], -- 3 for Monthly
                'Default monthly scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy],
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                NULL as [Rows], -- Will be set by user
                NULL as [Columns] -- Will be set by user
        ) as X 
        WHERE NOT EXISTS (
            SELECT 1 FROM [dbo].[Layouts] as l 
            WHERE l.[TenantId] = @TenantId 
            AND l.[LayoutName] = X.[LayoutName] 
            AND l.[Type] = X.[Type]
        )

        -- Return success message with count of inserted records
        SELECT 
            'Layouts initialized successfully for TenantId: ' + CAST(@TenantId AS NVARCHAR(10)) as Message,
            @@ROWCOUNT as RecordsInserted

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_JobCodes_Add.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_Add]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_JobCodes_Add]
    @JobTitle NVARCHAR(100),
    @Code NVARCHAR(50),
    @Description NVARCHAR(500),
    @Category NVARCHAR(50),
    @IsExempt BIT = 0,
    @PayRate DECIMAL(18,2) = 0,
    @DefaultHoursPerWeek INT = 40,
    @IsActive BIT = 1,
    @TenantId INT,
    @CreatedBy INT = NULL,
    @ColorCode NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result TABLE (Success INT, Message NVARCHAR(500));

    BEGIN TRY
        -- Trim input values
        SET @JobTitle = LTRIM(RTRIM(@JobTitle));
        SET @Code = LTRIM(RTRIM(@Code));
        SET @Description = LTRIM(RTRIM(@Description));

        -- Validate required fields
        IF @JobTitle IS NULL OR @JobTitle = ''
        BEGIN
            INSERT INTO @Result (Success, Message) VALUES (0, 'Job Title is required');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        IF @Code IS NULL OR @Code = ''
        BEGIN
            INSERT INTO @Result (Success, Message) VALUES (0, 'Job Code is required');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        -- *** FIXED: Case-insensitive and whitespace-trimmed duplicate check ***
        IF EXISTS (SELECT 1 FROM JobCodes
                   WHERE LOWER(LTRIM(RTRIM(JobCode))) = LOWER(LTRIM(RTRIM(@Code)))
                   AND TenantId = @TenantId
                   AND IsActive = 1)
        BEGIN
            INSERT INTO @Result (Success, Message)
            VALUES (0, 'A Job Code with this code already exists. Please use a different code.');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        -- Insert new job code
        INSERT INTO JobCodes (
            JobTitle,
            JobCode,
            Description,
            Category,
            IsExempt,
            PayRate,
            DefaultHoursPerWeek,
            IsActive,
            TenantId,
            CreatedBy,
            DateCreated,
            ColorCode
        )
        VALUES (
            @JobTitle,
            @Code,
            @Description,
            @Category,
            @IsExempt,
            @PayRate,
            @DefaultHoursPerWeek,
            @IsActive,
            @TenantId,
            @CreatedBy,
            GETDATE(),
            @ColorCode
        );

        INSERT INTO @Result (Success, Message) VALUES (1, 'Job Code added successfully');
        SELECT Success, Message FROM @Result;
    END TRY
    BEGIN CATCH
        INSERT INTO @Result (Success, Message)
        VALUES (0, 'Error: ' + ERROR_MESSAGE());
        SELECT Success, Message FROM @Result;
    END CATCH
END
GO

/* ----- dbo.usp_JobCodes_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ankur
-- Create date: 13-10-2025
-- Description: Delete a Job Code
-- =============================================

CREATE   PROCEDURE [dbo].[usp_JobCodes_Delete]
    @Id INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if job code exists for this tenant
        IF NOT EXISTS (SELECT 1 FROM JobCodes WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            SELECT
                0 AS Success,
                'Job Code not found.' AS Message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Delete the job code
        DELETE FROM JobCodes
        WHERE Id = @Id
            AND TenantId = @TenantId;

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            1 AS Success,
            'Job Code deleted successfully.' AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Return error
        SELECT
            0 AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_JobCodes_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Stored Procedure: usp_JobCodes_Get
-- Description: Get all job codes for a specific tenant
-- Parameters: @TenantId (int) - The tenant ID to filter job codes
-- Author:  Ankur Arora
-- Date:    12-10-2025
-- =======================================================================
 CREATE   PROCEDURE [dbo].[usp_JobCodes_Get]
      @TenantId INT
  AS
  BEGIN
      SET NOCOUNT ON;
      BEGIN TRY
          SELECT
              Id as id,
              JobTitle as jobTitle,
              JobCode AS code,
              Description as description,
              Category as category,
              IsExempt as isExempt,
              PayRate as payRate,
              DefaultHoursPerWeek as defaultHoursPerWeek,
              IsActive AS status,
              TenantId as tenantId,
              DateCreated AS createdDate,
              DateUpdated AS modifiedDate,
              CreatedBy as createdBy,
              UpdatedBy AS modifiedBy,
              IsActive as isActive,
              PayMultiplier as payMultiplier,
              ColorCode as colorCode
          FROM dbo.JobCodes
          WHERE TenantId = @TenantId AND ISNULL(IsActive, 1) = 1
          ORDER BY JobTitle ASC
          FOR JSON PATH;
      END TRY
      BEGIN CATCH
          SELECT
              ERROR_NUMBER() AS errorNumber,
              ERROR_MESSAGE() AS errorMessage
          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
      END CATCH
  END
GO

/* ----- dbo.usp_JobCodes_GetById.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_GetById]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ankur
-- Create date: 13-10-2025
-- Description: Get a Job Code by ID
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[usp_JobCodes_GetById]
    @Id INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        TenantId,
        JobCode,
        JobTitle,
        Description,
        Category,
        IsExempt,
        PayMultiplier,
        PayRate,
        DefaultHoursPerWeek,
        IsActive,
        CreatedBy,
        UpdatedBy,
        DateCreated,
        DateUpdated,
        ColorCode
    FROM JobCodes
    WHERE Id = @Id
        AND TenantId = @TenantId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

/* ----- dbo.usp_JobCodes_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Stored Procedure: usp_JobCodes_GetShortList
-- Description: Get a short list of job codes for dropdowns/lookups
-- Parameters: @TenantId (int) - The tenant ID to filter job codes
-- =======================================================================
CREATE   PROCEDURE [dbo].[usp_JobCodes_GetShortList]
    @TenantId INT
AS
BEGIN
    
        SELECT
            id,
            jobTitle,
            jobCode,
            category
        FROM
            dbo.JobCodes
        WHERE
            TenantId = @TenantId
            AND ISNULL(IsActive, 1) = 1
        ORDER BY
            JobTitle ASC

		FOR JSON PATH, INCLUDE_NULL_VALUES

   
END
GO

/* ----- dbo.usp_JobCodes_Update.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_JobCodes_Update]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================
-- Stored Procedure: usp_JobCodes_Update
-- Purpose: Update an existing Job Code
-- ============================================
CREATE   PROCEDURE [dbo].[usp_JobCodes_Update]
    @Id INT,
    @JobTitle NVARCHAR(100),
    @Code NVARCHAR(50),
    @Description NVARCHAR(500),
    @Category NVARCHAR(50),
    @IsExempt BIT = 0,
    @PayRate DECIMAL(18,2) = 0,
    @DefaultHoursPerWeek INT = 40,
    @IsActive BIT = 1,
    @TenantId INT,
    @ModifiedBy INT = NULL,
    @ColorCode NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result TABLE (Success INT, Message NVARCHAR(500));

    BEGIN TRY
        -- Trim input values
        SET @JobTitle = LTRIM(RTRIM(@JobTitle));
        SET @Code = LTRIM(RTRIM(@Code));
        SET @Description = LTRIM(RTRIM(@Description));

        -- Validate required fields
        IF @JobTitle IS NULL OR @JobTitle = ''
        BEGIN
            INSERT INTO @Result (Success, Message) VALUES (0, 'Job Title is required');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        IF @Code IS NULL OR @Code = ''
        BEGIN
            INSERT INTO @Result (Success, Message) VALUES (0, 'Job Code is required');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        -- Check if record exists
        IF NOT EXISTS (SELECT 1 FROM JobCodes WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            INSERT INTO @Result (Success, Message) VALUES (0, 'Job Code not found');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        -- *** FIXED: Case-insensitive and whitespace-trimmed duplicate check (excluding current record) ***
        IF EXISTS (SELECT 1 FROM JobCodes
                   WHERE LOWER(LTRIM(RTRIM(JobCode))) = LOWER(LTRIM(RTRIM(@Code)))
                   AND TenantId = @TenantId
                   AND Id != @Id
                   AND IsActive = 1)
        BEGIN
            INSERT INTO @Result (Success, Message)
            VALUES (0, 'A Job Code with this code already exists. Please use a different code.');
            SELECT Success, Message FROM @Result;
            RETURN;
        END

        -- Update existing job code
        UPDATE JobCodes
        SET
            JobTitle = @JobTitle,
            JobCode = @Code,
            Description = @Description,
            Category = @Category,
            IsExempt = @IsExempt,
            PayRate = @PayRate,
            DefaultHoursPerWeek = @DefaultHoursPerWeek,
            IsActive = @IsActive,
            ColorCode = @ColorCode,
            UpdatedBy = @ModifiedBy,
            DateUpdated = GETDATE()
        WHERE Id = @Id AND TenantId = @TenantId;

        INSERT INTO @Result (Success, Message) VALUES (1, 'Job Code updated successfully');
        SELECT Success, Message FROM @Result;
    END TRY
    BEGIN CATCH
        INSERT INTO @Result (Success, Message)
        VALUES (0, 'Error: ' + ERROR_MESSAGE());
        SELECT Success, Message FROM @Result;
    END CATCH
END
GO

/* ----- dbo.usp_Labels_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Labels_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Labels_Delete]
    @LabelId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the label is assigned to any shifts
        IF EXISTS (
            SELECT 1 
            FROM Shifts 
            WHERE ShiftLabelId = @LabelId 
                AND TenantId = @TenantId
        )
        BEGIN
            SELECT
                cast(0 as bit) AS success,
                'Cannot delete this label because it is assigned to one or more shifts. Please remove the shift assignments first.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Delete the label
        DELETE FROM Labels
        WHERE Id = @LabelId
            AND TenantId = @TenantId;

        -- Check if any rows were affected
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT
                cast(0 as bit) AS success,
                'Label not found or already deleted.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            cast(1 as bit) AS success,
            'Label deleted successfully.' AS message
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

/* ----- dbo.usp_Labels_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Labels_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Labels_Get]
	@LabelId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'LabelName',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	;WITH _rows AS (
		SELECT 
			l.Id as id,
			l.LabelName as labelName,
			l.LabelCode as labelCode,
			l.Description as description,
			l.ColorCode as colorCode,
			l.IconCode as iconCode,
			l.IsActive as isActive,
			l.CreatedBy as createdBy,
			l.UpdatedBy as updatedBy,
			l.DateCreated as dateCreated,
			l.DateUpdated as dateUpdated
		FROM Labels l
		WHERE l.TenantId = @TenantId
			AND (@LabelId IS NULL OR l.Id = @LabelId)
			AND (
				@SearchTerm IS NULL OR 
				l.LabelName LIKE '%' + @SearchTerm + '%' OR 
				l.LabelCode LIKE '%' + @SearchTerm + '%' OR 
				l.Description LIKE '%' + @SearchTerm + '%'
			)
	)
	SELECT 
		_rows.id,
		_rows.labelName,
		_rows.labelCode,
		_rows.description,
		_rows.colorCode,
		_rows.iconCode,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		(SELECT count(_rows.id) from _rows) as totalCount
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'LabelName' AND @SortDirection = 'ASC' THEN _rows.labelName END ASC,
		CASE WHEN @SortColumn = 'LabelName' AND @SortDirection = 'DESC' THEN _rows.labelName END DESC,
		CASE WHEN @SortColumn = 'LabelCode' AND @SortDirection = 'ASC' THEN _rows.labelCode END ASC,
		CASE WHEN @SortColumn = 'LabelCode' AND @SortDirection = 'DESC' THEN _rows.labelCode END DESC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'ASC' THEN _rows.description END ASC,
		CASE WHEN @SortColumn = 'Description' AND @SortDirection = 'DESC' THEN _rows.description END DESC,
		_rows.labelName ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Labels_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Labels_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Labels_GetShortList]
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            l.id,
            l.labelName,
            l.labelCode,
            l.colorCode,
            l.iconCode,
            l.isActive
        FROM Labels l
        WHERE l.TenantId = @TenantId
            AND l.IsActive = 1
        ORDER BY l.LabelName ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            cast(0 as bit) AS success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_Labels_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Labels_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Labels_Save]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Id INT;
        DECLARE @LabelName VARCHAR(100);
        DECLARE @LabelCode VARCHAR(55);
        DECLARE @Description NVARCHAR(MAX);
        DECLARE @ColorCode VARCHAR(7);
        DECLARE @IconCode VARCHAR(55);
        DECLARE @IsActive BIT;

        -- Parse JSON
        SELECT 
            @Id = Id,
            @LabelName = LabelName,
            @LabelCode = LabelCode,
            @Description = Description,
            @ColorCode = ColorCode,
            @IconCode = IconCode,
            @IsActive = ISNULL(IsActive, 1)
        FROM OPENJSON(@Json)
        WITH (
            id INT,
            labelName VARCHAR(100),
            labelCode VARCHAR(55),
            description NVARCHAR(MAX),
            colorCode VARCHAR(7),
            iconCode VARCHAR(55),
            isActive BIT
        );

        -- Validate required fields (BEFORE starting transaction)
        IF @LabelName IS NULL OR LTRIM(RTRIM(@LabelName)) = ''
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Label name is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        IF @LabelCode IS NULL OR LTRIM(RTRIM(@LabelCode)) = ''
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Label code is required.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check for duplicate label name (excluding current record if updating)
        IF EXISTS (
            SELECT 1 
            FROM Labels 
            WHERE LabelName = @LabelName 
                AND TenantId = @TenantId 
                AND (@Id IS NULL OR Id != @Id)
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'A label with this name already exists.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- Check for duplicate label code (excluding current record if updating)
        IF EXISTS (
            SELECT 1 
            FROM Labels 
            WHERE LabelCode = @LabelCode 
                AND TenantId = @TenantId 
                AND (@Id IS NULL OR Id != @Id)
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'A label with this code already exists.' AS message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        -- All validations passed, now start transaction
        BEGIN TRANSACTION;

        -- Insert or Update
        IF @Id IS NULL OR @Id = 0
        BEGIN
            -- Insert new label
            INSERT INTO Labels (TenantId, LabelName, LabelCode, Description, ColorCode, IconCode, IsActive, CreatedBy, DateCreated)
            VALUES (@TenantId, @LabelName, @LabelCode, @Description, @ColorCode, @IconCode, @IsActive, @UserId, SYSDATETIMEOFFSET());

            SET @Id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Update existing label
            UPDATE Labels
            SET 
                LabelName = @LabelName,
                LabelCode = @LabelCode,
                Description = @Description,
                ColorCode = @ColorCode,
                IconCode = @IconCode,
                IsActive = @IsActive,
                UpdatedBy = @UserId,
                DateUpdated = SYSDATETIMEOFFSET()
            WHERE Id = @Id AND TenantId = @TenantId;

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT
                    CAST(0 AS BIT) AS success,
                    'Label not found or unauthorized.' AS message
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                RETURN;
            END
        END

        COMMIT TRANSACTION;

        -- Return success with the label Id
        SELECT
            @Id AS id,
            CAST(1 AS BIT) AS success,
            'Label saved successfully.' AS message
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

/* ----- dbo.usp_Layouts_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Layouts_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Get short list of layouts for a tenant
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Layouts_GetShortList]
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameter
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Get layouts for the tenant
        SELECT 
            [Id] as [id],
            [LayoutName] as [layoutName],
            [Type] as [type],
            [Description] as [description],
            [Rows] as [rows],
            [Columns] as [columns]
        FROM [dbo].[Layouts]
        WHERE [TenantId] = @TenantId
        ORDER BY [Type], [LayoutName]
		FOR JSON AUTO, INCLUDE_NULL_VALUES

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_Layouts_SaveGridCells.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Layouts_SaveGridCells]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Layouts_SaveGridCells]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse JSON data
        DECLARE @LayoutId INT = JSON_VALUE(@Json, '$.layoutId');
        
        -- Validate LayoutId
        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'Error' AS Status, 'Invalid LayoutId' AS Message;
            RETURN;
        END
        
        -- Create temporary table to hold the parsed JSON data
        CREATE TABLE #TempGridCells (
            RowNumber INT,
            ColumnNumber INT,
            ColumnId INT,
            ColumnName NVARCHAR(255),
            BackgroundColor NVARCHAR(50),
            DisplayOrder INT
        );
        
        -- Parse JSON and insert into temp table
        INSERT INTO #TempGridCells (RowNumber, ColumnNumber, ColumnId, ColumnName, BackgroundColor, DisplayOrder)
        SELECT 
            JSON_VALUE(gridCells.value, '$.rowNumber') AS RowNumber,
            JSON_VALUE(gridCells.value, '$.columnNumber') AS ColumnNumber,
            JSON_VALUE(col.value, '$.id') AS ColumnId,
            JSON_VALUE(col.value, '$.columnName') AS ColumnName,
            JSON_VALUE(col.value, '$.backgroundColor') AS BackgroundColor,
            JSON_VALUE(col.value, '$.displayOrder') AS DisplayOrder
        FROM OPENJSON(@Json, '$.gridCells') AS gridCells
        CROSS APPLY OPENJSON(gridCells.value, '$.columns') AS col
        WHERE JSON_VALUE(gridCells.value, '$.rowNumber') IS NOT NULL
          AND JSON_VALUE(gridCells.value, '$.columnNumber') IS NOT NULL
          AND JSON_VALUE(col.value, '$.id') IS NOT NULL;
        
        -- Step 1: DELETE records that exist in table but NOT in JSON
        -- Delete records where RowNumber + ColumnNumber + LayoutId match but ColumnId is not in the JSON
        DELETE FROM LayoutGridColumns 
        WHERE LayoutId = @LayoutId 
          AND TenantId = @TenantId
          AND EXISTS (
              SELECT 1 FROM LayoutGridColumns lg 
              WHERE lg.LayoutId = @LayoutId 
                AND lg.TenantId = @TenantId
                AND lg.RowNumber = LayoutGridColumns.RowNumber
                AND lg.ColumnNumber = LayoutGridColumns.ColumnNumber
                AND lg.ColumnId = LayoutGridColumns.ColumnId
          )
          AND NOT EXISTS (
              SELECT 1 FROM #TempGridCells t 
              WHERE t.RowNumber = LayoutGridColumns.RowNumber
                AND t.ColumnNumber = LayoutGridColumns.ColumnNumber
                AND t.ColumnId = LayoutGridColumns.ColumnId
          );
        
        -- Step 2: INSERT records that exist in JSON but NOT in table
        INSERT INTO LayoutGridColumns (
            ColumnId,
            RowNumber,
            ColumnNumber,
            LayoutId,
            DisplayOrder,
            TenantId,
            CreatedBy,
            UpdatedBy,
            DateCreated,
            DateUpdated
        )
        SELECT 
            t.ColumnId,
            t.RowNumber,
            t.ColumnNumber,
            @LayoutId,
            t.DisplayOrder,
            @TenantId,
            @UserId,
            @UserId,
            GETUTCDATE(),
            GETUTCDATE()
        FROM #TempGridCells t
        WHERE NOT EXISTS (
            SELECT 1 FROM LayoutGridColumns lg 
            WHERE lg.LayoutId = @LayoutId 
              AND lg.TenantId = @TenantId
              AND lg.RowNumber = t.RowNumber
              AND lg.ColumnNumber = t.ColumnNumber
              AND lg.ColumnId = t.ColumnId
        );
        
        -- Step 3: UPDATE DisplayOrder for existing records that might have changed order
        UPDATE lg
        SET DisplayOrder = t.DisplayOrder,
            UpdatedBy = @UserId,
            DateUpdated = GETUTCDATE()
        FROM LayoutGridColumns lg
        INNER JOIN #TempGridCells t ON (
            lg.LayoutId = @LayoutId 
            AND lg.TenantId = @TenantId
            AND lg.RowNumber = t.RowNumber
            AND lg.ColumnNumber = t.ColumnNumber
            AND lg.ColumnId = t.ColumnId
        )
        WHERE lg.DisplayOrder != t.DisplayOrder;
        
        -- Clean up temp table
        DROP TABLE #TempGridCells;
        
        -- Return success response
        SELECT 'Success' AS success, 'Grid cells saved successfully' AS message
		FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Return error information
        SELECT 
            'Error' AS Status,
            'Error saving grid cells: ' + ERROR_MESSAGE() AS Message;
        
        -- Log error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

/* ----- dbo.usp_Layouts_SaveRowsColumns.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Layouts_SaveRowsColumns]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Save Layout Rows and Columns
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_Layouts_SaveRowsColumns]
    @Json NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        DECLARE @LayoutId INT = NULL
        DECLARE @Rows INT = NULL
        DECLARE @Columns INT = NULL

        -- Parse JSON parameters
        SELECT 
            @LayoutId = JSON_VALUE(@Json, '$.layoutId'),
            @Rows = JSON_VALUE(@Json, '$.rows'),
            @Columns = JSON_VALUE(@Json, '$.columns')

        -- Validate required parameters
        IF @LayoutId IS NULL
        BEGIN
            SELECT '{"success": false, "message": "LayoutId is required"}' as Result
            RETURN
        END

        -- Update existing layout with rows and columns
        UPDATE [dbo].[Layouts]
        SET 
            [UpdatedBy] = @UserId,
            [DateUpdated] = GETUTCDATE(),
            [Rows] = @Rows,
            [Columns] = @Columns
        WHERE [Id] = @LayoutId 
        AND [TenantId] = @TenantId

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT '{"success": false, "message": "Layout not found or access denied"}' as Result
            RETURN
        END

        SELECT '{"success": true, "message": "Layout rows and columns updated successfully", "layoutId": ' + CAST(@LayoutId AS NVARCHAR(10)) + '}' as Result

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO

/* ----- dbo.usp_Schedules_GetBySource.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Schedules_GetBySource]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[usp_Schedules_GetBySource]
	@SourceIds varchar(max),
	@SourceTypes varchar(max),
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		s.Id as id,
		s.SourceType as sourceType,
		s.SourceId as sourceId,
		s.StartFrom as startFrom,
		s.ScheduleWithoutTimes as scheduleWithoutTimes,
		s.StartTime as startTime,
		s.EndTime as endTime,
		s.ScheduleType as scheduleType,
		s.RepeatEvery as repeatEvery,
		s.EndType as endType,
		s.ValidUntil as validUntil,
		s.MaxOccurrences as maxOccurrences,
		s.Createdby as createdBy,
		s.UpdatedBy as updatedBy,
		s.DateCreated as dateCreated,
		s.DateUpdated as dateUpdated,
		-- Get Frequency array
		(
			SELECT 
				sf.id,
				sf.scheduleId,
				sf.Day as [day],
				sf.DayType as dayType
			FROM ScheduleFrequencies sf
			WHERE sf.ScheduleId = s.Id
				AND sf.TenantId = @TenantId
				AND ISNULL(sf.IsActive, 1) = 1
			FOR JSON PATH,INCLUDE_NULL_VALUES
		) as frequency
	FROM Schedules s
	WHERE s.SourceType in (select * from string_split(@SourceTypes, ','))
		AND s.SourceId in (select * from string_split(@SourceIds, ','))
		AND s.TenantId = @TenantId
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Schedules_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Schedules_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/17/2025
-- Description:	Save Schedule and its Frequencies
-- =============================================
CREATE   PROCEDURE [dbo].[usp_Schedules_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Declare variables for schedule fields
		DECLARE @Id int
		DECLARE @ScheduleName varchar(255)
		DECLARE @StartFrom date
		DECLARE @ValidUntil datetimeoffset(7)
		DECLARE @ScheduleType int
		DECLARE @RepeatEvery int
		DECLARE @ScheduleWithoutTimes bit
		DECLARE @StartTime time(7)
		DECLARE @EndTime time(7)
		DECLARE @MaxOccurrences int
		DECLARE @EndType nvarchar(50)
		DECLARE @IsActive bit
		DECLARE @SourceType int
		DECLARE @SourceId int

		-- Parse JSON for schedule data
		SELECT 
			@Id = id,
			@StartFrom = startFrom,
			@ValidUntil = validUntil,
			@ScheduleType = scheduleType,
			@RepeatEvery = repeatEvery,
			@ScheduleWithoutTimes = ISNULL(scheduleWithoutTimes, 0),
			@StartTime = startTime,
			@EndTime = endTime,
			@MaxOccurrences = maxOccurrences,
			@EndType = endType,
			@IsActive = ISNULL(isActive, 1),
			@SourceType = sourceType,
			@SourceId = sourceId
		FROM OPENJSON(@Json) WITH (
			id int,
			startFrom date,
			validUntil datetimeoffset(7),
			scheduleType int,
			repeatEvery int,
			scheduleWithoutTimes bit,
			startTime time(7),
			endTime time(7),
			maxOccurrences int,
			endType nvarchar(50),
			isActive bit,
			sourceType int,
			sourceId int
		)

		-- Generate schedule name if not provided
		SET @ScheduleName = 'Schedule_' + CAST(@SourceType AS varchar(10)) + '_' + CAST(@SourceId AS varchar(10))

		-- Check if Schedule exists
		IF EXISTS (SELECT 1 FROM Schedules WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Schedule
			UPDATE Schedules
			SET 
				ScheduleName = @ScheduleName,
				SourceType = @SourceType,
				SourceId = @SourceId,
				StartFrom = @StartFrom,
				ValidUntil = @ValidUntil,
				ScheduleType = @ScheduleType,
				RepeatEvery = @RepeatEvery,
				ScheduleWithoutTimes = @ScheduleWithoutTimes,
				StartTime = @StartTime,
				EndTime = @EndTime,
				MaxOccurrences = @MaxOccurrences,
				EndType = @EndType,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			-- Handle Schedule Frequencies - smart delete and insert
			-- First, create a temp table to store incoming frequencies
			DECLARE @IncomingFrequencies TABLE (
				Day int,
				DayType int
			)

			-- Populate temp table with incoming frequencies
			INSERT INTO @IncomingFrequencies (Day, DayType)
			SELECT 
				day,
				dayType
			FROM OPENJSON(@Json) 
			WITH (
				frequency nvarchar(max) AS JSON
			)
			CROSS APPLY OPENJSON(frequency) WITH (
				day int,
				dayType int
			)

			-- Delete frequencies that are NOT in the incoming list
			DELETE FROM ScheduleFrequencies
			WHERE ScheduleId = @Id
				AND NOT EXISTS (
					SELECT 1 FROM @IncomingFrequencies i
					WHERE i.Day = ScheduleFrequencies.Day 
						AND i.DayType = ScheduleFrequencies.DayType
				)

			-- Insert new frequencies that don't already exist
			INSERT INTO ScheduleFrequencies (TenantId, ScheduleId, Day, DayType, IsActive, CreatedBy, DateCreated)
			SELECT 
				@TenantId,
				@Id,
				i.Day,
				i.DayType,
				1, -- IsActive
				@UserId,
				GETUTCDATE()
			FROM @IncomingFrequencies i
			WHERE NOT EXISTS (
				SELECT 1 
				FROM ScheduleFrequencies sf
				WHERE sf.ScheduleId = @Id
					AND sf.Day = i.Day
					AND sf.DayType = i.DayType
			)

			SELECT @Id as id, CAST(1 AS bit) as success, 'Schedule updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			print('haha')
			-- Insert new Schedule
			INSERT INTO Schedules (
				TenantId,
				ScheduleName,
				SourceType,
				SourceId,
				StartFrom,
				ValidUntil,
				ScheduleType,
				RepeatEvery,
				ScheduleWithoutTimes,
				StartTime,
				EndTime,
				MaxOccurrences,
				EndType,
				Createdby,
				DateCreated
			)
			VALUES (
				@TenantId,
				@ScheduleName,
				@SourceType,
				@SourceId,
				@StartFrom,
				@ValidUntil,
				@ScheduleType,
				@RepeatEvery,
				@ScheduleWithoutTimes,
				@StartTime,
				@EndTime,
				@MaxOccurrences,
				@EndType,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()
			print('hehe')
			-- Insert Schedule Frequencies
			INSERT INTO ScheduleFrequencies (TenantId, ScheduleId, Day, DayType, IsActive, CreatedBy, DateCreated)
			SELECT 
				@TenantId,
				@Id,
				day,
				dayType,
				1, -- IsActive
				@UserId,
				GETUTCDATE()
			FROM OPENJSON(@Json) 
			WITH (
				frequency nvarchar(max) AS JSON
			)
			CROSS APPLY OPENJSON(frequency) WITH (
				day int,
				dayType int
			)

			SELECT @Id as id, CAST(1 AS bit) as success, 'Schedule created successfully' as message
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

/* ----- dbo.usp_ShiftAssignment_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftAssignment_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Get shift assignments by userIds or shiftIds
-- =============================================

CREATE   PROCEDURE [dbo].[usp_ShiftAssignment_Get]
    @UserIds NVARCHAR(MAX) = NULL,
    @ShiftIds NVARCHAR(MAX) = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Get all shift assignments matching the criteria
        SELECT 
            sa.Id as id,
            sa.ShiftId as shiftId,
            sa.UserId as userId,
            sa.StatusCustomTableValueId as statusCustomTableValueId,
            sa.Notes as notes,
            sa.AssignedAt as assignedAt,
            sa.Assignedby as assignedBy,
            sa.StartTime as startTime,
            sa.EndTime as endTime,
            sa.ScheduleId as scheduleId,
            sa.CreatedBy as createdBy,
            sa.UpdatedBy as updatedBy,
            sa.DateCreated as dateCreated,
            sa.DateUpdated as dateUpdated,
            -- Shift information
            s.ShiftName as shiftName,
            s.ShiftCode as shiftCode,
            s.BackgroundColour as shiftBackgroundColour,
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
            ) as jobCodes,
            -- Labels array
            (
                SELECT 
                    l.Id as id,
                    l.LabelName as labelName,
                    l.LabelCode as labelCode,
                    l.ColorCode as colorCode,
                    l.IsActive as isActive
                FROM EmployeeShiftAssignmentLabels esl
                INNER JOIN Labels l ON l.Id = esl.LabelId
                WHERE esl.ShiftAssignmentId = sa.Id 
                    AND esl.TenantId = @TenantId
                FOR JSON PATH
            ) as labels
        FROM ShiftAssignment sa
        INNER JOIN Shifts s ON s.Id = sa.ShiftId
        WHERE sa.TenantId = @TenantId
            AND (
                (@UserIds IS NULL OR sa.UserId IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@UserIds, ',')))
                OR
                (@ShiftIds IS NULL OR sa.ShiftId IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@ShiftIds, ',')))
            )
        ORDER BY sa.AssignedAt DESC, sa.DateCreated DESC
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

/* ----- dbo.usp_ShiftAssignment_ScheduleEmployee.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftAssignment_ScheduleEmployee]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-01-06
-- Description: Schedule an employee to a shift with work codes, job codes, and labels
--              Supports both INSERT (new assignment) and UPDATE (existing assignment)
-- =============================================

CREATE   PROCEDURE [dbo].[usp_ShiftAssignment_ScheduleEmployee]
    @JsonData NVARCHAR(MAX),
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ShiftId INT;
    DECLARE @EmployeeUserId INT;
    DECLARE @WorkCodeIds NVARCHAR(MAX);
    DECLARE @JobCodeIds NVARCHAR(MAX);
    DECLARE @LabelIds NVARCHAR(MAX);
    DECLARE @Notes NVARCHAR(MAX);
    DECLARE @AssignmentId INT;
    DECLARE @ExistingAssignmentId INT;
    DECLARE @IsUpdate BIT = 0;
    DECLARE @CurrentDateTime DATETIMEOFFSET = SYSDATETIMEOFFSET();

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse JSON data
        SELECT 
            @ExistingAssignmentId = JSON_VALUE(@JsonData, '$.id'),
            @ShiftId = JSON_VALUE(@JsonData, '$.shiftId'),
            @EmployeeUserId = JSON_VALUE(@JsonData, '$.userId'),
            @WorkCodeIds = JSON_VALUE(@JsonData, '$.workCodeIds'),
            @JobCodeIds = JSON_VALUE(@JsonData, '$.jobCodeIds'),
            @LabelIds = JSON_VALUE(@JsonData, '$.labelIds'),
            @Notes = JSON_VALUE(@JsonData, '$.notes');

        -- Validate required fields
        IF @ShiftId IS NULL OR @EmployeeUserId IS NULL
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'ShiftId and UserId are required',
                id = NULL,
                shiftId = NULL,
                userId = NULL,
                notes = NULL,
                assignedAt = NULL,
                assignedBy = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate Shift exists
        IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
        BEGIN
            SELECT 
                success = CAST(0 AS BIT),
                message = 'Shift not found',
                id = NULL,
                shiftId = NULL,
                userId = NULL,
                notes = NULL,
                assignedAt = NULL,
                assignedBy = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if this is an update (assignment ID provided)
        IF @ExistingAssignmentId IS NOT NULL
        BEGIN
            -- Validate assignment exists
            IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE Id = @ExistingAssignmentId AND TenantId = @TenantId)
            BEGIN
                SELECT 
                    success = CAST(0 AS BIT),
                    message = 'Shift assignment not found',
                    id = NULL,
                    shiftId = NULL,
                    userId = NULL,
                    notes = NULL,
                    assignedAt = NULL,
                    assignedBy = NULL
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
                
                ROLLBACK TRANSACTION;
                RETURN;
            END

            SET @IsUpdate = 1;
            SET @AssignmentId = @ExistingAssignmentId;

            -- Delete existing junction table records
            DELETE FROM EmployeeShiftAssignmentWorkCodes 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            DELETE FROM EmployeeShiftAssignmentJobCodes 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            DELETE FROM EmployeeShiftAssignmentLabels 
            WHERE ShiftAssignmentId = @AssignmentId AND TenantId = @TenantId;

            -- Update ShiftAssignment table
            UPDATE ShiftAssignment
            SET 
                ShiftId = @ShiftId,
                UserId = @EmployeeUserId,
                Notes = @Notes,
                UpdatedBy = @UserId,
                DateUpdated = @CurrentDateTime
            WHERE Id = @AssignmentId AND TenantId = @TenantId;
        END
        ELSE
        BEGIN
            -- Insert new ShiftAssignment
            INSERT INTO ShiftAssignment (
                TenantId,
                ShiftId,
                UserId,
                StatusCustomTableValueId,
                Notes,
                AssignedAt,
                Assignedby,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @ShiftId,
                @EmployeeUserId,
                1, -- Active status
                @Notes,
                @CurrentDateTime,
                @UserId,
                @UserId,
                @CurrentDateTime
            );

            SET @AssignmentId = SCOPE_IDENTITY();
        END

        -- Insert Work Codes into junction table
        IF @WorkCodeIds IS NOT NULL AND LEN(@WorkCodeIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentWorkCodes (
                TenantId,
                ShiftAssignmentId,
                WorkCodeId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@WorkCodeIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        -- Insert Job Codes into junction table
        IF @JobCodeIds IS NOT NULL AND LEN(@JobCodeIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentJobCodes (
                TenantId,
                ShiftAssignmentId,
                JobCodeId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@JobCodeIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        -- Insert Labels into junction table
        IF @LabelIds IS NOT NULL AND LEN(@LabelIds) > 0
        BEGIN
            INSERT INTO EmployeeShiftAssignmentLabels (
                TenantId,
                ShiftAssignmentId,
                LabelId,
                CreatedBy,
                DateCreated
            )
            SELECT 
                @TenantId,
                @AssignmentId,
                CAST(value AS INT),
                @UserId,
                @CurrentDateTime
            FROM STRING_SPLIT(@LabelIds, ',')
            WHERE LTRIM(RTRIM(value)) <> '';
        END

        COMMIT TRANSACTION;

        -- Get the assignment details for response
        DECLARE @AssignedAt DATETIMEOFFSET;
        DECLARE @AssignedBy INT;
        
        SELECT 
            @AssignedAt = AssignedAt,
            @AssignedBy = Assignedby
        FROM ShiftAssignment
        WHERE Id = @AssignmentId AND TenantId = @TenantId;

        -- Return the created/updated assignment
        SELECT 
            success = CAST(1 AS BIT),
            message = CASE WHEN @IsUpdate = 1 THEN 'Employee shift assignment updated successfully' ELSE 'Employee scheduled successfully' END,
            id = @AssignmentId,
            shiftId = @ShiftId,
            userId = @EmployeeUserId,
            notes = @Notes,
            assignedAt = @AssignedAt,
            assignedBy = @AssignedBy
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        SELECT 
            success = CAST(0 AS BIT),
            message = @ErrorMessage,
            id = NULL,
            shiftId = NULL,
            userId = NULL,
            notes = NULL,
            assignedAt = NULL,
            assignedBy = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_ShiftAssignment_UpdateScheduleId.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftAssignment_UpdateScheduleId]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Time Management Team
-- Create date: 2025-11-07
-- Description: Updates the ScheduleId for a shift assignment record
-- =============================================
CREATE   PROCEDURE [dbo].[usp_ShiftAssignment_UpdateScheduleId]
    @AssignmentId INT,
    @ScheduleId INT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate shift assignment exists for tenant
        IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE Id = @AssignmentId AND TenantId = @TenantId)
        BEGIN
            SELECT
                success = CAST(0 AS BIT),
                message = 'Shift assignment not found.',
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Ensure schedule exists for tenant (optional but keeps data integrity)
        IF NOT EXISTS (SELECT 1 FROM Schedules WHERE Id = @ScheduleId AND TenantId = @TenantId)
        BEGIN
            SELECT
                success = CAST(0 AS BIT),
                message = 'Schedule not found.',
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Ensure schedule is not linked to a different assignment for this tenant
        IF EXISTS (
            SELECT 1
            FROM ShiftAssignment
            WHERE TenantId = @TenantId
              AND ScheduleId = @ScheduleId
              AND Id <> @AssignmentId
        )
        BEGIN
            SELECT
                success = CAST(0 AS BIT),
                message = 'Schedule is already linked to a different shift assignment.',
                assignmentId = NULL,
                scheduleId = NULL
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE ShiftAssignment
        SET
            ScheduleId = @ScheduleId,
            UpdatedBy = @UserId,
            DateUpdated = SYSDATETIMEOFFSET()
        WHERE Id = @AssignmentId
          AND TenantId = @TenantId;

        COMMIT TRANSACTION;

        SELECT
            success = CAST(1 AS BIT),
            message = 'Schedule linked to shift assignment successfully.',
            assignmentId = @AssignmentId,
            scheduleId = @ScheduleId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            success = CAST(0 AS BIT),
            message = ERROR_MESSAGE(),
            assignmentId = NULL,
            scheduleId = NULL
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END

GO

/* ----- dbo.usp_ShiftGroups_AssignToShift.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_ShiftGroups_AssignToShift]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Assign existing groups to a shift
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ShiftGroups_AssignToShift]
	@ShiftId int,
	@GroupIds varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Validate Shift exists
		IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete existing assignments for this shift
		DELETE FROM ShiftGroupAssignment 
		WHERE ShiftId = @ShiftId AND TenantId = @TenantId

		-- Insert new group assignments
		INSERT INTO ShiftGroupAssignment (ShiftId, GroupId, CreatedBy, DateCreated, TenantId)
		SELECT 
			@ShiftId,
			CAST(value AS int),
			@UserId,
			GETUTCDATE(),
			@TenantId
		FROM STRING_SPLIT(@GroupIds, ',')
		WHERE RTRIM(value) != ''
			AND EXISTS (SELECT 1 FROM Groups WHERE Id = CAST(value AS int) AND TenantId = @TenantId)

		SELECT 
			CAST(1 AS bit) as success,
			'Groups assigned to shift successfully' as message
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_Shifts_AssignLabel.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_AssignLabel]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Shifts_AssignLabel]
	@ShiftId int,
	@LabelId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Shift exists
		IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Label exists
		IF NOT EXISTS (SELECT 1 FROM Labels WHERE Id = @LabelId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Label not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Update the shift with the new label
		UPDATE Shifts
		SET 
			ShiftLabelId = @LabelId,
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @ShiftId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Label assigned to shift successfully' as message,
			@LabelId as labelId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_Shifts_Close.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_Close]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Shifts_Close]
	@ShiftId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Shift exists
		IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Update the Shift to set StatusCustomTableValueId = 2 (Closed)
		UPDATE Shifts 
		SET 
			StatusCustomTableValueId = 2, -- 2 = Closed
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @ShiftId AND TenantId = @TenantId

		Update Schedules set ValidUntil = GETUTCDATE()
		Where SourceId = @ShiftId and SourceType = 1

		SELECT 
			CAST(1 AS bit) as success,
			'Shift closed successfully' as message,
			@ShiftId as closedId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_Shifts_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Delete Shift
-- =============================================
CREATE   PROCEDURE [dbo].[usp_Shifts_Delete]
	@ShiftId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Shift exists
		IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the Shift
		Update Shifts set StatusCustomTableValueId = 3, DateDeleted = Getutcdate(), DeletedBy = @UserId
		WHERE Id = @ShiftId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Shift deleted successfully' as message,
			@ShiftId as deletedId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_Shifts_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 2. UPDATE PROCEDURE: usp_Shifts_Get
-- =============================================
-- Add shiftGroupAssignments, workCodes, and jobCodes to SELECT statement
-- =============================================

CREATE PROCEDURE [dbo].[usp_Shifts_Get]
	@ShiftId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'DisplayOrder',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL,
	@StatusCustomTableValueId int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

	IF(@StatusCustomTableValueId IS NULL)
	BEGIN
		SET @StatusCustomTableValueId = 1;
	END

	;WITH _rows AS (
		SELECT *
		FROM [dbo].[fn_GetShiftData](@TenantId)
		WHERE (@ShiftId IS NULL OR id = @ShiftId)
			AND (
				@SearchTerm IS NULL OR 
				shiftName LIKE '%' + @SearchTerm + '%' OR 
				shiftCode LIKE '%' + @SearchTerm + '%' OR
				location LIKE '%' + @SearchTerm + '%'
			)
			AND statusCustomTableValueId = @StatusCustomTableValueId
	)
	SELECT 
		_rows.id,
		_rows.shiftName,
		_rows.shiftCode,
		_rows.minimumPositions,
		_rows.maxTimeOffs,
		_rows.location,
		_rows.isWorkShift,
		_rows.isSelfSchedulingEnabled,
		_rows.isSelfSchedulingRequiresAdminApprovals,
		_rows.isHideOpenSlots,
		_rows.shiftLabelId,
		_rows.backgroundColour,
		_rows.isActive,
		_rows.createdBy,
		_rows.updatedBy,
		_rows.dateCreated,
		_rows.dateUpdated,
		_rows.displayOrder,
		(SELECT count(_rows.id) from _rows) as totalCount,
		_rows.scheduleWithoutTimes,
		_rows.scheduleStartFrom,
		_rows.scheduleStartTime,
		_rows.scheduleType,
		-- *** NEW: Added these three columns ***
		_rows.shiftGroupAssignments,
		_rows.workCodes,
		_rows.jobCodes
		-- *** END NEW ***
	FROM _rows
	ORDER BY 
		CASE WHEN @SortColumn = 'ShiftName' AND @SortDirection = 'ASC' THEN _rows.shiftName END ASC,
		CASE WHEN @SortColumn = 'ShiftName' AND @SortDirection = 'DESC' THEN _rows.shiftName END DESC,
		CASE WHEN @SortColumn = 'ShiftCode' AND @SortDirection = 'ASC' THEN _rows.shiftCode END ASC,
		CASE WHEN @SortColumn = 'ShiftCode' AND @SortDirection = 'DESC' THEN _rows.shiftCode END DESC,
		CASE WHEN @SortColumn = 'Location' AND @SortDirection = 'ASC' THEN _rows.location END ASC,
		CASE WHEN @SortColumn = 'Location' AND @SortDirection = 'DESC' THEN _rows.location END DESC,
		CASE WHEN @SortColumn = 'DisplayOrder' AND @SortDirection = 'ASC' THEN _rows.displayOrder END ASC,
		CASE WHEN @SortColumn = 'DisplayOrder' AND @SortDirection = 'DESC' THEN _rows.displayOrder END DESC,
		_rows.displayOrder ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Shifts_GetById.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_GetById]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Shifts_GetById]
	@ShiftId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	-- Get main shift data
	SELECT 
		s.Id as id,
		s.ShiftName as shiftName,
		s.ShiftCode as shiftCode,
		s.MinimumPositions as minimumPositions,
		s.MaxTimeOffs as maxTimeOffs,
		s.Location as location,
		s.IsWorkShift as isWorkShift,
		s.IsSelfSchedulingEnabled as isSelfSchedulingEnabled,
		s.IsSelfSchedulingRequiresAdminApprovals as isSelfSchedulingRequiresAdminApprovals,
		s.IsHideOpenSlots as isHideOpenSlots,
		s.ShiftLabelId as shiftLabelId,
		s.BackgroundColour as backgroundColour,
		s.IsActive as isActive,
		s.CreatedBy as createdBy,
		s.UpdatedBy as updatedBy,
		s.DateCreated as dateCreated,
		s.DateUpdated as dateUpdated,
		s.DisplayOrder as displayOrder,
		s.StatusCustomTableValueId as statusCustomTableValueId,
		s.AdminIds as adminIds,
		-- Get WorkCodes array from ShiftWorkCodeAssignment junction table
		(
			SELECT 
				wc.Id as id,
				wc.WorkCodeName as workCodeName,
				wc.WorkCode as workCodeCode,
				wc.ColorCode as backgroundColour,
				wc.IsActive as isActive,
				swca.IsRequired as isRequired
			FROM ShiftWorkCodeAssignment swca
			INNER JOIN WorkCodes wc ON swca.WorkCodeId = wc.Id
			WHERE swca.ShiftId = s.Id
				AND swca.TenantId = @TenantId
				AND ISNULL(swca.IsActive, 1) = 1
			FOR JSON PATH
		) as workCodes,
		-- Get JobCodes array from ShiftJobCodeAssignment junction table
		(
			SELECT 
				jc.Id as id,
				jc.JobTitle as jobTitle,
				jc.JobCode as jobCode,
				jc.IsActive as isActive
			FROM ShiftJobCodeAssignment sjca
			INNER JOIN JobCodes jc ON sjca.JobCodeId = jc.Id
			WHERE sjca.ShiftId = s.Id
				AND sjca.TenantId = @TenantId
			FOR JSON PATH
		) as jobCodes
	FROM Shifts s
	WHERE s.Id = @ShiftId AND s.TenantId = @TenantId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Shifts_GetSchedulingShifts.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_GetSchedulingShifts]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. UPDATE PROCEDURE: usp_Shifts_GetSchedulingShifts
-- =============================================
-- Add a. prefix to shiftGroupAssignments and add workCodes, jobCodes
-- =============================================

CREATE PROCEDURE [dbo].[usp_Shifts_GetSchedulingShifts]
(
    @TenantId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT distinct
        a.id,
        a.shiftName,
        a.shiftCode,
        a.minimumPositions,
        a.maxTimeOffs,
        a.location,
        a.isWorkShift,
        a.isSelfSchedulingEnabled,
        a.isSelfSchedulingRequiresAdminApprovals,
        a.isHideOpenSlots,
        a.shiftLabelId,
        a.labelName,
        a.labelCode,
        a.colorCode,
        a.backgroundColour,
        a.isActive,
        a.createdBy,
        a.updatedBy,
        a.dateCreated,
        a.dateUpdated,
        a.displayOrder,
        a.statusCustomTableValueId,
        -- *** UPDATED: Added a. prefix and new columns ***
        a.shiftGroupAssignments,
        a.workCodes,
        a.jobCodes
        -- *** END NEW ***
    FROM dbo.fn_GetShiftData(@TenantId) a
    for json path, include_null_values
END
GO

/* ----- dbo.usp_Shifts_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------------------------------------------------------============================================================
CREATED BY			: TimeManagement API
CREATED DATE		: 10/15/2025
DESCRIPTION			: Get short list of Shifts for dropdowns/lookups
LAST UPDATED BY		:
DATE LAST UPDATED	:
EXEC [usp_Shifts_GetShortList] 1
---------------------------------------------------------------------============================================================+*/
CREATE   PROCEDURE [dbo].[usp_Shifts_GetShortList]
(
	@TenantId int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		s.Id as id,
		s.ShiftCode as shiftCode,
		s.ShiftName as shiftName,
		s.BackgroundColour as backgroundColour,
		s.IsActive as isActive
	FROM Shifts s
	WHERE s.TenantId = @TenantId
		AND ISNULL(s.IsActive, 1) = 1
		AND s.StatusCustomTableValueId = 1
	ORDER BY s.DisplayOrder ASC, s.ShiftName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_Shifts_GetUnassigned.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_GetUnassigned]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Shifts_GetUnassigned]
    @TenantId INT,
    @LayoutId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate TenantId
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid TenantId parameter"}' as Result
            RETURN
        END

        -- Validate LayoutId
        IF @LayoutId IS NULL OR @LayoutId <= 0
        BEGIN
            SELECT '{"success": false, "message": "Invalid LayoutId parameter"}' as Result
            RETURN
        END

        -- Get shifts that are NOT assigned to ANY column within the specific layout
        SELECT 
            s.[Id] as [id],
            s.[ShiftName] as [shiftName],
            s.[ShiftCode] as [shiftCode],
            s.[BackgroundColour] as [backgroundColour],
            s.[MinimumPositions] as [minimumPositions],
            s.[MaxTimeoffs] as [maxTimeoffs],
            s.[IsWorkShift] as [isWorkShift],
            s.[IsSelfSchedulingEnabled] as [isSelfSchedulingEnabled]
        FROM [dbo].[Shifts] s
        WHERE s.[TenantId] = @TenantId
          AND s.[IsWorkShift] = 1  -- Only work shifts
          AND s.Id NOT IN (
              SELECT DISTINCT cs.ShiftId 
              FROM [dbo].[ColumnShifts] cs 
              WHERE cs.TenantId = @TenantId
                AND cs.LayoutId = @LayoutId
          )
        ORDER BY s.[ShiftName]
        FOR JSON PATH, INCLUDE_NULL_VALUES

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        SELECT '{"success": false, "message": "' + @ErrorMessage + '"}' as Result
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

/* ----- dbo.usp_Shifts_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Shifts_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @ShiftName varchar(255)
		DECLARE @ShiftCode varchar(55)
		DECLARE @MinimumPositions int
		DECLARE @MaxTimeOffs int
		DECLARE @Location varchar(255)
		DECLARE @IsWorkShift bit
		DECLARE @IsSelfSchedulingEnabled bit
		DECLARE @IsSelfSchedulingRequiresAdminApprovals bit
		DECLARE @IsHideOpenSlots bit
		DECLARE @BackgroundColour varchar(7)
		DECLARE @IsActive bit
		DECLARE @DisplayOrder int
		DECLARE @WorkCodeIds varchar(max)
		DECLARE @JobCodeIds varchar(max)
		DECLARE @AdminIds varchar(max)

		-- Parse JSON
		SELECT 
			@Id = id,
			@ShiftName = shiftName,
			@ShiftCode = shiftCode,
			@MinimumPositions = minimumPositions,
			@MaxTimeOffs = maxTimeOffs,
			@Location = location,
			@IsWorkShift = ISNULL(isWorkShift, 0),
			@IsSelfSchedulingEnabled = ISNULL(isSelfSchedulingEnabled, 0),
			@IsSelfSchedulingRequiresAdminApprovals = ISNULL(isSelfSchedulingRequiresAdminApprovals, 0),
			@IsHideOpenSlots = ISNULL(isHideOpenSlots, 0),
			@BackgroundColour = backgroundColour,
			@IsActive = ISNULL(isActive, 1),
			@DisplayOrder = displayOrder,
			@WorkCodeIds = workCodeIds,
			@JobCodeIds = jobCodeIds,
			@AdminIds = adminIds
		FROM OPENJSON(@Json) WITH (
			id int,
			shiftName varchar(255),
			shiftCode varchar(55),
			minimumPositions int,
			maxTimeOffs int,
			location varchar(255),
			isWorkShift bit,
			isSelfSchedulingEnabled bit,
			isSelfSchedulingRequiresAdminApprovals bit,
			isHideOpenSlots bit,
			backgroundColour varchar(7),
			isActive bit,
			displayOrder int,
			workCodeIds varchar(max),
			jobCodeIds varchar(max),
			adminIds varchar(max)
		)

		-- Check if ShiftCode already exists for another shift
		IF EXISTS (
			SELECT 1 FROM Shifts 
			WHERE ShiftCode = @ShiftCode 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift Code already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Shift exists
		IF EXISTS (SELECT 1 FROM Shifts WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Shift
			UPDATE Shifts
			SET 
				ShiftName = @ShiftName,
				ShiftCode = @ShiftCode,
				MinimumPositions = @MinimumPositions,
				MaxTimeOffs = @MaxTimeOffs,
				Location = @Location,
				IsWorkShift = @IsWorkShift,
				IsSelfSchedulingEnabled = @IsSelfSchedulingEnabled,
				IsSelfSchedulingRequiresAdminApprovals = @IsSelfSchedulingRequiresAdminApprovals,
				IsHideOpenSlots = @IsHideOpenSlots,
				BackgroundColour = @BackgroundColour,
				IsActive = @IsActive,
				DisplayOrder = @DisplayOrder,
				AdminIds = @AdminIds,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			-- Handle WorkCode assignments - smart delete and insert
			IF @WorkCodeIds IS NOT NULL AND LEN(@WorkCodeIds) > 0
			BEGIN
				-- Delete work code assignments that are NOT in the incoming list
				DELETE FROM ShiftWorkCodeAssignment 
				WHERE ShiftId = @Id 
					AND WorkCodeId NOT IN (
						SELECT CAST(value AS int) 
						FROM STRING_SPLIT(@WorkCodeIds, ',')
						WHERE RTRIM(value) != ''
					)

				-- Insert new work code assignments that don't already exist
				INSERT INTO ShiftWorkCodeAssignment (ShiftId, WorkCodeId, CreatedBy, DateCreated, IsRequired, IsActive, TenantId)
				SELECT 
					@Id,
					CAST(value AS int),
					@UserId,
					GETUTCDATE(),
					1,
					1,
					@TenantId
				FROM STRING_SPLIT(@WorkCodeIds, ',')
				WHERE RTRIM(value) != ''
					AND CAST(value AS int) NOT IN (
						SELECT WorkCodeId 
						FROM ShiftWorkCodeAssignment 
						WHERE ShiftId = @Id
					)
			END
			ELSE
			BEGIN
				-- If no work codes provided, delete all existing assignments
				DELETE FROM ShiftWorkCodeAssignment WHERE ShiftId = @Id
			END

			-- Handle JobCode assignments - smart delete and insert
			IF @JobCodeIds IS NOT NULL AND LEN(@JobCodeIds) > 0
			BEGIN
				-- Delete job code assignments that are NOT in the incoming list
				DELETE FROM ShiftJobCodeAssignment 
				WHERE ShiftId = @Id 
					AND JobCodeId NOT IN (
						SELECT CAST(value AS int) 
						FROM STRING_SPLIT(@JobCodeIds, ',')
						WHERE RTRIM(value) != ''
					)

				-- Insert new job code assignments that don't already exist
				INSERT INTO ShiftJobCodeAssignment (ShiftId, JobCodeId, CreatedBy, DateCreated, TenantId)
				SELECT 
					@Id,
					CAST(value AS int),
					@UserId,
					GETUTCDATE(),
					@TenantId
				FROM STRING_SPLIT(@JobCodeIds, ',')
				WHERE RTRIM(value) != ''
					AND CAST(value AS int) NOT IN (
						SELECT JobCodeId 
						FROM ShiftJobCodeAssignment 
						WHERE ShiftId = @Id
					)
			END
			ELSE
			BEGIN
				-- If no job codes provided, delete all existing assignments
				DELETE FROM ShiftJobCodeAssignment WHERE ShiftId = @Id
			END

			SELECT @Id as id, CAST(1 AS bit) as success, 'Shift updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new Shift
			INSERT INTO Shifts (
				TenantId,
				ShiftName,
				ShiftCode,
				MinimumPositions,
				MaxTimeOffs,
				Location,
				IsWorkShift,
				IsSelfSchedulingEnabled,
				IsSelfSchedulingRequiresAdminApprovals,
				IsHideOpenSlots,
				BackgroundColour,
				IsActive,
				DisplayOrder,
				AdminIds,
				CreatedBy,
				DateCreated,
				StatusCustomTableValueId
			)
			VALUES (
				@TenantId,
				@ShiftName,
				@ShiftCode,
				@MinimumPositions,
				@MaxTimeOffs,
				@Location,
				@IsWorkShift,
				@IsSelfSchedulingEnabled,
				@IsSelfSchedulingRequiresAdminApprovals,
				@IsHideOpenSlots,
				@BackgroundColour,
				@IsActive,
				@DisplayOrder,
				@AdminIds,
				@UserId,
				GETUTCDATE(),
				1
			)

			SET @Id = SCOPE_IDENTITY()

			-- Insert WorkCode assignments if provided
			IF @WorkCodeIds IS NOT NULL AND LEN(@WorkCodeIds) > 0
			BEGIN
				INSERT INTO ShiftWorkCodeAssignment (ShiftId, WorkCodeId, CreatedBy, DateCreated, IsRequired, IsActive, TenantId)
				SELECT 
					@Id,
					CAST(value AS int),
					@UserId,
					GETUTCDATE(),
					1,
					1,
					@TenantId
				FROM STRING_SPLIT(@WorkCodeIds, ',')
				WHERE RTRIM(value) != ''
			END

			-- Insert JobCode assignments if provided
			IF @JobCodeIds IS NOT NULL AND LEN(@JobCodeIds) > 0
			BEGIN
				INSERT INTO ShiftJobCodeAssignment (ShiftId, JobCodeId, CreatedBy, DateCreated, TenantId)
				SELECT 
					@Id,
					CAST(value AS int),
					@UserId,
					GETUTCDATE(),
					@TenantId
				FROM STRING_SPLIT(@JobCodeIds, ',')
				WHERE RTRIM(value) != ''
			END

			SELECT @Id as id, CAST(1 AS bit) as success, 'Shift created successfully' as message
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

/* ----- dbo.usp_Shifts_UpdateSlotPositions.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shifts_UpdateSlotPositions]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Shifts_UpdateSlotPositions]
	@ShiftId int,
	@Action varchar(10),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Validate action parameter
		IF @Action NOT IN ('increase', 'decrease')
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Invalid action. Must be ''increase'' or ''decrease''' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Shift exists
		IF NOT EXISTS (SELECT 1 FROM Shifts WHERE Id = @ShiftId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Shift not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		DECLARE @CurrentMinimumPositions int
		DECLARE @NewMinimumPositions int

		-- Get current minimumPositions
		SELECT @CurrentMinimumPositions = ISNULL(MinimumPositions, 0)
		FROM Shifts 
		WHERE Id = @ShiftId AND TenantId = @TenantId

		-- Calculate new minimumPositions based on action
		IF @Action = 'increase'
		BEGIN
			SET @NewMinimumPositions = @CurrentMinimumPositions + 1
		END
		ELSE -- decrease
		BEGIN
			-- Don't allow decreasing below 0
			IF @CurrentMinimumPositions <= 0
			BEGIN
				SELECT 
					CAST(0 AS bit) as success,
					'Cannot decrease minimum positions below 0' as message
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				ROLLBACK TRAN
				RETURN
			END
			SET @NewMinimumPositions = @CurrentMinimumPositions - 1
		END

		-- Update the shift
		UPDATE Shifts
		SET 
			MinimumPositions = @NewMinimumPositions,
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @ShiftId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Slot positions updated successfully' as message,
			@NewMinimumPositions as newMinimumPositions
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_TradeBoardSettings.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TradeBoardSettings]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*==================================================================================
CREATED BY            : Ankur
CREATED DATE          : 03/11/2025
DESCRIPTION           : Get Trade Board Settings (Single record per tenant)
LAST UPDATED BY       : Ankur
DATE LAST UPDATED     : 05/11/2025
CHANGE DESCRIPTION    : Modified to return single record or default values if not exists

EXEC [usp_TradeBoardSettings] 1, 1
==================================================================================*/

CREATE PROCEDURE [dbo].[usp_TradeBoardSettings]
(
    @TenantId INT,
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SettingsId INT;
    DECLARE @ResultJson NVARCHAR(MAX);

    -- Check if settings exist for this tenant (regardless of IsActive status)
    SELECT @SettingsId = Id
    FROM TradeBoardSettings
    WHERE TenantId = @TenantId;

    -- If settings exist, return them
    IF @SettingsId IS NOT NULL
    BEGIN
        SELECT @ResultJson = (
            SELECT
                tbs.Id as id,
                tbs.TenantId as tenantId,
                tbs.SettingsName as settingsName,
                ISNULL(tbs.IsLimitTradesToMatchingLists, 0) as isLimitTradesToMatchingLists,
                ISNULL(tbs.IsOnlyAllowDirectTrades, 0) as isOnlyAllowDirectTrades,
                ISNULL(tbs.IsRequireApprovalBeforeSent, 0) as isRequireApprovalBeforeSent,
                ISNULL(tbs.IsRequireApprovalAfterAccepted, 0) as isRequireApprovalAfterAccepted,
                ISNULL(tbs.IsRequireSecondApproval, 0) as isRequireSecondApproval,
                ISNULL(tbs.IsApprovingUsersSeeOnlyTheirRequests, 0) as isApprovingUsersSeeOnlyTheirRequests,
                ISNULL(tbs.IsEnableShiftSwapFeature, 0) as isEnableShiftSwapFeature,
                ISNULL(tbs.IsColorCodeTradedShifts, 0) as isColorCodeTradedShifts,
                ISNULL(tbs.TradedShiftColorCode, '#FF5733') as tradedShiftColorCode,
                ISNULL(tbs.IsRequireManualLedgerApproval, 0) as isRequireManualLedgerApproval,
                ISNULL(tbs.IsUserSelectsApproval, 0) as isUserSelectsApproval,
                ISNULL(tbs.IsActive, 1) as isActive,
                tbs.CreatedBy as createdBy,
                tbs.UpdatedBy as updatedBy,
                tbs.DateCreated as dateCreated,
                tbs.DateUpdated as dateUpdated,
                (
                    SELECT
                        tbr.Id as id,
                        tbr.TenantId as tenantId,
                        tbr.TradeBoardSettingsId as tradeBoardSettingsId,
                        tbr.JobCodeId as jobCodeId,
                        jc.JobTitle as jobTitle,
                        tbr.RuleName as ruleName,
                        tbr.RuleDescription as ruleDescription,
                        ISNULL(tbr.IsActive, 1) as isActive,
                        tbr.CreatedBy as createdBy,
                        tbr.UpdatedBy as updatedBy,
                        tbr.DateCreated as dateCreated,
                        tbr.DateUpdated as dateUpdated
                    FROM TradeBoardListRules tbr
                    LEFT JOIN JobCodes jc ON tbr.JobCodeId = jc.Id AND jc.TenantId = @TenantId
                    WHERE tbr.TradeBoardSettingsId = tbs.Id
                        AND tbr.TenantId = @TenantId
                        AND ISNULL(tbr.IsActive, 1) = 1
                    FOR JSON PATH
                ) as rules
            FROM TradeBoardSettings tbs
            WHERE tbs.Id = @SettingsId
                AND tbs.TenantId = @TenantId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END

    -- Return the result (NULL if no settings exist)
    SELECT @ResultJson as result;

END
GO

/* ----- dbo.usp_TradeBoardSettings_GetList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TradeBoardSettings_GetList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*==================================================================================
CREATED BY            : Ankur
CREATED DATE          : 03/11/2025
DESCRIPTION           : Get Trade Board Settings (Single record per tenant)
LAST UPDATED BY       : Ankur
DATE LAST UPDATED     : 05/11/2025
CHANGE DESCRIPTION    : Modified to return single record or default values if not exists

EXEC [usp_TradeBoardSettings_GetList] 1, 1
==================================================================================*/

CREATE PROCEDURE [dbo].[usp_TradeBoardSettings_GetList]
(
    @TenantId INT,
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SettingsId INT;
    DECLARE @ResultJson NVARCHAR(MAX);

    -- Check if settings exist for this tenant (regardless of IsActive status)
    SELECT @SettingsId = Id
    FROM TradeBoardSettings
    WHERE TenantId = @TenantId;

    -- If settings exist, return them
    IF @SettingsId IS NOT NULL
    BEGIN
        SELECT @ResultJson = (
            SELECT
                tbs.Id as id,
                tbs.TenantId as tenantId,
                tbs.SettingsName as settingsName,
                ISNULL(tbs.IsLimitTradesToMatchingLists, 0) as isLimitTradesToMatchingLists,
                ISNULL(tbs.IsOnlyAllowDirectTrades, 0) as isOnlyAllowDirectTrades,
                ISNULL(tbs.IsRequireApprovalBeforeSent, 0) as isRequireApprovalBeforeSent,
                ISNULL(tbs.IsRequireApprovalAfterAccepted, 0) as isRequireApprovalAfterAccepted,
                ISNULL(tbs.IsRequireSecondApproval, 0) as isRequireSecondApproval,
                ISNULL(tbs.IsApprovingUsersSeeOnlyTheirRequests, 0) as isApprovingUsersSeeOnlyTheirRequests,
                ISNULL(tbs.IsEnableShiftSwapFeature, 0) as isEnableShiftSwapFeature,
                ISNULL(tbs.IsColorCodeTradedShifts, 0) as isColorCodeTradedShifts,
                ISNULL(tbs.TradedShiftColorCode, '#FF5733') as tradedShiftColorCode,
                ISNULL(tbs.IsRequireManualLedgerApproval, 0) as isRequireManualLedgerApproval,
                ISNULL(tbs.IsUserSelectsApproval, 0) as isUserSelectsApproval,
                ISNULL(tbs.IsActive, 1) as isActive,
                tbs.CreatedBy as createdBy,
                tbs.UpdatedBy as updatedBy,
                tbs.DateCreated as dateCreated,
                tbs.DateUpdated as dateUpdated,
                (
                    SELECT
                        tbr.Id as id,
                        tbr.TenantId as tenantId,
                        tbr.TradeBoardSettingsId as tradeBoardSettingsId,
                        tbr.JobCodeId as jobCodeId,
                        jc.JobTitle as jobTitle,
                        tbr.RuleName as ruleName,
                        tbr.RuleDescription as ruleDescription,
                        ISNULL(tbr.IsActive, 1) as isActive,
                        tbr.CreatedBy as createdBy,
                        tbr.UpdatedBy as updatedBy,
                        tbr.DateCreated as dateCreated,
                        tbr.DateUpdated as dateUpdated
                    FROM TradeBoardListRules tbr
                    LEFT JOIN JobCodes jc ON tbr.JobCodeId = jc.Id AND jc.TenantId = @TenantId
                    WHERE tbr.TradeBoardSettingsId = tbs.Id
                        AND tbr.TenantId = @TenantId
                        AND ISNULL(tbr.IsActive, 1) = 1
                    FOR JSON PATH
                ) as rules
            FROM TradeBoardSettings tbs
            WHERE tbs.Id = @SettingsId
                AND tbs.TenantId = @TenantId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END

    -- Return the result (NULL if no settings exist)
    SELECT @ResultJson as result;

END
GO

/* ----- dbo.usp_TradeBoardSettings_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_TradeBoardSettings_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*==================================================================================
CREATED BY            : Ankur
CREATED DATE          : 03/11/2025
DESCRIPTION           : Save Trade Board Settings with Rules (Single record, UPSERT logic)
LAST UPDATED BY       : Ankur
DATE LAST UPDATED     : 05/11/2025
CHANGE DESCRIPTION    : Renamed from SaveBatch, handles single record with MERGE logic for rules

EXEC [usp_TradeBoardSettings_Save] 1, 1, '{...single settings object...}'
==================================================================================*/

CREATE   PROCEDURE [dbo].[usp_TradeBoardSettings_Save]
    @TenantId INT,
    @UserId INT,
    @SettingsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SettingsId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get the settings ID from JSON
        SET @SettingsId = CAST(JSON_VALUE(@SettingsJson, '$.id') AS INT);

        -- If settings exist, update them
        IF @SettingsId IS NOT NULL AND @SettingsId > 0
        BEGIN
            UPDATE TradeBoardSettings
            SET
                SettingsName = ISNULL(JSON_VALUE(@SettingsJson, '$.settingsName'), SettingsName),
                IsLimitTradesToMatchingLists = CAST(JSON_VALUE(@SettingsJson, '$.isLimitTradesToMatchingLists') AS BIT),
                IsOnlyAllowDirectTrades = CAST(JSON_VALUE(@SettingsJson, '$.isOnlyAllowDirectTrades') AS BIT),
                IsRequireApprovalBeforeSent = CAST(JSON_VALUE(@SettingsJson, '$.isRequireApprovalBeforeSent') AS BIT),
                IsRequireApprovalAfterAccepted = CAST(JSON_VALUE(@SettingsJson, '$.isRequireApprovalAfterAccepted') AS BIT),
                IsRequireSecondApproval = CAST(JSON_VALUE(@SettingsJson, '$.isRequireSecondApproval') AS BIT),
                IsApprovingUsersSeeOnlyTheirRequests = CAST(JSON_VALUE(@SettingsJson, '$.isApprovingUsersSeeOnlyTheirRequests') AS BIT),
                IsEnableShiftSwapFeature = CAST(JSON_VALUE(@SettingsJson, '$.isEnableShiftSwapFeature') AS BIT),
                IsColorCodeTradedShifts = CAST(JSON_VALUE(@SettingsJson, '$.isColorCodeTradedShifts') AS BIT),
                TradedShiftColorCode = JSON_VALUE(@SettingsJson, '$.tradedShiftColorCode'),
                IsRequireManualLedgerApproval = CAST(JSON_VALUE(@SettingsJson, '$.isRequireManualLedgerApproval') AS BIT),
                IsUserSelectsApproval = CAST(JSON_VALUE(@SettingsJson, '$.isUserSelectsApproval') AS BIT),
                IsActive = CAST(JSON_VALUE(@SettingsJson, '$.isActive') AS BIT),
                UpdatedBy = @UserId,
                DateUpdated = GETUTCDATE()
            WHERE Id = @SettingsId
                AND TenantId = @TenantId;
        END
        ELSE
        BEGIN
            -- Insert new settings if they don't exist
            INSERT INTO TradeBoardSettings (
                TenantId,
                SettingsName,
                IsLimitTradesToMatchingLists,
                IsOnlyAllowDirectTrades,
                IsRequireApprovalBeforeSent,
                IsRequireApprovalAfterAccepted,
                IsRequireSecondApproval,
                IsApprovingUsersSeeOnlyTheirRequests,
                IsEnableShiftSwapFeature,
                IsColorCodeTradedShifts,
                TradedShiftColorCode,
                IsRequireManualLedgerApproval,
                IsUserSelectsApproval,
                IsActive,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                ISNULL(JSON_VALUE(@SettingsJson, '$.settingsName'), 'Default Trade Board Settings'),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isLimitTradesToMatchingLists') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isOnlyAllowDirectTrades') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isRequireApprovalBeforeSent') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isRequireApprovalAfterAccepted') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isRequireSecondApproval') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isApprovingUsersSeeOnlyTheirRequests') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isEnableShiftSwapFeature') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isColorCodeTradedShifts') AS BIT), 0),
                ISNULL(JSON_VALUE(@SettingsJson, '$.tradedShiftColorCode'), '#FF5733'),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isRequireManualLedgerApproval') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isUserSelectsApproval') AS BIT), 0),
                ISNULL(CAST(JSON_VALUE(@SettingsJson, '$.isActive') AS BIT), 1),
                @UserId,
                GETUTCDATE()
            );

            SET @SettingsId = SCOPE_IDENTITY();
        END

        -- Handle Rules - MERGE logic (UPSERT)
        -- First, mark all existing rules for this settings as inactive (soft delete)
        UPDATE TradeBoardListRules
        SET IsActive = 0,
            UpdatedBy = @UserId,
            DateUpdated = GETUTCDATE()
        WHERE TradeBoardSettingsId = @SettingsId
            AND TenantId = @TenantId;

        -- Now, merge the new rules from JSON
        MERGE INTO TradeBoardListRules AS target
        USING (
            SELECT
                @SettingsId AS TradeBoardSettingsId,
                @TenantId AS TenantId,
                CAST(JSON_VALUE(r.value, '$.jobCodeId') AS INT) AS JobCodeId,
                JSON_VALUE(r.value, '$.ruleName') AS RuleName,
                JSON_VALUE(r.value, '$.ruleDescription') AS RuleDescription,
                ISNULL(CAST(JSON_VALUE(r.value, '$.isActive') AS BIT), 1) AS IsActive
            FROM OPENJSON(@SettingsJson, '$.rules') r
            WHERE CAST(JSON_VALUE(r.value, '$.jobCodeId') AS INT) IS NOT NULL
        ) AS source
        ON target.TradeBoardSettingsId = source.TradeBoardSettingsId
            AND target.TenantId = source.TenantId
            AND target.JobCodeId = source.JobCodeId
        WHEN MATCHED THEN
            UPDATE SET
                RuleName = source.RuleName,
                RuleDescription = source.RuleDescription,
                IsActive = source.IsActive,
                UpdatedBy = @UserId,
                DateUpdated = GETUTCDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                TenantId,
                TradeBoardSettingsId,
                JobCodeId,
                RuleName,
                RuleDescription,
                IsActive,
                CreatedBy,
                DateCreated
            )
            VALUES (
                source.TenantId,
                source.TradeBoardSettingsId,
                source.JobCodeId,
                source.RuleName,
                source.RuleDescription,
                source.IsActive,
                @UserId,
                GETUTCDATE()
            );

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            1 as success,
            'Settings and rules saved successfully' as message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Return error
        SELECT
            0 as success,
            ERROR_MESSAGE() as message,
            ERROR_LINE() as errorLine,
            ERROR_PROCEDURE() as errorProcedure
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

/* ----- dbo.usp_WorkCodes_Delete.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Delete]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Delete WorkCode
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_Delete]
	@WorkCodeId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if WorkCode exists
		IF NOT EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @WorkCodeId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the WorkCode
		DELETE FROM WorkCodes 
		WHERE Id = @WorkCodeId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'WorkCode deleted successfully' as message,
			@WorkCodeId as deletedId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_WorkCodes_Get.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Get]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Get WorkCodes
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_Get]
	@WorkCodeId int = NULL,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		w.Id as id,
		w.WorkCode as workCode,
		w.WorkCodeName as workCodeName,
		w.Description as description,
		w.Category as category,
		w.ColorCode as colorCode,
		w.TextColor as textColor,
		w.PayMultiplier as payMultiplier,
		w.PayRate as payRate,
		w.IsDefault as isDefault,
		w.DisplayOrder as displayOrder,
		w.IsCountsTowardWeeklyLimit as isCountsTowardWeeklyLimit,
		w.IsCountsTowardMonthlyLimit as isCountsTowardMonthlyLimit,
		w.IsIncludeInCallbackRankings as isIncludeInCallbackRankings,
		w.IsExcludesFromCallbacks as isExcludesFromCallbacks,
		w.IsTradeable as isTradeable,
		w.MinTimeBufferHours as minTimeBufferHours,
		w.MaxTimeBufferHours as maxTimeBufferHours,
		w.ExclusionRuleHours as exclusionRuleHours,
		w.LimitPerEmployeePerYear as limitPerEmployeePerYear,
		w.IsRequestable as isRequestable,
		w.IsMasked as isMasked,
		w.IsActive as isActive,
		w.CreatedBy as createdBy,
		w.UpdatedBy as updatedBy,
		w.DateCreated as dateCreated,
		w.DateUpdated as dateUpdated
	FROM WorkCodes w
	WHERE w.TenantId = @TenantId
		AND (@WorkCodeId IS NULL OR w.Id = @WorkCodeId)
	ORDER BY w.DisplayOrder, w.WorkCodeName
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_WorkCodes_GetShortList.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_GetShortList]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------------------------------------------------------============================================================
CREATED BY			: TimeManagement API
CREATED DATE		: 10/15/2025
DESCRIPTION			: Get short list of WorkCodes for dropdowns/lookups
LAST UPDATED BY		:
DATE LAST UPDATED	:
EXEC [usp_WorkCodes_GetShortList] 1
---------------------------------------------------------------------============================================================+*/
CREATE   PROCEDURE [dbo].[usp_WorkCodes_GetShortList]
(
	@TenantId int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		w.Id as id,
		w.WorkCode as workCode,
		w.WorkCodeName as workCodeName,
		w.ColorCode as colorCode,
		w.TextColor as textColor,
		w.IsActive as isActive
	FROM WorkCodes w
	WHERE w.TenantId = @TenantId
		AND ISNULL(w.IsActive, 1) = 1
	ORDER BY w.DisplayOrder ASC, w.WorkCodeName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/* ----- dbo.usp_WorkCodes_Save.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Save]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Save (Insert/Update) WorkCode
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @WorkCode varchar(55)
		DECLARE @WorkCodeName varchar(255)
		DECLARE @Description nvarchar(max)
		DECLARE @Category varchar(55)
		DECLARE @ColorCode varchar(7)
		DECLARE @TextColor varchar(7)
		DECLARE @PayMultiplier decimal(10, 2)
		DECLARE @PayRate decimal(10, 2)
		DECLARE @IsDefault bit
		DECLARE @DisplayOrder int
		DECLARE @IsCountsTowardWeeklyLimit bit
		DECLARE @IsCountsTowardMonthlyLimit bit
		DECLARE @IsIncludeInCallbackRankings bit
		DECLARE @IsExcludesFromCallbacks bit
		DECLARE @IsTradeable bit
		DECLARE @MinTimeBufferHours decimal(5, 2)
		DECLARE @MaxTimeBufferHours decimal(5, 2)
		DECLARE @ExclusionRuleHours decimal(5, 2)
		DECLARE @LimitPerEmployeePerYear int
		DECLARE @IsRequestable bit
		DECLARE @IsMasked bit
		DECLARE @IsActive bit

		-- Parse JSON
		SELECT 
			@Id = id,
			@WorkCode = workCode,
			@WorkCodeName = workCodeName,
			@Description = description,
			@Category = category,
			@ColorCode = colorCode,
			@TextColor = textColor,
			@PayMultiplier = payMultiplier,
			@PayRate = payRate,
			@IsDefault = ISNULL(isDefault, 0),
			@DisplayOrder = displayOrder,
			@IsCountsTowardWeeklyLimit = ISNULL(isCountsTowardWeeklyLimit, 0),
			@IsCountsTowardMonthlyLimit = ISNULL(isCountsTowardMonthlyLimit, 0),
			@IsIncludeInCallbackRankings = ISNULL(isIncludeInCallbackRankings, 0),
			@IsExcludesFromCallbacks = ISNULL(isExcludesFromCallbacks, 0),
			@IsTradeable = ISNULL(isTradeable, 0),
			@MinTimeBufferHours = minTimeBufferHours,
			@MaxTimeBufferHours = maxTimeBufferHours,
			@ExclusionRuleHours = exclusionRuleHours,
			@LimitPerEmployeePerYear = limitPerEmployeePerYear,
			@IsRequestable = ISNULL(isRequestable, 0),
			@IsMasked = ISNULL(isMasked, 0),
			@IsActive = ISNULL(isActive, 1)
		FROM OPENJSON(@Json) WITH (
			id int,
			workCode varchar(55),
			workCodeName varchar(255),
			description nvarchar(max),
			category varchar(55),
			colorCode varchar(7),
			textColor varchar(7),
			payMultiplier decimal(10, 2),
			payRate decimal(10, 2),
			isDefault bit,
			displayOrder int,
			isCountsTowardWeeklyLimit bit,
			isCountsTowardMonthlyLimit bit,
			isIncludeInCallbackRankings bit,
			isExcludesFromCallbacks bit,
			isTradeable bit,
			minTimeBufferHours decimal(5, 2),
			maxTimeBufferHours decimal(5, 2),
			exclusionRuleHours decimal(5, 2),
			limitPerEmployeePerYear int,
			isRequestable bit,
			isMasked bit,
			isActive bit
		)

		-- Check if WorkCode already exists for another record
		IF EXISTS (
			SELECT 1 FROM WorkCodes 
			WHERE WorkCode = @WorkCode 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if WorkCode exists
		IF EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing WorkCode
			UPDATE WorkCodes
			SET 
				WorkCode = @WorkCode,
				WorkCodeName = @WorkCodeName,
				Description = @Description,
				Category = @Category,
				ColorCode = @ColorCode,
				TextColor = @TextColor,
				PayMultiplier = @PayMultiplier,
				PayRate = @PayRate,
				IsDefault = @IsDefault,
				DisplayOrder = @DisplayOrder,
				IsCountsTowardWeeklyLimit = @IsCountsTowardWeeklyLimit,
				IsCountsTowardMonthlyLimit = @IsCountsTowardMonthlyLimit,
				IsIncludeInCallbackRankings = @IsIncludeInCallbackRankings,
				IsExcludesFromCallbacks = @IsExcludesFromCallbacks,
				IsTradeable = @IsTradeable,
				MinTimeBufferHours = @MinTimeBufferHours,
				MaxTimeBufferHours = @MaxTimeBufferHours,
				ExclusionRuleHours = @ExclusionRuleHours,
				LimitPerEmployeePerYear = @LimitPerEmployeePerYear,
				IsRequestable = @IsRequestable,
				IsMasked = @IsMasked,
				IsActive = @IsActive,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			SELECT @Id as id, CAST(1 AS bit) as success, 'WorkCode updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new WorkCode
			INSERT INTO WorkCodes (
				TenantId,
				WorkCode,
				WorkCodeName,
				Description,
				Category,
				ColorCode,
				TextColor,
				PayMultiplier,
				PayRate,
				IsDefault,
				DisplayOrder,
				IsCountsTowardWeeklyLimit,
				IsCountsTowardMonthlyLimit,
				IsIncludeInCallbackRankings,
				IsExcludesFromCallbacks,
				IsTradeable,
				MinTimeBufferHours,
				MaxTimeBufferHours,
				ExclusionRuleHours,
				LimitPerEmployeePerYear,
				IsRequestable,
				IsMasked,
				IsActive,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@WorkCode,
				@WorkCodeName,
				@Description,
				@Category,
				@ColorCode,
				@TextColor,
				@PayMultiplier,
				@PayRate,
				@IsDefault,
				@DisplayOrder,
				@IsCountsTowardWeeklyLimit,
				@IsCountsTowardMonthlyLimit,
				@IsIncludeInCallbackRankings,
				@IsExcludesFromCallbacks,
				@IsTradeable,
				@MinTimeBufferHours,
				@MaxTimeBufferHours,
				@ExclusionRuleHours,
				@LimitPerEmployeePerYear,
				@IsRequestable,
				@IsMasked,
				@IsActive,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()

			SELECT @Id as id, CAST(1 AS bit) as success, 'WorkCode created successfully' as message
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

/* ----- dbo.usp_WorkCodes_UpdateActiveStatus.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_UpdateActiveStatus]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Update WorkCode Active Status
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_UpdateActiveStatus]
	@WorkCodeId int,
	@IsActive bit,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if WorkCode exists
		IF NOT EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @WorkCodeId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Update Active Status
		UPDATE WorkCodes
		SET 
			IsActive = @IsActive,
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @WorkCodeId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'WorkCode active status updated successfully' as message,
			@WorkCodeId as workCodeId,
			@IsActive as isActive
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

/* ----- dbo.usp_WorkCodes_UpdateDefaultStatus.StoredProcedure.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_UpdateDefaultStatus]    Script Date: 11/11/2025 7:54:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Update WorkCode Default Status
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_UpdateDefaultStatus]
	@WorkCodeId int,
	@IsDefault bit,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if WorkCode exists
		IF NOT EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @WorkCodeId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- If setting as default, unset all other defaults for this tenant
		IF @IsDefault = 1
		BEGIN
			UPDATE WorkCodes
			SET 
				IsDefault = 0,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE TenantId = @TenantId AND Id != @WorkCodeId
		END

		-- Update Default Status
		UPDATE WorkCodes
		SET 
			IsDefault = @IsDefault,
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @WorkCodeId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'WorkCode default status updated successfully' as message,
			@WorkCodeId as workCodeId,
			@IsDefault as isDefault
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

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

