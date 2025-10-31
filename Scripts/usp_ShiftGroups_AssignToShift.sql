USE [TimeManagementService]
GO

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
			AND EXISTS (SELECT 1 FROM ShiftGroups WHERE Id = CAST(value AS int) AND TenantId = @TenantId)

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

