namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for deleting a WorkCode
/// Used with usp_WorkCodes_Delete stored procedure
/// </summary>
public class DeleteWorkCodeRequest
{
    public int WorkCodeId { get; set; }
}

