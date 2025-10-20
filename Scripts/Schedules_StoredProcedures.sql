USE [TimeManagement_DEV]
GO

-- =============================================
-- Author:		TimeManagement API
-- Create date: 10/20/2025
-- Description:	Get Schedule by Source ID and Source Type with Frequencies
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Schedules_GetBySource]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_Schedules_GetBySource]
GO

CREATE PROCEDURE [dbo].[usp_Schedules_GetBySource]
	@SourceId int,
	@SourceType int,
	@TenantId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		s.Id as id,
		s.SourceType as sourceType,
		s.SourceId as sourceId,
		s.StartFrom as startFrom,
		s.ScheduleWithoutTimes as scheduleWithoutTimes,
		s.StartTime as startTime,
		s.EndTime as endTime,
		s.ScheduleType as scheduleType,
		s.RepeatEvery as repeatEvery,
		s.EndType as endType,
		s.ValidUntil as validUntil,
		s.MaxOccurrences as maxOccurrences,
		s.IsActive as isActive,
		s.Createdby as createdBy,
		s.UpdatedBy as updatedBy,
		s.DateCreated as dateCreated,
		s.DateUpdated as dateUpdated,
		-- Get Frequency array
		(
			SELECT 
				sf.Day as day,
				sf.DayType as dayType
			FROM ScheduleFrequencies sf
			WHERE sf.ScheduleId = s.Id
				AND sf.TenantId = @TenantId
				AND ISNULL(sf.IsActive, 1) = 1
			FOR JSON PATH
		) as frequency
	FROM Schedules s
	WHERE s.SourceType = @SourceType
		AND s.SourceId = @SourceId
		AND s.TenantId = @TenantId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
END
GO

