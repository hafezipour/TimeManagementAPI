namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class SaveTimeOffRequestRequest
{
    public int? Id { get; set; }
    public int? UserId { get; set; }
    public int? WorkCodeId { get; set; }
    public int? AccrualTypeId { get; set; }
    public int TimeOffTypeId { get; set; }
    public int? Status { get; set; }
    public string? Notes { get; set; }
    public DateTime FromDate { get; set; }
    public TimeSpan FromTime { get; set; }
    public DateTime ToDate { get; set; }
    public TimeSpan ToTime { get; set; }
    /// <summary>
    /// Multiple employee IDs for bulk requests. Serialized to JSON array for the SP.
    /// </summary>
    public List<int>? EmployeeIds { get; set; }
}


