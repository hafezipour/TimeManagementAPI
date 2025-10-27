using System;
using TimeManagement.Application.DTOs.Schedules;

namespace TimeManagement.Domain.Models
{
    /// <summary>
    /// Represents a scheduling shift with column assignment and schedule information
    /// Returned by usp_Shifts_GetSchedulingShifts
    /// </summary>
    public class SchedulingShift
    {
        public int? ColumnId { get; set; }

        public int? ColumnShiftId { get; set; }

        public int Id { get; set; }

        public string ShiftName { get; set; }

        public string ShiftCode { get; set; }

        public int? MinimumPositions { get; set; }

        public int? MaxTimeOffs { get; set; }

        public string Location { get; set; }

        public bool? IsWorkShift { get; set; }

        public bool? IsSelfSchedulingEnabled { get; set; }

        public bool? IsSelfSchedulingRequiresAdminApprovals { get; set; }

        public bool? IsHideOpenSlots { get; set; }

        public int? ShiftLabelId { get; set; }

        public string BackgroundColour { get; set; }

        public bool? IsActive { get; set; }

        public int CreatedBy { get; set; }

        public int? UpdatedBy { get; set; }

        public DateTimeOffset DateCreated { get; set; }

        public DateTimeOffset? DateUpdated { get; set; }

        public int? DisplayOrder { get; set; }
        public List<ScheduleResponse> Schedules { get; set; }
    }
}