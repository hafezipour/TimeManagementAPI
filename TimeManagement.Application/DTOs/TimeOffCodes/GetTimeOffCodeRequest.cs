namespace TimeManagement.Application.DTOs.TimeOffCodes;

public class GetTimeOffCodeRequest
{
    public int? TimeOffCodeId { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
    public string? SearchTerm { get; set; }
}

