namespace TimeManagement.Application.DTOs.Groups;

/// <summary>
/// Response from usp_ShiftGroups_Delete
/// </summary>
public class DeleteGroupResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int? DeletedId { get; set; }
}


