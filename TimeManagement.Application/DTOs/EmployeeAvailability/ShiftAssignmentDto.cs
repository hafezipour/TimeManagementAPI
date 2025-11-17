namespace TimeManagement.Application.DTOs.EmployeeAvailability
{
    /// <summary>
    /// Shift assignment for availability period
    /// </summary>
    public class ShiftAssignmentDto
    {
        public int ShiftId { get; set; }

        public string ShiftName { get; set; }

        public string ShiftCode { get; set; }

        public string BackgroundColour { get; set; }
    }
}
