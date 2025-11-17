using System;

namespace TimeManagement.Application.DTOs.EmployeeAvailability
{
    /// <summary>
    /// Request model for querying employee availability
    /// </summary>
    public class GetAvailabilityRequest
    {
        public int UserId { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }
    }
}
