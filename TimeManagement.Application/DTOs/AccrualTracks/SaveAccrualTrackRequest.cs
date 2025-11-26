namespace TimeManagement.Application.DTOs.AccrualTracks;

public class SaveAccrualTrackRequest
{
    public int? Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public List<SaveAccrualTrackProfileRequest> Profiles { get; set; } = new();
}

public class SaveAccrualTrackProfileRequest
{
    public int? Id { get; set; }
    public int AccrualProfileId { get; set; }
    public int SortOrder { get; set; }
}

