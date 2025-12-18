namespace TimeManagement.Application.DTOs.ShiftTrades;

/// <summary>
/// Request model for getting trade requests with server-side paging
/// </summary>
public class GetTradeRequestsRequest
{
    public int? UserId { get; set; } // Filter by user
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
}

