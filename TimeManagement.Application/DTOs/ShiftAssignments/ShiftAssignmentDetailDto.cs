using TimeManagement.Application.DTOs.Schedules;

namespace TimeManagement.Application.DTOs.ShiftAssignments;

public class ShiftAssignmentDetailDto
{
    public int Id { get; set; }
    public int ShiftId { get; set; }
    public int UserId { get; set; }
    public int? StatusCustomTableValueId { get; set; }
    public string? Notes { get; set; }
    public DateTimeOffset? AssignedAt { get; set; }
    public int? AssignedBy { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    public int? ScheduleId { get; set; }
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    
    // Shift information
    public string ShiftName { get; set; }
    public string ShiftCode { get; set; }
    public string ShiftBackgroundColour { get; set; }
    
    // Related arrays
    public List<AssignmentWorkCode>? WorkCodes { get; set; }
    public List<AssignmentJobCode>? JobCodes { get; set; }
    public List<AssignmentLabel>? Labels { get; set; }
}

public class AssignmentWorkCode
{
    public int Id { get; set; }
    public string WorkCodeName { get; set; }
    public string WorkCode { get; set; }
    public string ColorCode { get; set; }
    public bool IsActive { get; set; }
}

public class AssignmentJobCode
{
    public int Id { get; set; }
    public string JobTitle { get; set; }
    public string JobCode { get; set; }
    public bool IsActive { get; set; }
}

public class AssignmentLabel
{
    public int Id { get; set; }
    public string LabelName { get; set; }
    public string LabelCode { get; set; }
    public string ColorCode { get; set; }
    public bool IsActive { get; set; }
}

