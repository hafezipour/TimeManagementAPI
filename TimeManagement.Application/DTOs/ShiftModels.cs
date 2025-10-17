namespace TimeManagement.Application.DTOs;



/// <summary>
/// Request model for saving a Shift (Create/Update)
/// Used with usp_Shifts_Save stored procedure
/// </summary>
public class SaveShiftRequest
{
    public int? Id { get; set; }
    public string ShiftName { get; set; } = string.Empty;
    public string ShiftCode { get; set; } = string.Empty;
    public bool? IsNoAssignmentTime { get; set; }
    public int? MinimumPositions { get; set; }
    public int? MaxTimeOffs { get; set; }
    public string? Location { get; set; }
    public bool? IsWorkShift { get; set; }
    public bool? IsSelfSchedulingEnabled { get; set; }
    public bool? IsSelfSchedulingRequiresAdminApprovals { get; set; }
    public bool? IsHideOpenSlots { get; set; }
    public int ShiftLabelId { get; set; }
    public string? BackgroundColour { get; set; }
    public bool? IsActive { get; set; }
    public int? DisplayOrder { get; set; }
    
    // Comma-separated IDs
    public string? WorkCodeIds { get; set; }
    public string? AdminIds { get; set; }
    
    // Schedule data
    public List<Schedule>? Schedules { get; set; }
}

/// <summary>
/// Request model for getting shifts with server-side paging
/// Used with usp_Shifts_Get stored procedure
/// </summary>
public class GetShiftRequest
{
    public int? ShiftId { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
    public string? SearchTerm { get; set; }
}

/// <summary>
/// Request model for deleting a shift
/// Used with usp_Shifts_Delete stored procedure
/// </summary>
public class DeleteShiftRequest
{
    public int ShiftId { get; set; }
}

/// <summary>
/// Response from usp_Shifts_Save
/// </summary>
public class SaveShiftResponse
{
    public int Id { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

/// <summary>
/// Response from usp_Shifts_Delete
/// </summary>
public class DeleteShiftResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int? DeletedId { get; set; }
}




