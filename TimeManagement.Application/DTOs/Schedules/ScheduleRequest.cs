using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.DTOs.Schedules
{
    /// <summary>
    /// Schedule model for shift schedules
    /// </summary>
    public class ScheduleRequest
    {
        public int? Id { get; set; }
        public int ShiftId { get; set; }
        public int? SourceType { get; set; }
        public int? SourceId { get; set; }
        public DateTime StartFrom { get; set; }
        public bool ScheduleWithoutTimes { get; set; }
        public string? StartTime { get; set; }
        public string? EndTime { get; set; }
        public int ScheduleType { get; set; }  // 1=Daily, 2=Weekly, 3=Monthly, 4=DoesNotRepeat, 5=DaysOnOff
        public int RepeatEvery { get; set; }
        public List<ScheduleFrequencyRequest>? Frequency { get; set; }
        public int EndType { get; set; }  // 1=Never, 2=OnDate, 3=AfterOccurrences
        public DateTime? ValidUntil { get; set; }
        public int? MaxOccurrences { get; set; }
        public bool IsActive { get; set; }

        private TimeSpan? ParseTime(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return null;
            }

            if (TimeSpan.TryParse(value, CultureInfo.InvariantCulture, out var timeSpan))
            {
                return timeSpan;
            }

            if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateTime))
            {
                return dateTime.TimeOfDay;
            }

            return null;
        }
        public ScheduleResponse? ConvertToScheduleResponse(ScheduleRequest request)
        {
            if (request == null)
            {
                return null;
            }

            var schedule = new ScheduleResponse
            {
                Id = request.Id ?? 0,
                SourceType = request.SourceType ?? (int)ScheduleSourceTypes.ShiftAssignment,
                SourceId = request.SourceId ?? 0,
                StartFrom = request.StartFrom,
                ScheduleWithoutTimes = request.ScheduleWithoutTimes,
                ScheduleType = request.ScheduleType,
                RepeatEvery = request.RepeatEvery,
                EndType = Enum.IsDefined(typeof(EndType), request.EndType)
                    ? Enum.GetName(typeof(EndType), request.EndType)
                    : request.EndType.ToString(CultureInfo.InvariantCulture),
                ValidUntil = request.ValidUntil.HasValue ? new DateTimeOffset(request.ValidUntil.Value) : null,
                MaxOccurrences = request.MaxOccurrences,
                IsActive = request.IsActive,
                Frequency = request.Frequency?.Select(f => new ScheduleFrequencyResponse
                {
                    Day = f.Day,
                    DayType = f.DayType
                }).ToList()
            };

            var startTime = ParseTime(request.StartTime);
            var endTime = ParseTime(request.EndTime);

            schedule.StartTime = startTime;
            schedule.EndTime = endTime;

            if (startTime == null || endTime == null)
            {
                schedule.ScheduleWithoutTimes = true;
            }

            return schedule;
        }

    }
}
