namespace TimeManagement.Application.DTOs.ShiftTrades;

/// <summary>
/// Response model for trade requests with server-side paging
/// </summary>
public class GetTradeRequestsResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public List<TradeRequestDto> Data { get; set; }
    public int TotalRecords { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
}

/// <summary>
/// Trade request data transfer object
/// </summary>
public class TradeRequestDto
{
    public int Id { get; set; }
    public int FromUserId { get; set; }
    public string FromUserName { get; set; }
    public int ToUserId { get; set; }
    public string ToUserName { get; set; }
    public int FromAssignmentId { get; set; }
    public int ToAssignmentId { get; set; }
    public int? StatusCustomTableValueId { get; set; }
    public DateTimeOffset? RequestedAt { get; set; }
    public DateTimeOffset? ApprovedAt { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    
    // From Assignment Schedule Fields
    public DateTime? FromScheduleStartFrom { get; set; }
    public TimeSpan? FromScheduleStartTime { get; set; }
    public DateTime? FromScheduleValidUntil { get; set; }
    public TimeSpan? FromScheduleEndTime { get; set; }
    
    // To Assignment Schedule Fields
    public DateTime? ToScheduleStartFrom { get; set; }
    public TimeSpan? ToScheduleStartTime { get; set; }
    public DateTime? ToScheduleValidUntil { get; set; }
    public TimeSpan? ToScheduleEndTime { get; set; }
}

