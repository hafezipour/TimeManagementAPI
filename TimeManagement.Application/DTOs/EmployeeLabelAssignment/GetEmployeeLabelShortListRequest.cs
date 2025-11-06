namespace TimeManagement.Application.DTOs.EmployeeLabelAssignment;

public class GetEmployeeLabelShortListRequest
{
    public int? UserId { get; set; }
    public bool? Common { get; set; }
    public string? UserIds { get; set; } // Comma-separated user IDs for common lookup
}
