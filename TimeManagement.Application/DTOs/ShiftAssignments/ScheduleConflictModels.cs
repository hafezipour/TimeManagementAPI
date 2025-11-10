using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement
{
    public class ScheduleConflictDetail
    {
        public int UserId { get; set; }
        public int? ExistingAssignmentId { get; set; }
        public int? ExistingScheduleId { get; set; }
        public int? RequestedScheduleId { get; set; }
        public DateTime Date { get; set; }
        public string? ExistingShiftName { get; set; }
        public TimeWindow ExistingWindow { get; set; } = new TimeWindow();
        public TimeWindow RequestedWindow { get; set; } = new TimeWindow();
        public string? Reason { get; set; }
    }

    public class OccurrencePair
    {
        public Occurrence NewOccurrence { get; set; } = new Occurrence();
        public Occurrence ExistingOccurrence { get; set; } = new Occurrence();
    }

    public class Occurrence
    {
        public DateTime Date { get; set; }
        public DateTime Start { get; set; }
        public DateTime End { get; set; }
        public bool IsAllDay { get; set; }
    }

    public class TimeWindow
    {
        public DateTime? Start { get; set; }
        public DateTime? End { get; set; }
        public bool IsAllDay { get; set; }
    }

}
