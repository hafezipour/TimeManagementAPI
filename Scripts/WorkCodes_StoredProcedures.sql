USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Delete]    Script Date: 10/15/2025 5:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Delete WorkCode
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkCodes_Delete]
	@WorkCodeId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if WorkCode exists
		IF NOT EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @WorkCodeId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the WorkCode
		DELETE FROM WorkCodes 
		WHERE Id = @WorkCodeId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'WorkCode deleted successfully' as message,
			@WorkCodeId as deletedId
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
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Get]    Script Date: 10/15/2025 5:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Get WorkCodes
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkCodes_Get]
	@WorkCodeId int = NULL,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		w.Id as id,
		w.WorkCode as workCode,
		w.WorkCodeName as workCodeName,
		w.Description as description,
		w.Category as category,
		w.ColorCode as colorCode,
		w.TextColor as textColor,
		w.PayMultiplier as payMultiplier,
		w.PayRate as payRate,
		w.IsDefault as isDefault,
		w.DisplayOrder as displayOrder,
		w.IsCountsTowardWeeklyLimit as isCountsTowardWeeklyLimit,
		w.IsCountsTowardMonthlyLimit as isCountsTowardMonthlyLimit,
		w.IsIncludeInCallbackRankings as isIncludeInCallbackRankings,
		w.IsExcludesFromCallbacks as isExcludesFromCallbacks,
		w.IsTradeable as isTradeable,
		w.MinTimeBufferHours as minTimeBufferHours,
		w.MaxTimeBufferHours as maxTimeBufferHours,
		w.ExclusionRuleHours as exclusionRuleHours,
		w.LimitPerEmployeePerYear as limitPerEmployeePerYear,
		w.IsRequestable as isRequestable,
		w.IsMasked as isMasked,
		w.IsActive as isActive,
		w.CreatedBy as createdBy,
		w.UpdatedBy as updatedBy,
		w.DateCreated as dateCreated,
		w.DateUpdated as dateUpdated
	FROM WorkCodes w
	WHERE w.TenantId = @TenantId
		AND (@WorkCodeId IS NULL OR w.Id = @WorkCodeId)
	ORDER BY w.DisplayOrder, w.WorkCodeName
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_GetShortList]    Script Date: 10/15/2025 5:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*---------------------------------------------------------------------============================================================
CREATED BY			: TimeManagement API
CREATED DATE		: 10/15/2025
DESCRIPTION			: Get short list of WorkCodes for dropdowns/lookups
LAST UPDATED BY		:
DATE LAST UPDATED	:
EXEC [usp_WorkCodes_GetShortList] 1
---------------------------------------------------------------------============================================================+*/
CREATE   PROCEDURE [dbo].[usp_WorkCodes_GetShortList]
(
	@TenantId int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		w.Id as id,
		w.WorkCode as workCode,
		w.WorkCodeName as workCodeName,
		w.ColorCode as colorCode,
		w.TextColor as textColor,
		w.IsActive as isActive
	FROM WorkCodes w
	WHERE w.TenantId = @TenantId
		AND ISNULL(w.IsActive, 1) = 1
	ORDER BY w.DisplayOrder ASC, w.WorkCodeName ASC
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkCodes_Save]    Script Date: 10/15/2025 5:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/15/2025
-- Description:	Save (Insert/Update) WorkCode
-- =============================================
CREATE   PROCEDURE [dbo].[usp_WorkCodes_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @WorkCode varchar(55)
		DECLARE @WorkCodeName varchar(255)
		DECLARE @Description nvarchar(max)
		DECLARE @Category varchar(55)
		DECLARE @ColorCode varchar(7)
		DECLARE @TextColor varchar(7)
		DECLARE @PayMultiplier decimal(10, 2)
		DECLARE @PayRate decimal(10, 2)
		DECLARE @IsDefault bit
		DECLARE @DisplayOrder int
		DECLARE @IsCountsTowardWeeklyLimit bit
		DECLARE @IsCountsTowardMonthlyLimit bit
		DECLARE @IsIncludeInCallbackRankings bit
		DECLARE @IsExcludesFromCallbacks bit
		DECLARE @IsTradeable bit
		DECLARE @MinTimeBufferHours decimal(5, 2)
		DECLARE @MaxTimeBufferHours decimal(5, 2)
		DECLARE @ExclusionRuleHours decimal(5, 2)
		DECLARE @LimitPerEmployeePerYear int
		DECLARE @IsRequestable bit
		DECLARE @IsMasked bit
		DECLARE @IsActive bit

		-- Parse JSON
		SELECT 
			@Id = id,
			@WorkCode = workCode,
			@WorkCodeName = workCodeName,
			@Description = description,
			@Category = category,
			@ColorCode = colorCode,
			@TextColor = textColor,
			@PayMultiplier = payMultiplier,
			@PayRate = payRate,
			@IsDefault = ISNULL(isDefault, 0),
			@DisplayOrder = displayOrder,
			@IsCountsTowardWeeklyLimit = ISNULL(isCountsTowardWeeklyLimit, 0),
			@IsCountsTowardMonthlyLimit = ISNULL(isCountsTowardMonthlyLimit, 0),
			@IsIncludeInCallbackRankings = ISNULL(isIncludeInCallbackRankings, 0),
			@IsExcludesFromCallbacks = ISNULL(isExcludesFromCallbacks, 0),
			@IsTradeable = ISNULL(isTradeable, 0),
			@MinTimeBufferHours = minTimeBufferHours,
			@MaxTimeBufferHours = maxTimeBufferHours,
			@ExclusionRuleHours = exclusionRuleHours,
			@LimitPerEmployeePerYear = limitPerEmployeePerYear,
			@IsRequestable = ISNULL(isRequestable, 0),
			@IsMasked = ISNULL(isMasked, 0),
			@IsActive = ISNULL(isActive, 1)
		FROM OPENJSON(@Json) WITH (
			id int,
			workCode varchar(55),
			workCodeName varchar(255),
			description nvarchar(max),
			category varchar(55),
			colorCode varchar(7),
			textColor varchar(7),
			payMultiplier decimal(10, 2),
			payRate decimal(10, 2),
			isDefault bit,
			displayOrder int,
			isCountsTowardWeeklyLimit bit,
			isCountsTowardMonthlyLimit bit,
			isIncludeInCallbackRankings bit,
			isExcludesFromCallbacks bit,
			isTradeable bit,
			minTimeBufferHours decimal(5, 2),
			maxTimeBufferHours decimal(5, 2),
			exclusionRuleHours decimal(5, 2),
			limitPerEmployeePerYear int,
			isRequestable bit,
			isMasked bit,
			isActive bit
		)

		-- Check if WorkCode already exists for another record
		IF EXISTS (
			SELECT 1 FROM WorkCodes 
			WHERE WorkCode = @WorkCode 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'WorkCode already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if WorkCode exists
		IF EXISTS (SELECT 1 FROM WorkCodes WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing WorkCode
			UPDATE WorkCodes
			SET 
				WorkCode = @WorkCode,
				WorkCodeName = @WorkCodeName,
				Description = @Description,
				Category = @Category,
				ColorCode = @ColorCode,
				TextColor = @TextColor,
				PayMultiplier = @PayMultiplier,
				PayRate = @PayRate,
				IsDefault = @IsDefault,
				DisplayOrder = @DisplayOrder,
				IsCountsTowardWeeklyLimit = @IsCountsTowardWeeklyLimit,
				IsCountsTowardMonthlyLimit = @IsCountsTowardMonthlyLimit,
				IsIncludeInCallbackRankings = @IsIncludeInCallbackRankings,
				IsExcludesFromCallbacks = @IsExcludesFromCallbacks,
				IsTradeable = @IsTradeable,
				MinTimeBufferHours = @MinTimeBufferHours,
				MaxTimeBufferHours = @MaxTimeBufferHours,
				ExclusionRuleHours = @ExclusionRuleHours,
				LimitPerEmployeePerYear = @LimitPerEmployeePerYear,
				IsRequestable = @IsRequestable,
				IsMasked = @IsMasked,
				IsActive = @IsActive,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			SELECT @Id as id, CAST(1 AS bit) as success, 'WorkCode updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new WorkCode
			INSERT INTO WorkCodes (
				TenantId,
				WorkCode,
				WorkCodeName,
				Description,
				Category,
				ColorCode,
				TextColor,
				PayMultiplier,
				PayRate,
				IsDefault,
				DisplayOrder,
				IsCountsTowardWeeklyLimit,
				IsCountsTowardMonthlyLimit,
				IsIncludeInCallbackRankings,
				IsExcludesFromCallbacks,
				IsTradeable,
				MinTimeBufferHours,
				MaxTimeBufferHours,
				ExclusionRuleHours,
				LimitPerEmployeePerYear,
				IsRequestable,
				IsMasked,
				IsActive,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@WorkCode,
				@WorkCodeName,
				@Description,
				@Category,
				@ColorCode,
				@TextColor,
				@PayMultiplier,
				@PayRate,
				@IsDefault,
				@DisplayOrder,
				@IsCountsTowardWeeklyLimit,
				@IsCountsTowardMonthlyLimit,
				@IsIncludeInCallbackRankings,
				@IsExcludesFromCallbacks,
				@IsTradeable,
				@MinTimeBufferHours,
				@MaxTimeBufferHours,
				@ExclusionRuleHours,
				@LimitPerEmployeePerYear,
				@IsRequestable,
				@IsMasked,
				@IsActive,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()

			SELECT @Id as id, CAST(1 AS bit) as success, 'WorkCode created successfully' as message
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

