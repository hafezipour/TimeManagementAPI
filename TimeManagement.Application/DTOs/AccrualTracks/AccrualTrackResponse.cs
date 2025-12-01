namespace TimeManagement.Application.DTOs.AccrualTracks;

public class AccrualTrackResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    
    public List<AccrualTrackProfileResponse> Profiles { get; set; } = new();
}

