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
    
    public List<int>? EmployeeIds { get; set; }
    public List<int>? ShiftIds { get; set; }//currently not in use, but can be used for filters or fetching data for selective shift(s) only in futures
    public bool? IsAssignmentScreen { get; set; }
}






























