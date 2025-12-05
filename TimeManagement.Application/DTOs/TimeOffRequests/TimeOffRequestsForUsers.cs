namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class TimeOffRequestsForUsers
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int Status { get; set; }
    public int? TimeOffTypeId { get; set; }
    public int? AccrualTypeId { get; set; }
    public string? Notes { get; set; }
    public DateTime? DateCreated { get; set; }
    public DateTime? StartFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    public string? TimeOffTypeName { get; set; }
    public string? TimeOffTypeCode { get; set; }
    public string? AccrualTypeName { get; set; }
}

public class TimeOffOccurrence
{
    public DateTime StartDateTime { get; set; }
    public DateTime EndDateTime { get; set; }
}

public class OverlappingTimeOffRequest
{
    public int Id { get; set; }
    public string? TimeOffTypeName { get; set; }
    public string? AccrualTypeName { get; set; }
    public DateTime? StartFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    public List<TimeOffOccurrence> OverlappingOccurrences { get; set; } = new List<TimeOffOccurrence>();
}

