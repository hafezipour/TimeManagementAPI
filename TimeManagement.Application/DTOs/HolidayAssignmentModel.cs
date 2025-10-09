namespace TimeManagement.Application.DTOs;

/// <summary>
/// Holiday Assignment entity interface - matches the response from usp_HolidayAssignment_Get
/// </summary>
public class HolidayAssignmentModel
{
    public int id { get; set; }
    public int tenantId { get; set; }
    public int holidayId { get; set; }
    public int jobCodeId { get; set; }
    public int userId { get; set; }
    public bool isActive { get; set; }
    public DateTime? effectiveDate { get; set; }
    public DateTime? expiryDate { get; set; }
    public int createdBy { get; set; }
    public int? updatedBy { get; set; }
    public DateTime dateCreated { get; set; }
    public DateTime? dateUpdated { get; set; }
    
    // Joined data
    public string holidayCode { get; set; } = string.Empty;
    public string holidayName { get; set; } = string.Empty;
    public DateTime holidayDate { get; set; }
    public string jobCode { get; set; } = string.Empty;
    public string jobTitle { get; set; } = string.Empty;
    public string userName { get; set; } = string.Empty;
    public int totalCount { get; set; }
}
