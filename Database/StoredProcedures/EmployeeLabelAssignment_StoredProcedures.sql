-- =============================================
-- Employee Label Assignment Module - Stored Procedures
-- Author: TimeManagement API
-- Create date: 11-04-2025
-- Description: All stored procedures for Employee Label Assignment management
-- =============================================

USE [TimeManagement_DEV]
GO

/*---------------------=========================================================================================================
CREATED BY			: TimeManagement API
CREATED DATE 		: 11/04/2025
DESCRIPTION			: Get Employee Label Assignments with server-side paging
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeLabelAssignment_Get')
    DROP PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Get]
GO

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
			u.FirstName + ' ' + u.LastName as userName,
			u.Email as userEmail,
			ela.EffectiveDate as effectiveDate,
			ela.ExpiryDate as expiryDate,
			ela.CreatedBy as createdBy,
			ela.UpdatedBy as updatedBy,
			ela.DateCreated as dateCreated,
			ela.DateUpdated as dateUpdated
		FROM EmployeeLabelAssignment ela
		INNER JOIN Labels l ON ela.LabelId = l.Id
		INNER JOIN Users u ON ela.UserId = u.Id
		WHERE ela.TenantId = @TenantId
			AND ela.IsDeleted = 0
			AND (@Id IS NULL OR ela.Id = @Id)
			AND (
				@SearchTerm IS NULL OR 
				l.LabelName LIKE '%' + @SearchTerm + '%' OR 
				l.LabelCode LIKE '%' + @SearchTerm + '%' OR
				u.FirstName LIKE '%' + @SearchTerm + '%' OR
				u.LastName LIKE '%' + @SearchTerm + '%' OR
				u.Email LIKE '%' + @SearchTerm + '%'
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
		_rows.userName,
		_rows.userEmail,
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
		CASE WHEN @SortColumn = 'UserName' AND @SortDirection = 'ASC' THEN _rows.userName END ASC,
		CASE WHEN @SortColumn = 'UserName' AND @SortDirection = 'DESC' THEN _rows.userName END DESC,
		_rows.dateCreated DESC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

-- =============================================
-- 2. usp_EmployeeLabelAssignment_Save - Save (Insert/Update) Employee Label Assignment
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeLabelAssignment_Save')
    DROP PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Save]
GO

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
            Id INT,
            LabelId INT,
            UserId INT,
            EffectiveDate DATETIMEOFFSET,
            ExpiryDate DATETIMEOFFSET
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

        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Id = @EmployeeUserId AND TenantID = @TenantId)
        BEGIN
            SELECT
                CAST(0 AS BIT) AS success,
                'Employee not found.' AS message
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
                AND (@Id IS NULL OR Id != @Id)
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

-- =============================================
-- 3. usp_EmployeeLabelAssignment_Delete - Soft Delete Employee Label Assignment
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EmployeeLabelAssignment_Delete')
    DROP PROCEDURE [dbo].[usp_EmployeeLabelAssignment_Delete]
GO

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

PRINT 'Employee Label Assignment Stored Procedures created successfully!'
GO

