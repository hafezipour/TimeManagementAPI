USE [TimeManagement_DEV]
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Save (Insert/Update) Group with validation
LAST UPDATED BY 	: Ali Nafees
DATE LAST UPDATED 	: 11/03/2025
---------------------=========================================================================================================*/

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Groups_Save')
    DROP PROCEDURE [dbo].[usp_Groups_Save]
GO

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
				AND (@Id IS NULL OR Id != @Id)
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

PRINT 'usp_Groups_Save stored procedure created successfully!'
GO

