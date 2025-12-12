using System;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.DTOs.ShiftAssignments;

namespace TimeManagement.Domain.Models
{
    /// <summary>
    /// Represents a scheduling shift with column assignment and schedule information
    /// Returned by usp_Shifts_GetSchedulingShifts
    /// </summary>
    public class SchedulingShift
    {
        //public int? ColumnId { get; set; }

        //public int? ColumnShiftId { get; set; }

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
        public ScheduleResponse Schedules { get; set; }
        public string labelName { get; set; }
        public string labelCode { get; set; }
        public string colorCode { get; set; }
        public List<ShiftGroupAssignment> ShiftGroupAssignments { get; set; }
        public List<ShiftAssignmentDetailDto> UserAssignments { get; set; }
        public List<ShiftWorkCode> WorkCodes { get; set; }
        public List<ShiftJobCode> JobCodes { get; set; }

        // Additional properties can be added as needed
        public DateTime? EvaluationDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }


    }
    public class ShiftGroupAssignment
    {
        public int id { get; set; }
        public int shiftId { get; set; }
        public int groupId { get; set; }
        public string groupName { get; set; }
        public string colorCode { get; set; }
    }

    public class ShiftWorkCode
    {
        public int id { get; set; }
        public string workCodeName { get; set; }
        public string workCode { get; set; }
        public string colorCode { get; set; }
        public bool isActive { get; set; }
    }

    public class ShiftJobCode
    {
        public int id { get; set; }
        public string jobTitle { get; set; }
        public string jobCode { get; set; }
        public bool isActive { get; set; }
    }
}
