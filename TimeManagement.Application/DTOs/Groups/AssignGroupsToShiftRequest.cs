namespace TimeManagement.Application.DTOs.Groups;

public class AssignGroupsToShiftRequest
{
    public int ShiftId { get; set; }
    public string GroupIds { get; set; }
}

