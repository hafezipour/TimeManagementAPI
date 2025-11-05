namespace TimeManagement.Application.DTOs;

public class GetEmployeeWorkCodeShortListRequest
{
    public int? UserId { get; set; }
    public bool? Common { get; set; }
    public string? UserIds { get; set; } // Comma-separated user IDs for common lookup
}

