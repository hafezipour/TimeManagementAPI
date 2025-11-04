-- =============================================
-- Assistant Qualifiers Module - Stored Procedures
-- Author: TimeManagement API
-- Create date: 11-04-2025
-- Description: All stored procedures for Assistant Qualifiers management
-- =============================================

USE [TimeManagement_DEV]
GO

/*---------------------=========================================================================================================
CREATED BY			: TimeManagement API
CREATED DATE 		: 11/04/2025
DESCRIPTION			: Get Assistant Qualifiers with server-side paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AssistantQualifiers_Get')
    DROP PROCEDURE [dbo].[usp_AssistantQualifiers_Get]
GO

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

-- =============================================
-- 2. usp_AssistantQualifiers_Save - Save (Insert/Update) Assistant Qualifier
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AssistantQualifiers_Save')
    DROP PROCEDURE [dbo].[usp_AssistantQualifiers_Save]
GO

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
            Id INT,
            Name VARCHAR(100),
            Code VARCHAR(55),
            Description NVARCHAR(MAX),
            BackgroundColor VARCHAR(7),
            TextColor VARCHAR(7),
            IsActive BIT
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

-- =============================================
-- 3. usp_AssistantQualifiers_Delete - Delete Assistant Qualifier
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AssistantQualifiers_Delete')
    DROP PROCEDURE [dbo].[usp_AssistantQualifiers_Delete]
GO

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

-- =============================================
-- 4. usp_AssistantQualifiers_GetShortList - Get Short List for Dropdowns
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AssistantQualifiers_GetShortList')
    DROP PROCEDURE [dbo].[usp_AssistantQualifiers_GetShortList]
GO

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
            aq.Id,
            aq.Name,
            aq.Code,
            aq.BackgroundColor,
            aq.TextColor,
            aq.IsActive
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

PRINT 'Assistant Qualifiers Stored Procedures created successfully!'
GO

