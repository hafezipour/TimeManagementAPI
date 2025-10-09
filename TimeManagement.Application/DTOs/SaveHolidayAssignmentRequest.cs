namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for saving a holiday assignment (Create/Update)
/// Used with usp_HolidayAssignment_Save stored procedure
/// </summary>
public class SaveHolidayAssignmentRequest
{
    public int? Id { get; set; }
    public int HolidayId { get; set; }
    public int JobCodeId { get; set; }
    public int UserId { get; set; }
    public bool IsActive { get; set; }
    public DateTime? EffectiveDate { get; set; }
    public DateTime? ExpiryDate { get; set; }
}
