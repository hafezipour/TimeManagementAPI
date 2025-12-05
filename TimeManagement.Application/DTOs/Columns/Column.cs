using System;
using System.Collections.Generic;
using TimeManagement.Application.DTOs.Columns;
using TimeManagement.Application.DTOs.Shifts;
using TimeManagement.Application.DTOs.TimeOffRequests;

namespace TimeManagement.Domain.Models
{
    /// <summary>
    /// Represents a Column with its grid layout and shift assignments
    /// </summary>
    public class Column
    {
        public int Id { get; set; }

        public string ColumnName { get; set; }

        public string BackgroundColor { get; set; }

        public int CreatedBy { get; set; }

        public int? UpdatedBy { get; set; }

        public DateTimeOffset DateCreated { get; set; }

        public DateTimeOffset? DateUpdated { get; set; }

        public bool? IsSystem { get; set; }

        public List<GridColumn> GridColumns { get; set; }

        public List<ColumnShift> ColumnShifts { get; set; }
        public List<SchedulingShift> SchedulingShifts { get; set; }
        public List<TimeOffRequestsForUsers> TimeOffRequests { get; set; }
    }
}
