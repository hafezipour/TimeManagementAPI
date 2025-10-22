namespace TimeManagement.Application.DTOs;

public class SaveEmployeeJobCodeAssignmentRequest
{
    public int? Id { get; set; }
    public int JobCodeId { get; set; }
    public int UserId { get; set; }
    public bool IsActive { get; set; } = true;
    public string? EffectiveDate { get; set; }
    public string? ExpiryDate { get; set; }
}
