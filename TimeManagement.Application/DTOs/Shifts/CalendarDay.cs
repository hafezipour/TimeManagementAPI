using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TimeManagement.Domain.Models;

namespace TimeManagement.Application.DTOs.Shifts
{
    public class CalendarDay
    {
        public int DayNo { get; set; }
        public int MonthNo { get; set; }
        public List<SchedulingShift> SchedulingShifts { get; set; }
    }
}
