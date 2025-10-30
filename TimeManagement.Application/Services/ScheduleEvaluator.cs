using System;
using System.Collections.Generic;
using System.Linq;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services
{
    /// <summary>
    /// Simple schedule evaluator - checks if a given date is valid for a schedule
    /// </summary>
    public class ScheduleEvaluator
    {
        /// <summary>
        /// Check if a specific date is valid for the given schedule
        /// StartTime and EndTime from ScheduleResponse define the shift times
        /// </summary>
        /// <param name="schedule">The schedule to evaluate</param>
        /// <param name="date">The date to check</param>
        /// <returns>True if the date is valid for this schedule</returns>
        public bool IsDateValid(ScheduleResponse schedule, DateTime date)
        {
            if (schedule == null || !schedule.IsActive.GetValueOrDefault(true))
                return false;

            if (!schedule.StartFrom.HasValue)
                return false;

            var checkDate = date.Date;
            var startDate = schedule.StartFrom.Value.Date;

            // Date must be on or after schedule start
            if (checkDate < startDate)
                return false;

            // Check if schedule has ended
            var endDate = GetScheduleEndDate(schedule);
            if (endDate.HasValue && checkDate > endDate.Value)
                return false;

            // Check max occurrences if specified
            if (!string.IsNullOrEmpty(schedule.EndType) && 
                schedule.EndType.ToLower() == "afteroccurrences" && 
                schedule.MaxOccurrences.HasValue)
            {
                var occurrenceCount = CountOccurrencesUntilDate(schedule, checkDate);
                if (occurrenceCount > schedule.MaxOccurrences.Value)
                    return false;
            }

            // Evaluate based on schedule type
            var scheduleType = schedule.ScheduleType.HasValue 
                ? (ScheduleType)schedule.ScheduleType.Value 
                : ScheduleType.DoesNotRepeat;

            return scheduleType switch
            {
                ScheduleType.DoesNotRepeat => checkDate == startDate,
                ScheduleType.Daily => IsValidDaily(schedule, checkDate, startDate),
                ScheduleType.Weekly => IsValidWeekly(schedule, checkDate, startDate),
                ScheduleType.Monthly => IsValidMonthly(schedule, checkDate, startDate),
                ScheduleType.DaysOnOff => IsValidDaysOnOff(schedule, checkDate, startDate),
                _ => false
            };
        }

        private DateTime? GetScheduleEndDate(ScheduleResponse schedule)
        {
            if (string.IsNullOrEmpty(schedule.EndType))
                return null;

            var endType = schedule.EndType.ToLower();
            
            if (endType == "ondate" || endType == "2")
                return schedule.ValidUntil?.Date;
            
            return null; // Never or AfterOccurrences handled separately
        }

        private bool IsValidDaily(ScheduleResponse schedule, DateTime checkDate, DateTime startDate)
        {
            var repeatEvery = schedule.RepeatEvery ?? 1;
            if (repeatEvery < 1) repeatEvery = 1;

            var daysSinceStart = (checkDate - startDate).Days;
            return daysSinceStart % repeatEvery == 0;
        }

        private bool IsValidWeekly(ScheduleResponse schedule, DateTime checkDate, DateTime startDate)
        {
            var repeatEvery = schedule.RepeatEvery ?? 1;
            if (repeatEvery < 1) repeatEvery = 1;

            // Get selected days of week (0=Sunday, 6=Saturday)
            var selectedDays = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value >= 0 && f.Day.Value <= 6)
                .Select(f => f.Day.Value)
                .ToList() ?? new List<int>();

            if (selectedDays.Count == 0)
                return false;

            // Check if this day of week is selected
            var dayOfWeek = (int)checkDate.DayOfWeek;
            if (!selectedDays.Contains(dayOfWeek))
                return false;

            // If repeat every week, any selected weekday is valid
            if (repeatEvery == 1)
                return true;

            // For repeatEvery > 1, calculate week cycle from start of weeks
            var startOfStartWeek = startDate.AddDays(-(int)startDate.DayOfWeek); // Sunday of start week
            var startOfCheckWeek = checkDate.AddDays(-(int)checkDate.DayOfWeek); // Sunday of check week
            var weeksSinceStart = (int)((startOfCheckWeek - startOfStartWeek).TotalDays / 7);
            
            return weeksSinceStart % repeatEvery == 0;
        }

        private bool IsValidMonthly(ScheduleResponse schedule, DateTime checkDate, DateTime startDate)
        {
            var repeatEvery = schedule.RepeatEvery ?? 1;
            if (repeatEvery < 1) repeatEvery = 1;

            // Get selected days of month (1-31)
            var selectedDays = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value >= 1 && f.Day.Value <= 31)
                .Select(f => f.Day.Value)
                .ToList() ?? new List<int>();

            if (selectedDays.Count == 0)
                return false;

            // Check if this day of month is selected
            if (!selectedDays.Contains(checkDate.Day))
                return false;

            // Check if we're in the right month cycle
            var monthsSinceStart = ((checkDate.Year - startDate.Year) * 12) + (checkDate.Month - startDate.Month);
            return monthsSinceStart % repeatEvery == 0;
        }

        private bool IsValidDaysOnOff(ScheduleResponse schedule, DateTime checkDate, DateTime startDate)
        {
            var pattern = schedule.Frequency?
                .Where(f => f.Day.HasValue && f.Day.Value > 0 && f.DayType.HasValue)
                .OrderBy(f => f.Id)
                .ToList();

            if (pattern == null || pattern.Count == 0)
                return false;

            var totalPatternDays = pattern.Sum(p => p.Day.Value);
            var daysSinceStart = (checkDate - startDate).Days;
            var positionInPattern = daysSinceStart % totalPatternDays;

            var accumulatedDays = 0;
            foreach (var segment in pattern)
            {
                var segmentStart = accumulatedDays;
                var segmentEnd = accumulatedDays + segment.Day.Value - 1;

                if (positionInPattern >= segmentStart && positionInPattern <= segmentEnd)
                {
                    return segment.DayType.Value == (int)DayType.On;
                }

                accumulatedDays += segment.Day.Value;
            }

            return false;
        }

        private int CountOccurrencesUntilDate(ScheduleResponse schedule, DateTime untilDate)
        {
            if (!schedule.StartFrom.HasValue)
                return 0;

            var startDate = schedule.StartFrom.Value.Date;
            var scheduleType = schedule.ScheduleType.HasValue 
                ? (ScheduleType)schedule.ScheduleType.Value 
                : ScheduleType.DoesNotRepeat;

            if (scheduleType == ScheduleType.DoesNotRepeat)
                return untilDate >= startDate ? 1 : 0;

            if (scheduleType == ScheduleType.Daily)
            {
                var repeatEvery = schedule.RepeatEvery ?? 1;
                if (repeatEvery < 1) repeatEvery = 1;
                var daysSinceStart = (untilDate - startDate).Days;
                if (daysSinceStart < 0) return 0;
                return (daysSinceStart / repeatEvery) + 1;
            }

            // For Weekly, Monthly, DaysOnOff - count by checking each day
            // This is simpler than complex math and works for all patterns
            var count = 0;
            var currentDate = startDate;
            var maxDays = Math.Min((untilDate - startDate).Days + 1, 3650); // Max 10 years
            
            for (int i = 0; i < maxDays; i++)
            {
                // Temporarily skip the max occurrence check to avoid recursion
                if (IsDateValidInternal(schedule, currentDate))
                    count++;
                    
                currentDate = currentDate.AddDays(1);
                if (currentDate > untilDate)
                    break;
            }
            
            return count;
        }

        // Internal method that skips max occurrence check to avoid recursion
        private bool IsDateValidInternal(ScheduleResponse schedule, DateTime date)
        {
            if (schedule == null || !schedule.IsActive.GetValueOrDefault(true))
                return false;

            if (!schedule.StartFrom.HasValue)
                return false;

            var checkDate = date.Date;
            var startDate = schedule.StartFrom.Value.Date;

            if (checkDate < startDate)
                return false;

            var endDate = GetScheduleEndDate(schedule);
            if (endDate.HasValue && checkDate > endDate.Value)
                return false;

            var scheduleType = schedule.ScheduleType.HasValue 
                ? (ScheduleType)schedule.ScheduleType.Value 
                : ScheduleType.DoesNotRepeat;

            return scheduleType switch
            {
                ScheduleType.DoesNotRepeat => checkDate == startDate,
                ScheduleType.Daily => IsValidDaily(schedule, checkDate, startDate),
                ScheduleType.Weekly => IsValidWeekly(schedule, checkDate, startDate),
                ScheduleType.Monthly => IsValidMonthly(schedule, checkDate, startDate),
                ScheduleType.DaysOnOff => IsValidDaysOnOff(schedule, checkDate, startDate),
                _ => false
            };
        }
    }
}
