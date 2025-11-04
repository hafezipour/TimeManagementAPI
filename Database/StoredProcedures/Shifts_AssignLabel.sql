-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Assign label to shift (Update ShiftLabelId in Shifts table)
-- =============================================

USE [TimeManagement_DEV]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Shifts_AssignLabel')
    DROP PROCEDURE [dbo].[usp_Shifts_AssignLabel]
GO

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

PRINT 'usp_Shifts_AssignLabel created successfully!'
GO

