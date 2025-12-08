namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class TimeOffRequestResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int? AccrualTypeId { get; set; }
    public int? TimeOffTypeId { get; set; }
    public int? Status { get; set; }
    public string? Notes { get; set; }
    public DateTime? DateCreated { get; set; }
    public int? TotalCount { get; set; }
}
