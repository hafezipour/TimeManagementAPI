namespace TimeManagement.Application.DTOs.AccrualTracks;

public class AccrualTrackProfileResponse
{
    public int Id { get; set; }
    public int AccrualTrackId { get; set; }
    public int AccrualProfileId { get; set; }
    public int SortOrder { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public bool IsBaseOnYearsServed { get; set; }
    public decimal? FromYears { get; set; }
    public decimal? ToYears { get; set; }
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
}

