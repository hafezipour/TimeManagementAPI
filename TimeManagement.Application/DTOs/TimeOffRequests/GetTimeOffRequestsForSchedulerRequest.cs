namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class GetTimeOffRequestsForSchedulerRequest
{
    public List<int>? UserIds { get; set; }
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public int? StatusFilter { get; set; } // 1 = Pending, 2 = Approved, null = Both
}

