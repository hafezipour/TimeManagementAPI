namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for getting holiday assignments
/// Used with usp_HolidayAssignment_Get stored procedure
/// </summary>
public class GetHolidayAssignmentRequest
{
    public string? HolidayIds { get; set; }
    public int? JobCodeId { get; set; }
    public int? UserId { get; set; }
    public string? SearchStr { get; set; }
    public string? AssignmentBy { get; set; } // 'jobcode', 'user', 'both', or null
    public int OffSet { get; set; } = 0;
    public int Limit { get; set; } = 10;
}
