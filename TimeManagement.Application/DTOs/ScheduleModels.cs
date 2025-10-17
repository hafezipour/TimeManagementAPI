using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs
{
    /// <summary>
    /// Schedule frequency model representing days and day types
    /// </summary>
    public class ScheduleFrequency
    {
        public int Day { get; set; }
        public int? DayType { get; set; }
    }

    /// <summary>
    /// Schedule model for shift schedules
    /// </summary>
    public class Schedule
    {
        public int? Id { get; set; }
        public int ShiftId { get; set; }
        public DateTime StartFrom { get; set; }
        public bool ScheduleWithoutTimes { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int ScheduleType { get; set; }  // 1=Daily, 2=Weekly, 3=Monthly, 4=DoesNotRepeat, 5=DaysOnOff
        public int RepeatEvery { get; set; }
        public List<ScheduleFrequency>? Frequency { get; set; }
        public int EndType { get; set; }  // 1=Never, 2=OnDate, 3=AfterOccurrences
        public DateTime? ValidUntil { get; set; }
        public int? MaxOccurrences { get; set; }
        public bool IsActive { get; set; }
    }


}
