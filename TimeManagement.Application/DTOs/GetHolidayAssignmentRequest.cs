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
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}
