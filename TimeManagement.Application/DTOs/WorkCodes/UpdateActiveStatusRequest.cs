namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for updating WorkCode Active Status
/// </summary>
public class UpdateActiveStatusRequest
{
    public int WorkCodeId { get; set; }
    public bool IsActive { get; set; }
}


