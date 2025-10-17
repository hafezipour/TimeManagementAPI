namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for getting holidays
/// Used with usp_Holidays_Get stored procedure
/// </summary>
public class GetHolidayRequest
{
    public int? HolidayId { get; set; }
}
