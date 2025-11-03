namespace TimeManagement.Application.DTOs.Labels;

public class SaveLabelRequest
{
    public int? Id { get; set; }
    public string LabelName { get; set; } = string.Empty;
    public string LabelCode { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ColorCode { get; set; }
    public bool IsActive { get; set; } = true;
}

