namespace TimeManagement.Application.DTOs;

public class HolidayAssignmentModel
{
    public int Id { get; set; }
    public int HolidayId { get; set; }
    public string HolidayName { get; set; } = string.Empty;
    public string HolidayCode { get; set; } = string.Empty;
    public DateTime HolidayDate { get; set; }
    public int? JobCodeId { get; set; }
    public string? JobCodeName { get; set; }
    public int? UserId { get; set; }
    public string? UserName { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? ModifiedDate { get; set; }
}

