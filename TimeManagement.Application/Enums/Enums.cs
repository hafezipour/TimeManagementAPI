using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.Enums
{
    public enum ScheduleSourceTypes
    {
        Shift = 1,
        StaffAvailability = 2,
        ShiftAssignment = 3
    }

    /// <summary>
    /// Types of schedule recurrence patterns
    /// </summary>
    public enum ScheduleType
    {
        Daily = 1,
        Weekly = 2,
        Monthly = 3,
        DoesNotRepeat = 4,
        DaysOnOff = 5
    }

    /// <summary>
    /// Schedule end type options
    /// </summary>
    public enum EndType
    {
        Never = 1,
        OnDate = 2,
        AfterOccurrences = 3
    }

    /// <summary>
    /// Day type for DaysOnOff schedules
    /// </summary>
    public enum DayType
    {
        Off = 0,
        On = 1
    }
}
