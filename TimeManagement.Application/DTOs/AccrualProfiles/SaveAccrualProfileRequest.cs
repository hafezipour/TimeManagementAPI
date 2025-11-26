namespace TimeManagement.Application.DTOs.AccrualProfiles;

public class SaveAccrualProfileRequest
{
    public int? Id { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public bool IsBaseOnYearsServed { get; set; }
    public decimal? FromYears { get; set; }
    public decimal? ToYears { get; set; }
    public string? Description { get; set; }
}

