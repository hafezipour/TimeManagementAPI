namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for saving a holiday (Create/Update)
/// Used with usp_Holidays_Save stored procedure
/// </summary>
public class SaveHolidayRequest
{
    public int? Id { get; set; }
    public string HolidayCode { get; set; } = string.Empty;
    public string HolidayName { get; set; } = string.Empty;
    public DateTime HolidayDate { get; set; }
    public DateTime? ObservedDate { get; set; }
    public bool IsObserved { get; set; }
    public bool IsFloating { get; set; }
    public bool IsAppliesToAll { get; set; }
}
