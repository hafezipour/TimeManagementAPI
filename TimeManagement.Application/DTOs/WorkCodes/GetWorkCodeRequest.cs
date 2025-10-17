namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for getting WorkCodes
/// Used with usp_WorkCodes_Get stored procedure
/// </summary>
public class GetWorkCodeRequest
{
    public int? WorkCodeId { get; set; }
}

