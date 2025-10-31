namespace TimeManagement.Application.DTOs.Groups;

/// <summary>
/// Request model for getting groups with server-side paging
/// </summary>
public class GetGroupRequest
{
    public int? GroupId { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string SortColumn { get; set; }
    public string SortDirection { get; set; }
    public string SearchTerm { get; set; }
}


