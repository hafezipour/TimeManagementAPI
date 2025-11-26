namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class SaveEmployeeAccrualSettingsRequest
{
    public int? Id { get; set; }
    public int UserId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int? AccrualProfileId { get; set; }
    public string AccrualStartDate { get; set; } = string.Empty;
}

