namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class CheckTimeOffOverlapRequest
{
    public List<int> UserIds { get; set; } = new List<int>();
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public TimeSpan FromTime { get; set; }
    public TimeSpan ToTime { get; set; }
    public int? ExcludeId { get; set; }
}

