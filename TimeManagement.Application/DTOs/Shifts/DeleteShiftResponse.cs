namespace TimeManagement.Application.DTOs;

/// <summary>
/// Response from usp_Shifts_Delete
/// </summary>
public class DeleteShiftResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int? DeletedId { get; set; }
}




