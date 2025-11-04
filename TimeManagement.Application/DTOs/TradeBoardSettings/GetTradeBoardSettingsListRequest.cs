namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request DTO for getting trade board settings list with pagination and sorting
/// </summary>
public class GetTradeBoardSettingsListRequest
{
    public int TenantId { get; set; }
    public int UserId { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
    public string SortColumn { get; set; } = "dateCreated";
    public string SortDirection { get; set; } = "desc";
    public string SearchStr { get; set; } = "";
}
