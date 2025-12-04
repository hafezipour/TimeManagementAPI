namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class GetTimeOffRequestRequest
{
    public int? TimeOffRequestId { get; set; }
    public int? UserId { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
    public string? SearchTerm { get; set; }
}

