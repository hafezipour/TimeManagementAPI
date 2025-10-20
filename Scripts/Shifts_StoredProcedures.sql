USE [TimeManagement_DEV]
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Get Shifts with server-side paging and filtering
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_Get]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_Get]
GO

CREATE PROCEDURE [dbo].[usp_Shifts_Get]
	@ShiftId int = NULL,
	@TenantId int,
	@PageNumber int = 1,
	@PageSize int = 10,
	@SortColumn varchar(50) = 'DisplayOrder',
	@SortDirection varchar(4) = 'ASC',
	@SearchTerm varchar(255) = NULL,
	@StatusCustomTableValueId int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset int = (@PageNumber - 1) * @PageSize

	-- Total count query
	DECLARE @TotalCount int
	
	SELECT @TotalCount = COUNT(*)
	FROM Shifts s
	WHERE s.TenantId = @TenantId
		AND (@ShiftId IS NULL OR s.Id = @ShiftId)
		AND (@SearchTerm IS NULL OR 
			s.ShiftName LIKE '%' + @SearchTerm + '%' OR 
			s.ShiftCode LIKE '%' + @SearchTerm + '%')
		AND (@StatusCustomTableValueId IS NULL OR 
			(@StatusCustomTableValueId = 1 AND ISNULL(s.IsActive, 1) = 1) OR
			(@StatusCustomTableValueId = 0 AND ISNULL(s.IsActive, 1) = 0))

	-- Main query with pagination
	SELECT 
		s.Id as id,
		s.ShiftName as shiftName,
		s.ShiftCode as shiftCode,
		s.IsNoAssignmentTime as isNoAssignmentTime,
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
		s.WorkCodeIds as workCodeIds,
		s.AdminIds as adminIds,
		sch.StartFrom as scheduleStartFrom,
		sch.StartTime as scheduleStartTime,
		@TotalCount as totalCount,
		@PageNumber as pageNumber,
		@PageSize as pageSize,
		CEILING(CAST(@TotalCount AS float) / @PageSize) as totalPages
	FROM Shifts s
	LEFT JOIN Schedules sch ON s.Id = sch.SourceId AND sch.SourceType = 1 AND sch.TenantId = @TenantId AND ISNULL(sch.IsActive, 1) = 1
	WHERE s.TenantId = @TenantId
		AND (@ShiftId IS NULL OR s.Id = @ShiftId)
		AND (@SearchTerm IS NULL OR 
			s.ShiftName LIKE '%' + @SearchTerm + '%' OR 
			s.ShiftCode LIKE '%' + @SearchTerm + '%')
		AND (@StatusCustomTableValueId IS NULL OR 
			(@StatusCustomTableValueId = 1 AND ISNULL(s.IsActive, 1) = 1) OR
			(@StatusCustomTableValueId = 0 AND ISNULL(s.IsActive, 1) = 0))
	ORDER BY 
		CASE WHEN @SortDirection = 'ASC' THEN
			CASE @SortColumn
				WHEN 'ShiftName' THEN s.ShiftName
				WHEN 'ShiftCode' THEN s.ShiftCode
				WHEN 'Location' THEN s.Location
			END
		END ASC,
		CASE WHEN @SortDirection = 'DESC' THEN
			CASE @SortColumn
				WHEN 'ShiftName' THEN s.ShiftName
				WHEN 'ShiftCode' THEN s.ShiftCode
				WHEN 'Location' THEN s.Location
			END
		END DESC,
		CASE WHEN @SortDirection = 'ASC' THEN
			CASE @SortColumn
				WHEN 'DisplayOrder' THEN s.DisplayOrder
				WHEN 'MinimumPositions' THEN s.MinimumPositions
			END
		END ASC,
		CASE WHEN @SortDirection = 'DESC' THEN
			CASE @SortColumn
				WHEN 'DisplayOrder' THEN s.DisplayOrder
				WHEN 'MinimumPositions' THEN s.MinimumPositions
			END
		END DESC,
		s.DisplayOrder ASC, s.ShiftName ASC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Get a single Shift by ID
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_GetById]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_GetById]
GO

CREATE PROCEDURE [dbo].[usp_Shifts_GetById]
	@ShiftId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		s.Id as id,
		s.ShiftName as shiftName,
		s.ShiftCode as shiftCode,
		s.IsNoAssignmentTime as isNoAssignmentTime,
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
		s.WorkCodeIds as workCodeIds,
		s.AdminIds as adminIds
	FROM Shifts s
	WHERE s.Id = @ShiftId AND s.TenantId = @TenantId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
