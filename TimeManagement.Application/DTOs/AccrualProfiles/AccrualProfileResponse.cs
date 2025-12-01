namespace TimeManagement.Application.DTOs.AccrualProfiles;

public class AccrualProfileResponse
{
    public int Id { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public bool IsBaseOnYearsServed { get; set; }
    public decimal? FromYears { get; set; }
    public decimal? ToYears { get; set; }
    public string? Description { get; set; }
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    public int? TrackId { get; set; }
}

