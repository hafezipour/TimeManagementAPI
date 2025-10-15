namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for updating WorkCode Active Status
/// </summary>
public class UpdateActiveStatusRequest
{
    public int WorkCodeId { get; set; }
    public bool IsActive { get; set; }
}

/// <summary>
/// Request model for updating WorkCode Default Status
/// </summary>
public class UpdateDefaultStatusRequest
{
    public int WorkCodeId { get; set; }
    public bool IsDefault { get; set; }
}
