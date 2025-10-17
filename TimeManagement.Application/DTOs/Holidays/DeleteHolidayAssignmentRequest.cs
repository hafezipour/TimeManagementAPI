namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for deleting a holiday assignment
/// Used with usp_HolidayAssignment_Delete stored procedure
/// </summary>
public class DeleteHolidayAssignmentRequest
{
    public int HolidayAssignmentId { get; set; }
}
