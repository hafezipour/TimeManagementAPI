namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for deleting a holiday
/// Used with usp_Holidays_Delete stored procedure
/// </summary>
public class DeleteHolidayRequest
{
    public int HolidayId { get; set; }
}
