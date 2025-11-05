-- =============================================
-- Author:		TimeManagement API
-- Create date: 11/04/2025
-- Description:	Updates to Shift stored procedures to support Job Code assignments
-- =============================================

USE [TimeManagement_DEV]
GO

-- =============================================
-- 1. UPDATE usp_Shifts_GetById - Add JobCodes array
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Shifts_GetById')
    DROP PROCEDURE [dbo].[usp_Shifts_GetById]
GO

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

-- =============================================
-- 2. UPDATE usp_Shifts_Save - Add JobCodeIds parameter and handling
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Shifts_Save')
    DROP PROCEDURE [dbo].[usp_Shifts_Save]
GO

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

PRINT 'Shift Job Code assignment support added successfully!'
GO

