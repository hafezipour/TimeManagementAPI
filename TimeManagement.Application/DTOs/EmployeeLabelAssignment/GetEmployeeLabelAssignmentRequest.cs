namespace TimeManagement.Application.DTOs.EmployeeLabelAssignment;

public class GetEmployeeLabelAssignmentRequest
{
    public int? Id { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
    public string? SearchTerm { get; set; }
}

