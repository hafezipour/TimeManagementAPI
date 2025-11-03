namespace TimeManagement.Application.DTOs;

public class GetEmployeeJobCodeAssignmentRequest
{
    public int? JobCodeId { get; set; }
    public int? UserId { get; set; }
    public string? SearchStr { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
    public string? SortColumn { get; set; } = "effectiveDate";
    public string? SortDirection { get; set; } = "desc";
}
