using Microsoft.AspNetCore.Mvc;
using System.Text;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Services;

namespace TimeManagement.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestScheduleController : ControllerBase
    {
        private readonly ScheduleEvaluator _evaluator;

        public TestScheduleController(ScheduleEvaluator evaluator)
        {
            _evaluator = evaluator;
        }

        /// <summary>
        /// Test all schedule types - Returns HTML output
        /// </summary>
        [HttpGet("test-all")]
        public IActionResult TestAll()
        {
            var output = new StringBuilder();
            output.AppendLine("<html><head><style>");
            output.AppendLine("body { font-family: 'Courier New', monospace; background: #1e1e1e; color: #d4d4d4; padding: 20px; }");
            output.AppendLine(".pass { color: #4ec9b0; }");
            output.AppendLine(".fail { color: #f48771; }");
            output.AppendLine("h2 { color: #569cd6; border-bottom: 2px solid #569cd6; }");
            output.AppendLine("pre { background: #252526; padding: 10px; border-left: 3px solid #007acc; }");
            output.AppendLine("</style></head><body>");
            output.AppendLine("<h1>Schedule Evaluator Test Results</h1>");

            // Example 1: DoesNotRepeat
            output.AppendLine(Example1_DoesNotRepeat());

            // Example 2: Daily Every Day
            output.AppendLine(Example2_DailyEveryDay());

            // Example 3: Daily Every 3 Days
            output.AppendLine(Example3_DailyEvery3Days());

            // Example 4: Weekly Mon/Wed/Fri
            output.AppendLine(Example4_WeeklyMWF());

            // Example 5: Weekly Biweekly Thursday
            output.AppendLine(Example5_WeeklyBiweeklyThursday());

            // Example 6: Monthly 1st and 15th
            output.AppendLine(Example6_Monthly1stAnd15th());

            // Example 7: Monthly Quarterly
            output.AppendLine(Example7_MonthlyQuarterly());

            // Example 8: Days On/Off Simple
            output.AppendLine(Example8_DaysOnOff_3On2Off());

            // Example 9: Days On/Off Complex
            output.AppendLine(Example9_DaysOnOff_Complex());

            output.AppendLine("</body></html>");

            return Content(output.ToString(), "text/html");
        }

        private string Example1_DoesNotRepeat()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                Id = 1,
                StartFrom = new DateTime(2024, 11, 15),
                ScheduleType = (int)ScheduleType.DoesNotRepeat,
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(17),
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 1: DoesNotRepeat</h2>");
            sb.AppendLine($"<pre>Start Date: {schedule.StartFrom:yyyy-MM-dd}");
            sb.AppendLine("Schedule Type: DoesNotRepeat</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 15), true, "Exact start date");
            TestDate(sb, schedule, new DateTime(2024, 11, 14), false, "Day before");
            TestDate(sb, schedule, new DateTime(2024, 11, 16), false, "Day after");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example2_DailyEveryDay()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1,
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 2: Daily - Every Day</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}, Repeat Every: {schedule.RepeatEvery} day(s)</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 1), true, "Start date");
            TestDate(sb, schedule, new DateTime(2024, 11, 2), true, "Next day");
            TestDate(sb, schedule, new DateTime(2024, 11, 15), true, "Two weeks later");
            TestDate(sb, schedule, new DateTime(2024, 10, 31), false, "Before start");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example3_DailyEvery3Days()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 3,
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 3: Daily - Every 3 Days</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}, Repeat Every: {schedule.RepeatEvery} days</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 1), true, "Day 0");
            TestDate(sb, schedule, new DateTime(2024, 11, 2), false, "Day 1");
            TestDate(sb, schedule, new DateTime(2024, 11, 3), false, "Day 2");
            TestDate(sb, schedule, new DateTime(2024, 11, 4), true, "Day 3");
            TestDate(sb, schedule, new DateTime(2024, 11, 7), true, "Day 6");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example4_WeeklyMWF()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1), // Friday
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 1,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1 }, // Monday
                    new ScheduleFrequencyResponse { Day = 3 }, // Wednesday
                    new ScheduleFrequencyResponse { Day = 5 }  // Friday
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 4: Weekly - Mon, Wed, Fri</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd} (Friday)");
            sb.AppendLine("Days: Monday, Wednesday, Friday</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 1), true, "Nov 1 (Fri)");
            TestDate(sb, schedule, new DateTime(2024, 11, 4), true, "Nov 4 (Mon)");
            TestDate(sb, schedule, new DateTime(2024, 11, 5), false, "Nov 5 (Tue)");
            TestDate(sb, schedule, new DateTime(2024, 11, 6), true, "Nov 6 (Wed)");
            TestDate(sb, schedule, new DateTime(2024, 11, 8), true, "Nov 8 (Fri)");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example5_WeeklyBiweeklyThursday()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 7), // Thursday
                ScheduleType = (int)ScheduleType.Weekly,
                RepeatEvery = 2,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 4 } // Thursday
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 5: Weekly - Thursday Every 2 Weeks</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd} (Thursday)");
            sb.AppendLine("Repeat Every: 2 weeks, Day: Thursday</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 7), true, "Nov 7 (Thu) Week 0");
            TestDate(sb, schedule, new DateTime(2024, 11, 14), false, "Nov 14 (Thu) Week 1");
            TestDate(sb, schedule, new DateTime(2024, 11, 21), true, "Nov 21 (Thu) Week 2");
            TestDate(sb, schedule, new DateTime(2024, 11, 28), false, "Nov 28 (Thu) Week 3");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example6_Monthly1stAnd15th()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 1,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 1 },
                    new ScheduleFrequencyResponse { Day = 15 }
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 6: Monthly - 1st and 15th</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}");
            sb.AppendLine("Days: 1st and 15th every month</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 1), true, "Nov 1");
            TestDate(sb, schedule, new DateTime(2024, 11, 15), true, "Nov 15");
            TestDate(sb, schedule, new DateTime(2024, 11, 16), false, "Nov 16");
            TestDate(sb, schedule, new DateTime(2024, 12, 1), true, "Dec 1");
            TestDate(sb, schedule, new DateTime(2024, 12, 15), true, "Dec 15");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example7_MonthlyQuarterly()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 1, 10),
                ScheduleType = (int)ScheduleType.Monthly,
                RepeatEvery = 3,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Day = 10 }
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 7: Monthly - Every 3 Months</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}");
            sb.AppendLine("Day: 10th, Repeat Every: 3 months</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 1, 10), true, "Jan 10 (Month 0)");
            TestDate(sb, schedule, new DateTime(2024, 2, 10), false, "Feb 10 (Month 1)");
            TestDate(sb, schedule, new DateTime(2024, 4, 10), true, "Apr 10 (Month 3)");
            TestDate(sb, schedule, new DateTime(2024, 7, 10), true, "Jul 10 (Month 6)");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example8_DaysOnOff_3On2Off()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.DaysOnOff,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Id = 1, Day = 3, DayType = (int)DayType.On },
                    new ScheduleFrequencyResponse { Id = 2, Day = 2, DayType = (int)DayType.Off }
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 8: Days On/Off - 3 On, 2 Off</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}");
            sb.AppendLine("Pattern: 3 days ON, 2 days OFF (repeats every 5 days)</pre>");

            sb.AppendLine("<pre>");
            TestDate(sb, schedule, new DateTime(2024, 11, 1), true, "Day 0 (ON)");
            TestDate(sb, schedule, new DateTime(2024, 11, 2), true, "Day 1 (ON)");
            TestDate(sb, schedule, new DateTime(2024, 11, 3), true, "Day 2 (ON)");
            TestDate(sb, schedule, new DateTime(2024, 11, 4), false, "Day 3 (OFF)");
            TestDate(sb, schedule, new DateTime(2024, 11, 5), false, "Day 4 (OFF)");
            TestDate(sb, schedule, new DateTime(2024, 11, 6), true, "Day 5 (ON)");
            TestDate(sb, schedule, new DateTime(2024, 11, 7), true, "Day 6 (ON)");
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private string Example9_DaysOnOff_Complex()
        {
            var sb = new StringBuilder();
            var schedule = new ScheduleResponse
            {
                StartFrom = new DateTime(2024, 11, 1),
                ScheduleType = (int)ScheduleType.DaysOnOff,
                Frequency = new List<ScheduleFrequencyResponse>
                {
                    new ScheduleFrequencyResponse { Id = 1, Day = 2, DayType = (int)DayType.On },
                    new ScheduleFrequencyResponse { Id = 2, Day = 1, DayType = (int)DayType.Off },
                    new ScheduleFrequencyResponse { Id = 3, Day = 4, DayType = (int)DayType.On },
                    new ScheduleFrequencyResponse { Id = 4, Day = 2, DayType = (int)DayType.Off }
                },
                IsActive = true,
                EndType = "Never"
            };

            sb.AppendLine("<h2>Example 9: Days On/Off - Complex Pattern</h2>");
            sb.AppendLine($"<pre>Start: {schedule.StartFrom:yyyy-MM-dd}");
            sb.AppendLine("Pattern: 2 ON, 1 OFF, 4 ON, 2 OFF (9 day cycle)</pre>");

            sb.AppendLine("<pre>");
            for (int i = 0; i < 15; i++)
            {
                var date = new DateTime(2024, 11, 1).AddDays(i);
                var expected = i switch
                {
                    0 or 1 or 3 or 4 or 5 or 6 or 9 or 10 or 12 or 13 or 14 => true,
                    _ => false
                };
                TestDate(sb, schedule, date, expected, $"Day {i}");
            }
            sb.AppendLine("</pre>");

            return sb.ToString();
        }

        private void TestDate(StringBuilder sb, ScheduleResponse schedule, DateTime date, bool expectedResult, string description)
        {
            var result = _evaluator.IsDateValid(schedule, date);
            var status = result == expectedResult ? "✓ PASS" : "✗ FAIL";
            var cssClass = result == expectedResult ? "pass" : "fail";
            var resultText = result ? "VALID  " : "INVALID";

            sb.AppendLine($"<span class='{cssClass}'>{status}</span> | {date:yyyy-MM-dd (ddd)} | {resultText} | {description}");
        }
    }
}










































