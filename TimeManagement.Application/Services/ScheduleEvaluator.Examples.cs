using System;
using System.Collections.Generic;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services
{
    /// <summary>
    /// Usage examples for ScheduleEvaluator
    /// </summary>
    public class ScheduleEvaluatorExamples
    {
        private readonly ScheduleEvaluator _evaluator = new ScheduleEvaluator();

        /// <summary>
        /// Example 1: Daily schedule that repeats every 2 days
        /// </summary>
        public List<DateTime> Example_DailySchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 1,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 2, // Every 2 days
                EndType = "Never",
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 11, 10);

            // Returns: Nov 1, Nov 3, Nov 5, Nov 7, Nov 9
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 2: Weekly schedule on Mon, Wed, Fri every week
        /// </summary>
        public List<DateTime> Example_WeeklySchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 2,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 1, // Every week
                EndType = "Never",
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 }, // Monday
                    new ScheduleFrequencyResponse { Day = 3, DayType = 0 }, // Wednesday
                    new ScheduleFrequencyResponse { Day = 5, DayType = 0 }  // Friday
                },
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 11, 30);

            // Returns: All Mondays, Wednesdays, and Fridays in November 2024
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 3: Monthly schedule on 1st and 15th of every month
        /// </summary>
        public List<DateTime> Example_MonthlySchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 3,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 1, // Every month
                EndType = "OnDate",
                ValidUntil = new DateTime(2025, 3, 31),
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 },  // 1st of month
                    new ScheduleFrequencyResponse { Day = 15, DayType = 0 }  // 15th of month
                },
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2025, 12, 31);

            // Returns: 1st and 15th of each month from Nov 2024 to Mar 2025
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 4: Does not repeat - single occurrence
        /// </summary>
        public List<DateTime> Example_DoesNotRepeat()
        {
            var schedule = new ScheduleResponse
            {
                Id = 4,
                StartFrom = new DateTime(2024, 11, 15),
                ScheduleType = (int)ScheduleType.DoesNotRepeat,
                EndType = "Never",
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 11, 30);

            // Returns: Only Nov 15, 2024
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 5: Days On/Off pattern - 3 days on, 2 days off, 4 days on
        /// </summary>
        public List<DateTime> Example_DaysOnOffSchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 5,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.DaysOnOff,
                EndType = "Never",
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 3, DayType = (int)DayType.On },  // 3 days ON
                    new ScheduleFrequencyResponse { Day = 2, DayType = (int)DayType.Off }, // 2 days OFF
                    new ScheduleFrequencyResponse { Day = 4, DayType = (int)DayType.On }   // 4 days ON
                },
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 11, 30);

            // Returns: Pattern repeats every 9 days (3+2+4)
            // Days ON: Nov 1-3, Nov 6-9, Nov 12-14, Nov 17-20, Nov 23-26, Nov 29-30
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 6: Schedule with max occurrences limit
        /// </summary>
        public List<DateTime> Example_MaxOccurrences()
        {
            var schedule = new ScheduleResponse
            {
                Id = 6,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1, // Every day
                EndType = "AfterOccurrences",
                MaxOccurrences = 5, // Only 5 times
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 11, 30);

            // Returns: Only first 5 days (Nov 1-5, 2024)
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 7: Check if a specific date is valid
        /// </summary>
        public bool Example_CheckSpecificDate()
        {
            var schedule = new ScheduleResponse
            {
                Id = 7,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 1,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 } // Monday only
                },
                EndType = "Never",
                IsActive = true
            };

            var dateToCheck = new DateTime(2024, 11, 4); // Monday

            // Returns: true (Nov 4, 2024 is a Monday)
            return _evaluator.IsDateValid(schedule, dateToCheck);
        }

        /// <summary>
        /// Example 8: Get next occurrence after a date
        /// </summary>
        public DateTime? Example_GetNextOccurrence()
        {
            var schedule = new ScheduleResponse
            {
                Id = 8,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 3, // Every 3 days
                EndType = "Never",
                IsActive = true
            };

            var afterDate = new DateTime(2024, 11, 5);

            // Returns: Nov 7, 2024 (next occurrence after Nov 5)
            return _evaluator.GetNextOccurrence(schedule, afterDate);
        }

        /// <summary>
        /// Example 9: Biweekly schedule (every 2 weeks)
        /// </summary>
        public List<DateTime> Example_BiweeklySchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 9,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 2, // Every 2 weeks
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 }, // Monday
                    new ScheduleFrequencyResponse { Day = 3, DayType = 0 }  // Wednesday
                },
                EndType = "Never",
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 11, 1);
            var rangeEnd = new DateTime(2024, 12, 31);

            // Returns: Mon & Wed on weeks starting Nov 3, Nov 17, Dec 1, Dec 15, Dec 29
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }

        /// <summary>
        /// Example 10: Quarterly schedule (every 3 months on 1st)
        /// </summary>
        public List<DateTime> Example_QuarterlySchedule()
        {
            var schedule = new ScheduleResponse
            {
                Id = 10,
                StartFrom = new DateTime(2024, 1, 1),
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 3, // Every 3 months
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 } // 1st of month
                },
                EndType = "Never",
                IsActive = true
            };

            var rangeStart = new DateTime(2024, 1, 1);
            var rangeEnd = new DateTime(2024, 12, 31);

            // Returns: Jan 1, Apr 1, Jul 1, Oct 1, 2024
            return _evaluator.EvaluateSchedule(schedule, rangeStart, rangeEnd);
        }
    }
}

