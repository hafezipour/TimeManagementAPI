namespace TimeManagement.Application.DTOs.Schedules
{
    /// <summary>
    /// Response model for schedule frequency data from usp_Schedules_GetBySource
    /// </summary>
    public class ScheduleFrequencyResponse
    {
        public int Id { get; set; }

        public int ScheduleId { get; set; }

        public int? Day { get; set; }

        public int? DayType { get; set; }
    }
}

