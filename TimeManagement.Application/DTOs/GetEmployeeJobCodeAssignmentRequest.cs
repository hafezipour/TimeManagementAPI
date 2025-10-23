namespace TimeManagement.Application.DTOs;

public class GetEmployeeJobCodeAssignmentRequest
{
    public int? JobCodeId { get; set; }
    public int? UserId { get; set; }
    public string? SearchStr { get; set; }
}
