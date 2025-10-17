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

}
