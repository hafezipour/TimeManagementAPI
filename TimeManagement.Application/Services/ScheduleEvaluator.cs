using System;
using System.Collections.Generic;
using System.Linq;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services
{
    /// <summary>
    /// Evaluates schedules and generates valid occurrence dates based on schedule rules
    /// </summary>
    public class ScheduleEvaluator
    {
        /// <summary>
        /// Evaluates a schedule and returns all valid occurrence dates within the specified date range
        /// </summary>
        /// <param name="schedule">The schedule to evaluate</param>
        /// <param name="rangeStart">Start date of the evaluation range</param>
        /// <param name="rangeEnd">End date of the evaluation range</param>
        /// <returns>List of dates when the schedule is valid</returns>
        public List<DateTime> EvaluateSchedule(ScheduleResponse schedule, DateTime rangeStart, DateTime rangeEnd)
        {
            if (schedule == null)
                throw new ArgumentNullException(nameof(schedule));

            if (rangeEnd < rangeStart)
                throw new ArgumentException("Range end must be greater than or equal to range start");

            var validDates = new List<DateTime>();

            // Get schedule start date
            if (!schedule.StartFrom.HasValue)
                return validDates; // No start date, no valid occurrences

            var scheduleStartDate = schedule.StartFrom.Value.Date;

            // If schedule starts after range end, no occurrences
            if (scheduleStartDate > rangeEnd)
                return validDates;

            // Get schedule end date based on EndType
            DateTime? scheduleEndDate = GetScheduleEndDate(schedule);

            // If schedule ended before range start, no occurrences
            if (scheduleEndDate.HasValue && scheduleEndDate.Value < rangeStart)
                return validDates;

            // Determine which schedule type to evaluate
            var scheduleType = schedule.ScheduleType.HasValue ? (ScheduleType)schedule.ScheduleType.Value : ScheduleType.DoesNotRepeat;

            switch (scheduleType)
            {
                case ScheduleType.DoesNotRepeat:
                    validDates = EvaluateDoesNotRepeat(scheduleStartDate, rangeStart, rangeEnd);
                    break;

                case ScheduleType.Daily:
                    validDates = EvaluateDaily(schedule, scheduleStartDate, rangeStart, rangeEnd, scheduleEndDate);
                    break;

                case ScheduleType.Weekly:
                    validDates = EvaluateWeekly(schedule, scheduleStartDate, rangeStart, rangeEnd, scheduleEndDate);
                    break;

                case ScheduleType.Monthly:
                    validDates = EvaluateMonthly(schedule, scheduleStartDate, rangeStart, rangeEnd, scheduleEndDate);
                    break;

                case ScheduleType.DaysOnOff:
                    validDates = EvaluateDaysOnOff(schedule, scheduleStartDate, rangeStart, rangeEnd, scheduleEndDate);
                    break;

                default:
                    break;
            }

            // Apply max occurrences limit if specified
            if (schedule.MaxOccurrences.HasValue && validDates.Count > schedule.MaxOccurrences.Value)
            {
                validDates = validDates.Take(schedule.MaxOccurrences.Value).ToList();
            }

            return validDates;
        }

        /// <summary>
        /// Gets the end date of the schedule based on EndType
        /// </summary>
        private DateTime? GetScheduleEndDate(ScheduleResponse schedule)
        {
            if (string.IsNullOrEmpty(schedule.EndType))
                return null;

            var endType = ParseEndType(schedule.EndType);

            switch (endType)
            {
                case EndType.Never:
                    return null; // No end date

                case EndType.OnDate:
                    return schedule.ValidUntil?.Date;

                case EndType.AfterOccurrences:
                    // For max occurrences, we don't set an end date here
                    // It will be handled after generating dates
                    return null;

                default:
                    return null;
            }
        }

        /// <summary>
        /// Parses EndType from string value
        /// </summary>
        private EndType ParseEndType(string endTypeStr)
        {
            if (string.IsNullOrEmpty(endTypeStr))
                return EndType.Never;

            var lower = endTypeStr.ToLower();
            
            if (lower == "never" || lower == "1")
                return EndType.Never;
            else if (lower == "ondate" || lower == "2")
                return EndType.OnDate;
            else if (lower == "afteroccurrences" || lower == "3")
                return EndType.AfterOccurrences;
            
            return EndType.Never;
        }

        /// <summary>
        /// Evaluates DoesNotRepeat schedule - returns single occurrence on start date
        /// </summary>
        private List<DateTime> EvaluateDoesNotRepeat(DateTime scheduleStart, DateTime rangeStart, DateTime rangeEnd)
        {
            var validDates = new List<DateTime>();

            if (scheduleStart >= rangeStart && scheduleStart <= rangeEnd)
            {
                validDates.Add(scheduleStart);
            }

            return validDates;
        }

        /// <summary>
        /// Evaluates Daily schedule - repeats every N days
        /// </summary>
        private List<DateTime> EvaluateDaily(ScheduleResponse schedule, DateTime scheduleStart, 
            DateTime rangeStart, DateTime rangeEnd, DateTime? scheduleEndDate)
        {
            var validDates = new List<DateTime>();
            var repeatEvery = schedule.RepeatEvery ?? 1;

            if (repeatEvery < 1) repeatEvery = 1;

            var currentDate = scheduleStart;

            // Adjust current date to the first occurrence within or after range start
            if (currentDate < rangeStart)
            {
                var daysDiff = (rangeStart - currentDate).Days;
                var occurrences = (int)Math.Ceiling((double)daysDiff / repeatEvery);
                currentDate = currentDate.AddDays(occurrences * repeatEvery);
            }

            while (currentDate <= rangeEnd)
            {
                if (scheduleEndDate.HasValue && currentDate > scheduleEndDate.Value)
                    break;

                if (currentDate >= rangeStart)
                {
                    validDates.Add(currentDate);
                }

                currentDate = currentDate.AddDays(repeatEvery);
            }

            return validDates;
        }

        /// <summary>
        /// Evaluates Weekly schedule - repeats on specific days of week every N weeks
        /// </summary>
        private List<DateTime> EvaluateWeekly(ScheduleResponse schedule, DateTime scheduleStart, 
            DateTime rangeStart, DateTime rangeEnd, DateTime? scheduleEndDate)
        {
            var validDates = new List<DateTime>();
            var repeatEvery = schedule.RepeatEvery ?? 1;

            if (repeatEvery < 1) repeatEvery = 1;

            // Get selected days of week from frequency (0 = Sunday, 6 = Saturday)
            var selectedDaysOfWeek = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value >= 0 && f.Day.Value <= 6)
                .Select(f => f.Day.Value)
                .Distinct()
                .OrderBy(d => d)
                .ToList() ?? new List<int>();

            if (selectedDaysOfWeek.Count == 0)
                return validDates; // No days selected

            // Start from the beginning of the week containing scheduleStart
            var startOfFirstWeek = scheduleStart.AddDays(-(int)scheduleStart.DayOfWeek);
            var currentWeekStart = startOfFirstWeek;

            // Move to first week that overlaps with range start
            while (currentWeekStart.AddDays(6) < rangeStart)
            {
                currentWeekStart = currentWeekStart.AddDays(7 * repeatEvery);
            }

            // Generate occurrences
            while (currentWeekStart <= rangeEnd)
            {
                foreach (var dayOfWeek in selectedDaysOfWeek)
                {
                    var occurrenceDate = currentWeekStart.AddDays(dayOfWeek);

                    // Check if occurrence is within all bounds
                    if (occurrenceDate >= scheduleStart && 
                        occurrenceDate >= rangeStart && 
                        occurrenceDate <= rangeEnd &&
                        (!scheduleEndDate.HasValue || occurrenceDate <= scheduleEndDate.Value))
                    {
                        validDates.Add(occurrenceDate);
                    }
                }

                currentWeekStart = currentWeekStart.AddDays(7 * repeatEvery);

                if (scheduleEndDate.HasValue && currentWeekStart > scheduleEndDate.Value)
                    break;
            }

            return validDates.OrderBy(d => d).ToList();
        }

        /// <summary>
        /// Evaluates Monthly schedule - repeats on specific days of month every N months
        /// </summary>
        private List<DateTime> EvaluateMonthly(ScheduleResponse schedule, DateTime scheduleStart, 
            DateTime rangeStart, DateTime rangeEnd, DateTime? scheduleEndDate)
        {
            var validDates = new List<DateTime>();
            var repeatEvery = schedule.RepeatEvery ?? 1;

            if (repeatEvery < 1) repeatEvery = 1;

            // Get selected days of month from frequency (1-31)
            var selectedDaysOfMonth = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value >= 1 && f.Day.Value <= 31)
                .Select(f => f.Day.Value)
                .Distinct()
                .OrderBy(d => d)
                .ToList() ?? new List<int>();

            if (selectedDaysOfMonth.Count == 0)
                return validDates; // No days selected

            // Start from the month containing scheduleStart
            var currentMonth = new DateTime(scheduleStart.Year, scheduleStart.Month, 1);

            // Move to first month that could contain range start
            while (currentMonth.AddMonths(1).AddDays(-1) < rangeStart)
            {
                currentMonth = currentMonth.AddMonths(repeatEvery);
            }

            // Generate occurrences
            while (currentMonth <= rangeEnd)
            {
                var daysInMonth = DateTime.DaysInMonth(currentMonth.Year, currentMonth.Month);

                foreach (var dayOfMonth in selectedDaysOfMonth)
                {
                    // Skip if day doesn't exist in this month (e.g., Feb 30)
                    if (dayOfMonth > daysInMonth)
                        continue;

                    var occurrenceDate = new DateTime(currentMonth.Year, currentMonth.Month, dayOfMonth);

                    // Check if occurrence is within all bounds
                    if (occurrenceDate >= scheduleStart && 
                        occurrenceDate >= rangeStart && 
                        occurrenceDate <= rangeEnd &&
                        (!scheduleEndDate.HasValue || occurrenceDate <= scheduleEndDate.Value))
                    {
                        validDates.Add(occurrenceDate);
                    }
                }

                currentMonth = currentMonth.AddMonths(repeatEvery);

                if (scheduleEndDate.HasValue && currentMonth > scheduleEndDate.Value)
                    break;
            }

            return validDates.OrderBy(d => d).ToList();
        }

        /// <summary>
        /// Evaluates DaysOnOff schedule - pattern of N days on, M days off
        /// </summary>
        private List<DateTime> EvaluateDaysOnOff(ScheduleResponse schedule, DateTime scheduleStart, 
            DateTime rangeStart, DateTime rangeEnd, DateTime? scheduleEndDate)
        {
            var validDates = new List<DateTime>();

            // Get pattern from frequency (day = number of days, dayType = 0 for Off, 1 for On)
            var pattern = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value > 0 && f.DayType.HasValue)
                .OrderBy(f => f.Id) // Maintain order as entered by user
                .ToList();

            if (pattern == null || pattern.Count == 0)
                return validDates; // No pattern defined

            // Calculate total days in pattern
            var totalPatternDays = pattern.Sum(p => p.Day.Value);
            var currentDate = scheduleStart;

            // Fast-forward to range start if needed
            if (currentDate < rangeStart)
            {
                var daysDiff = (rangeStart - currentDate).Days;
                var fullCycles = daysDiff / totalPatternDays;
                currentDate = currentDate.AddDays(fullCycles * totalPatternDays);
            }

            // Generate occurrences
            while (currentDate <= rangeEnd)
            {
                if (scheduleEndDate.HasValue && currentDate > scheduleEndDate.Value)
                    break;

                // Calculate position in pattern
                var daysSinceStart = (currentDate - scheduleStart).Days;
                var positionInPattern = daysSinceStart % totalPatternDays;

                // Find which segment of pattern we're in
                var accumulatedDays = 0;
                foreach (var segment in pattern)
                {
                    var segmentStart = accumulatedDays;
                    var segmentEnd = accumulatedDays + segment.Day.Value - 1;

                    if (positionInPattern >= segmentStart && positionInPattern <= segmentEnd)
                    {
                        // Check if this segment is "On" (dayType = 1)
                        if (segment.DayType.Value == (int)DayType.On && currentDate >= rangeStart)
                        {
                            validDates.Add(currentDate);
                        }
                        break;
                    }

                    accumulatedDays += segment.Day.Value;
                }

                currentDate = currentDate.AddDays(1);
            }

            return validDates;
        }

        /// <summary>
        /// Checks if a specific date is valid for the given schedule
        /// </summary>
        public bool IsDateValid(ScheduleResponse schedule, DateTime date)
        {
            var validDates = EvaluateSchedule(schedule, date.Date, date.Date);
            return validDates.Any();
        }

        /// <summary>
        /// Gets the next valid occurrence after a given date
        /// </summary>
        public DateTime? GetNextOccurrence(ScheduleResponse schedule, DateTime afterDate)
        {
            // Look ahead up to 2 years
            var lookAheadDate = afterDate.AddYears(2);
            var validDates = EvaluateSchedule(schedule, afterDate.AddDays(1), lookAheadDate);
            return validDates.FirstOrDefault();
        }

        /// <summary>
        /// Gets the previous valid occurrence before a given date
        /// </summary>
        public DateTime? GetPreviousOccurrence(ScheduleResponse schedule, DateTime beforeDate)
        {
            // Look back up to 2 years
            var lookBackDate = beforeDate.AddYears(-2);
            var validDates = EvaluateSchedule(schedule, lookBackDate, beforeDate.AddDays(-1));
            return validDates.LastOrDefault();
        }
    }
}

