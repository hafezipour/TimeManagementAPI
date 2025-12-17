using TimeManagement.Application.DTOs.Schedules;

namespace TimeManagement.Application.DTOs.ShiftAssignments;

public class ScheduleEmployeeRequest
{
    public int? Id { get; set; } // Optional: Assignment ID for updates
    public int ShiftId { get; set; }
    public int UserId { get; set; }
    public string? WorkCodeIds { get; set; } // Comma-separated work code IDs
    public string? JobCodeIds { get; set; } // Comma-separated job code IDs
    public string? LabelIds { get; set; } // Comma-separated label IDs
    public string? Notes { get; set; }
    public int? ExcludeAssignmentId { get; set; }
    public List<ScheduleRequest>? Schedules { get; set; }
}

