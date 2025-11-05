using System.ComponentModel.DataAnnotations;

namespace TimeManagement.Application.DTOs.Shifts;

/// <summary>
/// Request model for getting scheduled shifts with filters
/// </summary>
public class GetScheduledShiftsRequest
{
    public int LayoutId { get; set; }
    
    public DateTime StartDate { get; set; }
    
    public DateTime EndDate { get; set; }
    
    public string ViewType { get; set; } // "day", "week", "month"
    
    public int? DepartmentId { get; set; }
    
    public int? LocationId { get; set; }
    
    public int? EmployeeId { get; set; }
}



















