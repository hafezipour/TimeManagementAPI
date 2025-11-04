namespace TimeManagement.Application.DTOs.EmployeeLabelAssignment;

public class SaveEmployeeLabelAssignmentRequest
{
    public int? Id { get; set; }
    public int LabelId { get; set; }
    public int UserId { get; set; }
    public DateTime? EffectiveDate { get; set; }
    public DateTime? ExpiryDate { get; set; }
}

