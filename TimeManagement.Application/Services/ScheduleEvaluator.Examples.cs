using System;
using System.Collections.Generic;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services
{
    /// <summary>
    /// Examples demonstrating how ScheduleEvaluator works for all schedule types
    /// </summary>
    public class ScheduleEvaluatorExamples
    {
        private readonly ScheduleEvaluator _evaluator = new ScheduleEvaluator();

        #region Example 1: DoesNotRepeat Schedule
        /// <summary>
        /// Example 1: DoesNotRepeat - Single occurrence on a specific date
        /// </summary>
        public void Example1_DoesNotRepeat()
        {
            var schedule = new ScheduleResponse
            {
                Id = 1,
                SourceType = (int)ScheduleSourceTypes.Shift,
                SourceId = 1,
                StartFrom = new DateTime(2024, 11, 15), // Nov 15, 2024
                ScheduleType = (int)ScheduleType.DoesNotRepeat,
                StartTime = TimeSpan.FromHours(8), // 8:00 AM
                EndTime = TimeSpan.FromHours(17), // 5:00 PM
                IsActive = true,
                EndType = "Never"
            };

            // Test Cases
            Console.WriteLine("=== Example 1: DoesNotRepeat ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Schedule Type: DoesNotRepeat");
            Console.WriteLine();

            // Should be TRUE - exact date
            TestDate(schedule, new DateTime(2024, 11, 15), true, "Exact start date");

            // Should be FALSE - day before
            TestDate(schedule, new DateTime(2024, 11, 14), false, "Day before start");

            // Should be FALSE - day after
            TestDate(schedule, new DateTime(2024, 11, 16), false, "Day after start");

            // Should be FALSE - one week later
            TestDate(schedule, new DateTime(2024, 11, 22), false, "One week later");

            Console.WriteLine();
        }
        #endregion

        #region Example 2: Daily Schedule - Every Day
        /// <summary>
        /// Example 2: Daily schedule that repeats every day
        /// </summary>
        public void Example2_DailyEveryDay()
        {
            var schedule = new ScheduleResponse
            {
                Id = 2,
                StartFrom = new DateTime(2024, 11, 1), // Nov 1, 2024
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1, // Every day
                StartTime = TimeSpan.FromHours(9),
                EndTime = TimeSpan.FromHours(18),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 2: Daily - Every Day ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} day(s)");
            Console.WriteLine();

            // Should be TRUE - start date
            TestDate(schedule, new DateTime(2024, 11, 1), true, "Start date");

            // Should be TRUE - next day
            TestDate(schedule, new DateTime(2024, 11, 2), true, "Next day");

            // Should be TRUE - any day after start
            TestDate(schedule, new DateTime(2024, 11, 15), true, "Two weeks later");

            // Should be TRUE - one month later
            TestDate(schedule, new DateTime(2024, 12, 1), true, "One month later");

            // Should be FALSE - before start
            TestDate(schedule, new DateTime(2024, 10, 31), false, "Day before start");

            Console.WriteLine();
        }
        #endregion

        #region Example 3: Daily Schedule - Every 3 Days
        /// <summary>
        /// Example 3: Daily schedule that repeats every 3 days
        /// </summary>
        public void Example3_DailyEvery3Days()
        {
            var schedule = new ScheduleResponse
            {
                Id = 3,
                StartFrom = new DateTime(2024, 11, 1), // Nov 1, 2024 (Friday)
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 3, // Every 3 days
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(16),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 3: Daily - Every 3 Days ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} days");
            Console.WriteLine();

            // Should be TRUE - start date (Day 0)
            TestDate(schedule, new DateTime(2024, 11, 1), true, "Day 0 (Start)");

            // Should be FALSE - Day 1
            TestDate(schedule, new DateTime(2024, 11, 2), false, "Day 1");

            // Should be FALSE - Day 2
            TestDate(schedule, new DateTime(2024, 11, 3), false, "Day 2");

            // Should be TRUE - Day 3
            TestDate(schedule, new DateTime(2024, 11, 4), true, "Day 3");

            // Should be FALSE - Day 4
            TestDate(schedule, new DateTime(2024, 11, 5), false, "Day 4");

            // Should be TRUE - Day 6
            TestDate(schedule, new DateTime(2024, 11, 7), true, "Day 6");

            Console.WriteLine();
        }
        #endregion

        #region Example 4: Weekly Schedule - Monday, Wednesday, Friday Every Week
        /// <summary>
        /// Example 4: Weekly schedule on Mon, Wed, Fri every week
        /// </summary>
        public void Example4_WeeklyMWF()
        {
            var schedule = new ScheduleResponse
            {
                Id = 4,
                StartFrom = new DateTime(2024, 11, 1), // Nov 1, 2024 (Friday)
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 1, // Every week
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 }, // Monday
                    new ScheduleFrequencyResponse { Day = 3, DayType = 0 }, // Wednesday
                    new ScheduleFrequencyResponse { Day = 5, DayType = 0 }  // Friday
                },
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 4: Weekly - Mon, Wed, Fri Every Week ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd} (Friday)");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} week(s)");
            Console.WriteLine("Days: Monday, Wednesday, Friday");
            Console.WriteLine();

            // Week 1
            TestDate(schedule, new DateTime(2024, 11, 1), true, "Nov 1 (Fri) - Week 1");
            TestDate(schedule, new DateTime(2024, 11, 2), false, "Nov 2 (Sat) - Week 1");
            TestDate(schedule, new DateTime(2024, 11, 3), false, "Nov 3 (Sun) - Week 1");
            TestDate(schedule, new DateTime(2024, 11, 4), true, "Nov 4 (Mon) - Week 2");
            TestDate(schedule, new DateTime(2024, 11, 5), false, "Nov 5 (Tue) - Week 2");
            TestDate(schedule, new DateTime(2024, 11, 6), true, "Nov 6 (Wed) - Week 2");
            TestDate(schedule, new DateTime(2024, 11, 7), false, "Nov 7 (Thu) - Week 2");
            TestDate(schedule, new DateTime(2024, 11, 8), true, "Nov 8 (Fri) - Week 2");

            Console.WriteLine();
        }
        #endregion

        #region Example 5: Weekly Schedule - Thursday Every 2 Weeks
        /// <summary>
        /// Example 5: Weekly schedule on Thursday every 2 weeks (Bi-weekly)
        /// </summary>
        public void Example5_WeeklyBiweeklyThursday()
        {
            var schedule = new ScheduleResponse
            {
                Id = 5,
                StartFrom = new DateTime(2024, 11, 7), // Nov 7, 2024 (Thursday)
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 2, // Every 2 weeks
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 4, DayType = 0 } // Thursday
                },
                StartTime = TimeSpan.FromHours(9),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 5: Weekly - Thursday Every 2 Weeks ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd} (Thursday)");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} weeks");
            Console.WriteLine("Days: Thursday");
            Console.WriteLine();

            // Should be TRUE - start date (Week 0, Thursday)
            TestDate(schedule, new DateTime(2024, 11, 7), true, "Nov 7 (Thu) - Week 0");

            // Should be FALSE - next Thursday (Week 1)
            TestDate(schedule, new DateTime(2024, 11, 14), false, "Nov 14 (Thu) - Week 1");

            // Should be TRUE - Thursday in Week 2
            TestDate(schedule, new DateTime(2024, 11, 21), true, "Nov 21 (Thu) - Week 2");

            // Should be FALSE - Thursday in Week 3
            TestDate(schedule, new DateTime(2024, 11, 28), false, "Nov 28 (Thu) - Week 3");

            // Should be TRUE - Thursday in Week 4
            TestDate(schedule, new DateTime(2024, 12, 5), true, "Dec 5 (Thu) - Week 4");

            // Should be FALSE - Wednesday (not selected day)
            TestDate(schedule, new DateTime(2024, 11, 20), false, "Nov 20 (Wed) - Wrong day");

            Console.WriteLine();
        }
        #endregion

        #region Example 6: Monthly Schedule - 1st and 15th Every Month
        /// <summary>
        /// Example 6: Monthly schedule on 1st and 15th of every month
        /// </summary>
        public void Example6_Monthly1stAnd15th()
        {
            var schedule = new ScheduleResponse
            {
                Id = 6,
                StartFrom = new DateTime(2024, 11, 1), // Nov 1, 2024
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 1, // Every month
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1, DayType = 0 },  // 1st of month
                    new ScheduleFrequencyResponse { Day = 15, DayType = 0 }  // 15th of month
                },
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 6: Monthly - 1st and 15th Every Month ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} month(s)");
            Console.WriteLine("Days: 1st and 15th");
            Console.WriteLine();

            // Should be TRUE - 1st of start month
            TestDate(schedule, new DateTime(2024, 11, 1), true, "Nov 1");

            // Should be FALSE - 2nd
            TestDate(schedule, new DateTime(2024, 11, 2), false, "Nov 2");

            // Should be TRUE - 15th of start month
            TestDate(schedule, new DateTime(2024, 11, 15), true, "Nov 15");

            // Should be FALSE - 16th
            TestDate(schedule, new DateTime(2024, 11, 16), false, "Nov 16");

            // Should be TRUE - 1st of next month
            TestDate(schedule, new DateTime(2024, 12, 1), true, "Dec 1");

            // Should be TRUE - 15th of next month
            TestDate(schedule, new DateTime(2024, 12, 15), true, "Dec 15");

            Console.WriteLine();
        }
        #endregion

        #region Example 7: Monthly Schedule - 10th Every 3 Months
        /// <summary>
        /// Example 7: Monthly schedule on 10th day every 3 months (Quarterly)
        /// </summary>
        public void Example7_MonthlyQuarterly()
        {
            var schedule = new ScheduleResponse
            {
                Id = 7,
                StartFrom = new DateTime(2024, 1, 10), // Jan 10, 2024
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 3, // Every 3 months
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 10, DayType = 0 } // 10th
                },
                StartTime = TimeSpan.FromHours(9),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 7: Monthly - 10th Every 3 Months ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Repeat Every: {schedule.RepeatEvery} months");
            Console.WriteLine("Days: 10th");
            Console.WriteLine();

            // Should be TRUE - start month (Month 0)
            TestDate(schedule, new DateTime(2024, 1, 10), true, "Jan 10 (Month 0)");

            // Should be FALSE - Month 1
            TestDate(schedule, new DateTime(2024, 2, 10), false, "Feb 10 (Month 1)");

            // Should be FALSE - Month 2
            TestDate(schedule, new DateTime(2024, 3, 10), false, "Mar 10 (Month 2)");

            // Should be TRUE - Month 3
            TestDate(schedule, new DateTime(2024, 4, 10), true, "Apr 10 (Month 3)");

            // Should be FALSE - Month 4
            TestDate(schedule, new DateTime(2024, 5, 10), false, "May 10 (Month 4)");

            // Should be TRUE - Month 6
            TestDate(schedule, new DateTime(2024, 7, 10), true, "Jul 10 (Month 6)");

            // Should be FALSE - wrong day
            TestDate(schedule, new DateTime(2024, 4, 11), false, "Apr 11 (Wrong day)");

            Console.WriteLine();
        }
        #endregion

        #region Example 8: Days On/Off - 3 On, 2 Off Pattern
        /// <summary>
        /// Example 8: Days On/Off pattern - 3 days on, 2 days off
        /// </summary>
        public void Example8_DaysOnOff_3On2Off()
        {
            var schedule = new ScheduleResponse
            {
                Id = 8,
                StartFrom = new DateTime(2024, 11, 1), // Nov 1, 2024
                ScheduleType = (int)ScheduleType.DaysOnOff,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Id = 1, Day = 3, DayType = (int)DayType.On },  // 3 days ON
                    new ScheduleFrequencyResponse { Id = 2, Day = 2, DayType = (int)DayType.Off }  // 2 days OFF
                },
                StartTime = TimeSpan.FromHours(7),
                EndTime = TimeSpan.FromHours(19),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 8: Days On/Off - 3 On, 2 Off ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine("Pattern: 3 days ON, 2 days OFF (repeats every 5 days)");
            Console.WriteLine();

            // Pattern repeats every 5 days
            // Days 0-2: ON, Days 3-4: OFF, Days 5-7: ON, Days 8-9: OFF, etc.

            TestDate(schedule, new DateTime(2024, 11, 1), true, "Nov 1 - Day 0 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 2), true, "Nov 2 - Day 1 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 3), true, "Nov 3 - Day 2 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 4), false, "Nov 4 - Day 3 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 5), false, "Nov 5 - Day 4 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 6), true, "Nov 6 - Day 5 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 7), true, "Nov 7 - Day 6 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 8), true, "Nov 8 - Day 7 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 9), false, "Nov 9 - Day 8 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 10), false, "Nov 10 - Day 9 (OFF)");

            Console.WriteLine();
        }
        #endregion

        #region Example 9: Days On/Off - Complex Pattern
        /// <summary>
        /// Example 9: Days On/Off - Complex pattern (2 on, 1 off, 4 on, 2 off)
        /// </summary>
        public void Example9_DaysOnOff_Complex()
        {
            var schedule = new ScheduleResponse
            {
                Id = 9,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.DaysOnOff,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Id = 1, Day = 2, DayType = (int)DayType.On },  // 2 days ON
                    new ScheduleFrequencyResponse { Id = 2, Day = 1, DayType = (int)DayType.Off }, // 1 day OFF
                    new ScheduleFrequencyResponse { Id = 3, Day = 4, DayType = (int)DayType.On },  // 4 days ON
                    new ScheduleFrequencyResponse { Id = 4, Day = 2, DayType = (int)DayType.Off }  // 2 days OFF
                },
                StartTime = TimeSpan.FromHours(6),
                EndTime = TimeSpan.FromHours(18),
                IsActive = true,
                EndType = "Never"
            };

            Console.WriteLine("=== Example 9: Days On/Off - Complex Pattern ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine("Pattern: 2 ON, 1 OFF, 4 ON, 2 OFF (repeats every 9 days)");
            Console.WriteLine();

            // Pattern: Days 0-1: ON, Day 2: OFF, Days 3-6: ON, Days 7-8: OFF
            TestDate(schedule, new DateTime(2024, 11, 1), true, "Day 0 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 2), true, "Day 1 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 3), false, "Day 2 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 4), true, "Day 3 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 5), true, "Day 4 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 6), true, "Day 5 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 7), true, "Day 6 (ON)");
            TestDate(schedule, new DateTime(2024, 11, 8), false, "Day 7 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 9), false, "Day 8 (OFF)");
            TestDate(schedule, new DateTime(2024, 11, 10), true, "Day 9 (Cycle repeats - ON)");

            Console.WriteLine();
        }
        #endregion

        #region Example 10: Schedule with End Date
        /// <summary>
        /// Example 10: Daily schedule with specific end date
        /// </summary>
        public void Example10_WithEndDate()
        {
            var schedule = new ScheduleResponse
            {
                Id = 10,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1,
                EndType = "OnDate",
                ValidUntil = new DateTimeOffset(new DateTime(2024, 11, 10)),
                StartTime = TimeSpan.FromHours(9),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true
            };

            Console.WriteLine("=== Example 10: Daily with End Date ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"End Date: {schedule.ValidUntil:yyyy-MM-dd}");
            Console.WriteLine();

            TestDate(schedule, new DateTime(2024, 11, 1), true, "Nov 1 (Start)");
            TestDate(schedule, new DateTime(2024, 11, 5), true, "Nov 5 (During)");
            TestDate(schedule, new DateTime(2024, 11, 10), true, "Nov 10 (End)");
            TestDate(schedule, new DateTime(2024, 11, 11), false, "Nov 11 (After end)");

            Console.WriteLine();
        }
        #endregion

        #region Example 11: Schedule with Max Occurrences
        /// <summary>
        /// Example 11: Daily schedule with max 5 occurrences
        /// </summary>
        public void Example11_WithMaxOccurrences()
        {
            var schedule = new ScheduleResponse
            {
                Id = 11,
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1,
                EndType = "AfterOccurrences",
                MaxOccurrences = 5,
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(16),
                IsActive = true
            };

            Console.WriteLine("=== Example 11: Daily with Max 5 Occurrences ===");
            Console.WriteLine($"Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            Console.WriteLine($"Max Occurrences: {schedule.MaxOccurrences}");
            Console.WriteLine();

            TestDate(schedule, new DateTime(2024, 11, 1), true, "Occurrence 1");
            TestDate(schedule, new DateTime(2024, 11, 2), true, "Occurrence 2");
            TestDate(schedule, new DateTime(2024, 11, 3), true, "Occurrence 3");
            TestDate(schedule, new DateTime(2024, 11, 4), true, "Occurrence 4");
            TestDate(schedule, new DateTime(2024, 11, 5), true, "Occurrence 5");
            TestDate(schedule, new DateTime(2024, 11, 6), false, "After max occurrences");

            Console.WriteLine();
        }
        #endregion

        #region Helper Methods
        private void TestDate(ScheduleResponse schedule, DateTime date, bool expectedResult, string description)
        {
            var result = _evaluator.IsDateValid(schedule, date);
            var status = result == expectedResult ? "✓ PASS" : "✗ FAIL";
            var resultText = result ? "VALID" : "INVALID";
            
            Console.WriteLine($"{status} | {date:yyyy-MM-dd (ddd)} | {resultText,-7} | {description}");
            
            if (result != expectedResult)
            {
                Console.WriteLine($"       Expected: {expectedResult}, Got: {result}");
            }
        }

        /// <summary>
        /// Run all examples
        /// </summary>
        public void RunAllExamples()
        {
            Example1_DoesNotRepeat();
            Example2_DailyEveryDay();
            Example3_DailyEvery3Days();
            Example4_WeeklyMWF();
            Example5_WeeklyBiweeklyThursday();
            Example6_Monthly1stAnd15th();
            Example7_MonthlyQuarterly();
            Example8_DaysOnOff_3On2Off();
            Example9_DaysOnOff_Complex();
            Example10_WithEndDate();
            Example11_WithMaxOccurrences();

            Console.WriteLine("=== All Examples Complete ===");
        }
        #endregion
    }
}

