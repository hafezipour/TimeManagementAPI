-- =============================================
-- Labels Module - Stored Procedures
-- Author: Ali Nafees
-- Create date: 11-03-2025
-- Description: All stored procedures for Labels management
-- =============================================

USE [TimeManagement_DEV]
GO

/*---------------------=========================================================================================================
CREATED BY			: Ali Nafees
CREATED DATE 		: 11/03/2025
DESCRIPTION			: Get Labels with server-side paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Labels_Get')
    DROP PROCEDURE [dbo].[usp_Labels_Get]
GO

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
			l.TenantId as tenantId,
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
		_rows.tenantId,
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

-- =============================================
-- 2. usp_Labels_Save - Save (Insert/Update) Label
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Labels_Save')
    DROP PROCEDURE [dbo].[usp_Labels_Save]
GO

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
            Id INT,
            LabelName VARCHAR(100),
            LabelCode VARCHAR(55),
            Description NVARCHAR(MAX),
            ColorCode VARCHAR(7),
            IconCode VARCHAR(55),
            IsActive BIT
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

-- =============================================
-- 3. usp_Labels_Delete - Delete Label with Validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Labels_Delete')
    DROP PROCEDURE [dbo].[usp_Labels_Delete]
GO

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
            WHERE LabelId = @LabelId 
                AND TenantId = @TenantId
        )
        BEGIN
            SELECT
                0 AS Success,
                'Cannot delete this label because it is assigned to one or more shifts. Please remove the shift assignments first.' AS Message
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
                0 AS Success,
                'Label not found or already deleted.' AS Message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Return success
        SELECT
            1 AS Success,
            'Label deleted successfully.' AS Message
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

-- =============================================
-- 4. usp_Labels_GetShortList - Get Short List for Dropdowns
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Labels_GetShortList')
    DROP PROCEDURE [dbo].[usp_Labels_GetShortList]
GO

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
            l.Id,
            l.LabelName,
            l.LabelCode,
            l.ColorCode,
            l.IconCode,
            l.IsActive
        FROM Labels l
        WHERE l.TenantId = @TenantId
            AND l.IsActive = 1
        ORDER BY l.LabelName ASC
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        -- Return error as JSON
        SELECT
            0 AS Success,
            ERROR_MESSAGE() AS Message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

PRINT 'Labels Stored Procedures created successfully!'
GO

