using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Schedules
{
    public class GetScheduleRequest
    {
        public string SourceId { get; set; }
        public int SourceType { get; set; }
    }
}
