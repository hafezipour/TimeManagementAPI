namespace TimeManagement.Application.DTOs.ShiftAssignments;

public class DeleteAssignmentRequest
{
    public int AssignmentId { get; set; }
    public string DeleteDate { get; set; } = string.Empty; // ISO date string (yyyy-MM-dd)
    public string? DeleteTime { get; set; } // Optional time string (HH:mm:ss)
}

