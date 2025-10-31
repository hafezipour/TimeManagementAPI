USE [TimeManagementService]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Save (Insert/Update) Shift Group
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ShiftGroups_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @GroupName varchar(255)
		DECLARE @GroupTypeCustomTableValueId int
		DECLARE @Description nvarchar(max)
		DECLARE @ColorCode varchar(7)
		DECLARE @IsActive bit

		-- Parse JSON
		SELECT 
			@Id = id,
			@GroupName = groupName,
			@GroupTypeCustomTableValueId = groupTypeCustomTableValueId,
			@Description = description,
			@ColorCode = colorCode,
			@IsActive = ISNULL(isActive, 1)
		FROM OPENJSON(@Json) WITH (
			id int,
			groupName varchar(255),
			groupTypeCustomTableValueId int,
			description nvarchar(max),
			colorCode varchar(7),
			isActive bit
		)

		-- Check if GroupName already exists for another group
		IF EXISTS (
			SELECT 1 FROM ShiftGroups 
			WHERE GroupName = @GroupName 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Group Name already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Group exists
		IF EXISTS (SELECT 1 FROM ShiftGroups WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Group
			UPDATE ShiftGroups
			SET 
				GroupName = @GroupName,
				GroupTypeCustomTableValueId = @GroupTypeCustomTableValueId,
				Description = @Description,
				ColorCode = @ColorCode,
				IsActive = @IsActive,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			SELECT @Id as id, CAST(1 AS bit) as success, 'Group updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new Group
			INSERT INTO ShiftGroups (
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
			)

			SET @Id = SCOPE_IDENTITY()

			SELECT @Id as id, CAST(1 AS bit) as success, 'Group created successfully' as message
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


