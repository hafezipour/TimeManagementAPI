namespace TimeManagement.Application.DTOs.TimeOffCodes;

public class SaveTimeOffCodeRequest
{
    public int? Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string BackgroundColor { get; set; } = string.Empty;
    public string TextColor { get; set; } = string.Empty;
    public bool IsRequestable { get; set; } = true;
}

