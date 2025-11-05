namespace TimeManagement.Application.DTOs.AssistantQualifiers;

public class SaveAssistantQualifierRequest
{
    public int? Id { get; set; }
    public string Name { get; set; }
    public string Code { get; set; }
    public string? Description { get; set; }
    public string? BackgroundColor { get; set; }
    public string? TextColor { get; set; }
    public bool? IsActive { get; set; }
}