END
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Save (Insert/Update) Shift
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_Save]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_Save]
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
		DECLARE @IsNoAssignmentTime bit
		DECLARE @MinimumPositions int
		DECLARE @MaxTimeOffs int
		DECLARE @Location varchar(255)
		DECLARE @IsWorkShift bit
		DECLARE @IsSelfSchedulingEnabled bit
		DECLARE @IsSelfSchedulingRequiresAdminApprovals bit
		DECLARE @IsHideOpenSlots bit
		DECLARE @ShiftLabelId int
		DECLARE @BackgroundColour varchar(7)
		DECLARE @IsActive bit
		DECLARE @DisplayOrder int
		DECLARE @WorkCodeIds varchar(max)
		DECLARE @AdminIds varchar(max)

		-- Parse JSON
		SELECT 
			@Id = id,
			@ShiftName = shiftName,
			@ShiftCode = shiftCode,
			@IsNoAssignmentTime = ISNULL(isNoAssignmentTime, 0),
			@MinimumPositions = minimumPositions,
			@MaxTimeOffs = maxTimeOffs,
			@Location = location,
			@IsWorkShift = ISNULL(isWorkShift, 1),
			@IsSelfSchedulingEnabled = ISNULL(isSelfSchedulingEnabled, 0),
			@IsSelfSchedulingRequiresAdminApprovals = ISNULL(isSelfSchedulingRequiresAdminApprovals, 0),
			@IsHideOpenSlots = ISNULL(isHideOpenSlots, 0),
			@ShiftLabelId = shiftLabelId,
			@BackgroundColour = backgroundColour,
			@IsActive = ISNULL(isActive, 1),
			@DisplayOrder = displayOrder,
			@WorkCodeIds = workCodeIds,
			@AdminIds = adminIds
		FROM OPENJSON(@Json) WITH (
			id int,
			shiftName varchar(255),
			shiftCode varchar(55),
			isNoAssignmentTime bit,
			minimumPositions int,
			maxTimeOffs int,
			location varchar(255),
			isWorkShift bit,
			isSelfSchedulingEnabled bit,
			isSelfSchedulingRequiresAdminApprovals bit,
			isHideOpenSlots bit,
			shiftLabelId int,
			backgroundColour varchar(7),
			isActive bit,
			displayOrder int,
			workCodeIds varchar(max),
			adminIds varchar(max)
		)

		-- Check if Shift Code already exists for another record
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
				IsNoAssignmentTime = @IsNoAssignmentTime,
				MinimumPositions = @MinimumPositions,
				MaxTimeOffs = @MaxTimeOffs,
				Location = @Location,
				IsWorkShift = @IsWorkShift,
				IsSelfSchedulingEnabled = @IsSelfSchedulingEnabled,
				IsSelfSchedulingRequiresAdminApprovals = @IsSelfSchedulingRequiresAdminApprovals,
				IsHideOpenSlots = @IsHideOpenSlots,
				ShiftLabelId = @ShiftLabelId,
				BackgroundColour = @BackgroundColour,
				IsActive = @IsActive,
				DisplayOrder = @DisplayOrder,
				WorkCodeIds = @WorkCodeIds,
				AdminIds = @AdminIds,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

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
				IsNoAssignmentTime,
				MinimumPositions,
				MaxTimeOffs,
				Location,
				IsWorkShift,
				IsSelfSchedulingEnabled,
				IsSelfSchedulingRequiresAdminApprovals,
				IsHideOpenSlots,
				ShiftLabelId,
				BackgroundColour,
				IsActive,
				DisplayOrder,
				WorkCodeIds,
				AdminIds,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@ShiftName,
				@ShiftCode,
				@IsNoAssignmentTime,
				@MinimumPositions,
				@MaxTimeOffs,
				@Location,
				@IsWorkShift,
				@IsSelfSchedulingEnabled,
				@IsSelfSchedulingRequiresAdminApprovals,
				@IsHideOpenSlots,
				@ShiftLabelId,
				@BackgroundColour,
				@IsActive,
				@DisplayOrder,
				@WorkCodeIds,
				@AdminIds,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()

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

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Delete Shift
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_Delete]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_Delete]
GO

CREATE PROCEDURE [dbo].[usp_Shifts_Delete]
	@ShiftId int,
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

		-- Delete related schedules first (if they exist)
		DELETE FROM Schedules 
		WHERE SourceType = 1 -- Assuming 1 is for Shifts
			AND SourceId = @ShiftId 
			AND TenantId = @TenantId

		-- Delete the Shift
		DELETE FROM Shifts 
		WHERE Id = @ShiftId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Shift deleted successfully' as message,
			@ShiftId as deletedId
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

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Get Shifts Short List for dropdowns/lookups
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_GetShortList]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_GetShortList]
GO

CREATE PROCEDURE [dbo].[usp_Shifts_GetShortList]
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		s.Id as id,
		s.ShiftName as shiftName,
		s.ShiftCode as shiftCode,
		s.BackgroundColour as backgroundColour,
		s.IsActive as isActive
	FROM Shifts s
	WHERE s.TenantId = @TenantId
		AND ISNULL(s.IsActive, 1) = 1
	ORDER BY s.DisplayOrder ASC, s.ShiftName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Close Shift (Set StatusCustomTableValueId = 2)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Shifts_Close]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Shifts_Close]
GO

CREATE PROCEDURE [dbo].[usp_Shifts_Close]
	@ShiftId int,
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

		-- Update the Shift to set StatusCustomTableValueId = 2 (Closed)
		-- Note: Assuming there's a StatusCustomTableValueId column in the Shifts table
		-- If not, you may need to add this column or use a different approach
		UPDATE Shifts 
		SET 
			StatusCustomTableValueId = 2, -- 2 = Closed
			UpdatedBy = @UserId,
			DateUpdated = GETUTCDATE()
		WHERE Id = @ShiftId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Shift closed successfully' as message,
			@ShiftId as closedId
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


