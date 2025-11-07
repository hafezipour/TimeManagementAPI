namespace TimeManagement.Application.DTOs.Schedules;

/// <summary>
/// Represents the response returned by usp_Schedules_Save
/// </summary>
public class ScheduleSaveResult
{
    public int? Id { get; set; }

    public bool Success { get; set; }

    public string? Message { get; set; }
}

