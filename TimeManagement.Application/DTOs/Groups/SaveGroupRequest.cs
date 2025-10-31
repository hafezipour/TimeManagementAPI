namespace TimeManagement.Application.DTOs.Groups;

/// <summary>
/// Request model for saving a Group (Create/Update)
/// Used with usp_ShiftGroups_Save
/// </summary>
public class SaveGroupRequest
{
    public int? Id { get; set; }
    public string GroupName { get; set; }
    public int? GroupTypeCustomTableValueId { get; set; }
    public string Description { get; set; }
    public string ColorCode { get; set; }
    public bool? IsActive { get; set; }
}


