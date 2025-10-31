USE [TimeManagementService]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/31/2025
DESCRIPTION			: Delete Shift Group by ID
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ShiftGroups_Delete]
	@GroupId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Group exists
		IF NOT EXISTS (SELECT 1 FROM ShiftGroups WHERE Id = @GroupId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Group not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Group is assigned to any shifts
		IF EXISTS (SELECT 1 FROM ShiftGroupAssignment WHERE GroupId = @GroupId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Cannot delete group. It is assigned to one or more shifts' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the Group
		DELETE FROM ShiftGroups
		WHERE Id = @GroupId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Group deleted successfully' as message,
			@GroupId as deletedId
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


