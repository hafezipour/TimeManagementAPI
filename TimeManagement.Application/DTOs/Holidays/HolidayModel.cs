namespace TimeManagement.Application.DTOs;

public class HolidayModel
{
    public int? Id { get; set; }
    public string HolidayCode { get; set; } = string.Empty;
    public string HolidayName { get; set; } = string.Empty;
    public DateTime HolidayDate { get; set; }
    public DateTime? ObservedDate { get; set; }
    public bool? IsObserved { get; set; }
    public bool? IsFloating { get; set; }
    public bool? IsAppliesToAll { get; set; }
    public DateTime? CreatedDate { get; set; }
    public DateTime? ModifiedDate { get; set; }
}

