using System;
using System.Collections.Generic;

namespace TimeManagement.Application.DTOs.Schedules
{
    /// <summary>
    /// Response model for schedule data from usp_Schedules_GetBySource
    /// </summary>
    public class ScheduleResponse
    {
        public int Id { get; set; }

        public int SourceType { get; set; }

        public int SourceId { get; set; }

        public DateTime? StartFrom { get; set; }

        public bool? ScheduleWithoutTimes { get; set; }

        public TimeSpan? StartTime { get; set; }

        public TimeSpan? EndTime { get; set; }

        public int? ScheduleType { get; set; }

        public int? RepeatEvery { get; set; }

        public string EndType { get; set; }

        public DateTimeOffset? ValidUntil { get; set; }

        public int? MaxOccurrences { get; set; }

        public int CreatedBy { get; set; }

        public int? UpdatedBy { get; set; }

        public DateTimeOffset DateCreated { get; set; }

        public DateTimeOffset? DateUpdated { get; set; }

        public List<ScheduleFrequencyResponse> Frequency { get; set; }
    }
}

