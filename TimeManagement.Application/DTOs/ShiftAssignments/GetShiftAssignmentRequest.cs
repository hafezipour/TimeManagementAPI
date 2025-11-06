namespace TimeManagement.Application.DTOs.ShiftAssignments;

public class GetShiftAssignmentRequest
{
    public string? UserIds { get; set; } // Comma-separated user IDs
    public string? ShiftIds { get; set; } // Comma-separated shift IDs
}

