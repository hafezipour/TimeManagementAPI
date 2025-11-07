using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Schedules
{
    /// <summary>
    /// Schedule model for shift schedules
    /// </summary>
    public class ScheduleRequest
    {
        public int? Id { get; set; }
        public int ShiftId { get; set; }
        public int? SourceType { get; set; }
        public int? SourceId { get; set; }
        public DateTime StartFrom { get; set; }
        public bool ScheduleWithoutTimes { get; set; }
        public string? StartTime { get; set; }
        public string? EndTime { get; set; }
        public int ScheduleType { get; set; }  // 1=Daily, 2=Weekly, 3=Monthly, 4=DoesNotRepeat, 5=DaysOnOff
        public int RepeatEvery { get; set; }
        public List<ScheduleFrequencyRequest>? Frequency { get; set; }
        public int EndType { get; set; }  // 1=Never, 2=OnDate, 3=AfterOccurrences
        public DateTime? ValidUntil { get; set; }
        public int? MaxOccurrences { get; set; }
        public bool IsActive { get; set; }
    }
}
