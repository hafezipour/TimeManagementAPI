using System;

namespace TimeManagement.Application.DTOs.EmployeeAvailability
{
    /// <summary>
    /// Request model for creating/updating employee availability
    /// </summary>
    public class AvailabilityRequest
    {
        public int? Id { get; set; }

        public int UserId { get; set; }

        /// <summary>
        /// Start date of availability
        /// </summary>
        public DateTime StartDate { get; set; }

        public string StartTime { get; set; }

        /// <summary>
        /// End date - defaults to StartDate if not provided (same-day availability)
        /// </summary>
        public DateTime EndDate { get; set; }

        /// <summary>
        /// End time - defaults to 11:59 PM if not provided (end of day)
        /// </summary>
        public string EndTime { get; set; }

        /// <summary>
        /// True = available for scheduling (work/meeting time)
        /// False = unavailable/blocked time
        /// </summary>
        public bool IsAvailable { get; set; }

        /// <summary>
        /// Notes or reason (e.g., "Doctor appointment", "Personal leave", "Meeting")
        /// </summary>
        public string Notes { get; set; }

        /// <summary>
        /// List of shift assignments for this availability period
        /// </summary>
        public List<ShiftAssignmentDto> Assignments { get; set; }
    }
}
