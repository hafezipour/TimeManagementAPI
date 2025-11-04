-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Update shift slot positions (increase/decrease minimumPositions)
-- =============================================

USE [TimeManagement_DEV]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Shifts_UpdateSlotPositions')
    DROP PROCEDURE [dbo].[usp_Shifts_UpdateSlotPositions]
GO

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

PRINT 'usp_Shifts_UpdateSlotPositions created successfully!'
GO

