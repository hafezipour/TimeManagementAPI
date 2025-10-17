using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TimeManagement.Application.DTOs.Schedules;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Request model for saving a Shift (Create/Update)
    /// Used with usp_Shifts_Save stored procedure
    /// </summary>
    public class SaveShiftRequest
    {
        public int? Id { get; set; }
        public string ShiftName { get; set; } = string.Empty;
        public string ShiftCode { get; set; } = string.Empty;
        public bool? IsNoAssignmentTime { get; set; }
        public int? MinimumPositions { get; set; }
        public int? MaxTimeOffs { get; set; }
        public string? Location { get; set; }
        public bool? IsWorkShift { get; set; }
        public bool? IsSelfSchedulingEnabled { get; set; }
        public bool? IsSelfSchedulingRequiresAdminApprovals { get; set; }
        public bool? IsHideOpenSlots { get; set; }
        public string? BackgroundColour { get; set; }
        public bool? IsActive { get; set; }
        public int? DisplayOrder { get; set; }

        // Comma-separated IDs
        public string? WorkCodeIds { get; set; }
        public string? AdminIds { get; set; }

        // Schedule data
        public List<Schedule>? Schedules { get; set; }
    }

}
