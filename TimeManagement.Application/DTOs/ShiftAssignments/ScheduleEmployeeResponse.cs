namespace TimeManagement.Application.DTOs.ShiftAssignments;

public class ScheduleEmployeeResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int? Id { get; set; }
    public int? ShiftId { get; set; }
    public int? UserId { get; set; }
    public string? Notes { get; set; }
    public DateTimeOffset? AssignedAt { get; set; }
    public int? AssignedBy { get; set; }
}

