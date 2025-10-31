namespace TimeManagement.Application.DTOs.Groups;

/// <summary>
/// Response from usp_ShiftGroups_Save
/// </summary>
public class SaveGroupResponse
{
    public int Id { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; }
}


