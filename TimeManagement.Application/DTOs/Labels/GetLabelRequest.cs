namespace TimeManagement.Application.DTOs.Labels;

public class GetLabelRequest
{
    public int? LabelId { get; set; }
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
    public string? SortColumn { get; set; }
    public string? SortDirection { get; set; }
    public string? SearchTerm { get; set; }
}

