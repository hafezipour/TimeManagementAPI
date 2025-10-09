-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Get Holidays
-- =============================================
CREATE PROCEDURE [dbo].[usp_Holidays_Get]
	@HolidayId int = NULL,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		h.Id,
		h.TenantId,
		h.HolidayCode as holidayCode,
		h.HolidayName as holidayName,
		h.HolidayDate as holidayDate,
		h.IsObserved as isObserved,
		h.IsFloating as isFloating,
		h.IsAppliesToAll as isAppliesToAll,
		h.CreatedBy as createdBy,
		h.UpdatedBy as updatedBy,
		h.DateCreated as dateCreated,
		h.DateUpdated as dateUpdated
	FROM Holidays h
	WHERE h.TenantId = @TenantId
		AND (@HolidayId IS NULL OR h.Id = @HolidayId)
	ORDER BY h.HolidayDate
	FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

/****** Object:  StoredProcedure [dbo].[usp_Holidays_Save] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Save (Insert/Update) Holiday
-- =============================================
CREATE PROCEDURE [dbo].[usp_Holidays_Save]
	@Json varchar(max),
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		DECLARE @Id int
		DECLARE @HolidayCode varchar(50)
		DECLARE @HolidayName varchar(255)
		DECLARE @HolidayDate datetimeoffset(7)
		DECLARE @IsObserved bit
		DECLARE @IsFloating bit
		DECLARE @IsAppliesToAll bit

		-- Parse JSON
		SELECT 
			@Id = Id,
			@HolidayCode = holidayCode,
			@HolidayName = holidayName,
			@HolidayDate = holidayDate,
			@IsObserved = ISNULL(isObserved, 0),
			@IsFloating = ISNULL(isFloating, 0),
			@IsAppliesToAll = ISNULL(isAppliesToAll, 0)
		FROM OPENJSON(@Json) WITH (
			Id int,
			holidayCode varchar(50),
			holidayName varchar(255),
			holidayDate datetimeoffset(7),
			isObserved bit,
			isFloating bit,
			isAppliesToAll bit
		)


		-- Check if HolidayCode already exists for another holiday
		IF EXISTS (
			SELECT 1 FROM Holidays 
			WHERE HolidayCode = @HolidayCode 
				AND TenantId = @TenantId 
				AND Id != ISNULL(@Id, 0)
		)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Holiday Code already exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Holiday exists
		IF EXISTS (SELECT 1 FROM Holidays WHERE Id = @Id AND TenantId = @TenantId)
		BEGIN
			-- Update existing Holiday
			UPDATE Holidays
			SET 
				HolidayCode = @HolidayCode,
				HolidayName = @HolidayName,
				HolidayDate = @HolidayDate,
				IsObserved = @IsObserved,
				IsFloating = @IsFloating,
				IsAppliesToAll = @IsAppliesToAll,
				UpdatedBy = @UserId,
				DateUpdated = GETUTCDATE()
			WHERE Id = @Id AND TenantId = @TenantId

			SELECT @Id as id, CAST(1 AS bit) as success, 'Holiday updated successfully' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
		ELSE
		BEGIN
			-- Insert new Holiday
			INSERT INTO Holidays (
				TenantId,
				HolidayCode,
				HolidayName,
				HolidayDate,
				IsObserved,
				IsFloating,
				IsAppliesToAll,
				CreatedBy,
				DateCreated
			)
			VALUES (
				@TenantId,
				@HolidayCode,
				@HolidayName,
				@HolidayDate,
				@IsObserved,
				@IsFloating,
				@IsAppliesToAll,
				@UserId,
				GETUTCDATE()
			)

			SET @Id = SCOPE_IDENTITY()

			SELECT @Id as id, CAST(1 AS bit) as success, 'Holiday created successfully' as message
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

/****** Object:  StoredProcedure [dbo].[usp_Holidays_Delete] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/9/2025
-- Description:	Delete Holiday
-- =============================================
CREATE PROCEDURE [dbo].[usp_Holidays_Delete]
	@HolidayId int,
	@UserId int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN

		-- Check if Holiday exists
		IF NOT EXISTS (SELECT 1 FROM Holidays WHERE Id = @HolidayId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Holiday not found' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Check if Holiday has assignments
		IF EXISTS (SELECT 1 FROM HolidayAssignment WHERE HolidayId = @HolidayId AND TenantId = @TenantId)
		BEGIN
			SELECT 
				CAST(0 AS bit) as success,
				'Cannot delete as Holiday Assignment exists' as message
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			ROLLBACK TRAN
			RETURN
		END

		-- Delete the Holiday
		DELETE FROM Holidays 
		WHERE Id = @HolidayId AND TenantId = @TenantId

		SELECT 
			CAST(1 AS bit) as success,
			'Holiday deleted successfully' as message,
			@HolidayId as deletedId
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

