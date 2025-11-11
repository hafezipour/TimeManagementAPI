using System;

namespace TimeManagement.Application.DTOs.Schedules
{
    public class AvailabilityDto
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public DateTime? StartFrom { get; set; }

        public TimeSpan? StartTime { get; set; }

        public TimeSpan? EndTime { get; set; }

        public DateTimeOffset? ValidUntil { get; set; }
    }
}
