using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services;

/// <summary>
/// Provides demonstration scenarios for <see cref="ShiftAssignmentConflictService"/>.
/// </summary>
public class ShiftAssignmentConflictExamples
{
    private readonly ShiftAssignmentConflictService _conflictService;

    public ShiftAssignmentConflictExamples(ShiftAssignmentConflictService conflictService)
    {
        _conflictService = conflictService;
    }

    /// <summary>
    /// Runs all predefined examples and returns their evaluated results.
    /// </summary>
    public IReadOnlyList<ShiftAssignmentConflictExampleResult> RunAll()
    {
        return new List<ShiftAssignmentConflictExampleResult>
        {
            RunExample(
                "Daily overlap on same shift",
                "Existing assignment is 09:00-17:00 every day. New request is 13:00-21:00 on the same pattern. Should conflict.",
                expectConflict: true,
                BuildDailyOverlap),
            RunExample(
                "Daily non-overlap (split shift)",
                "Existing assignment is 06:00-12:00 every day. New request is 13:00-21:00, leaving a gap. Should not conflict.",
                expectConflict: false,
                BuildDailyNonOverlap),
            RunExample(
                "Cross-midnight collision",
                "Existing assignment spans 20:00-02:00. New request starts 01:00-05:00 the next day. Overnight carry should conflict.",
                expectConflict: true,
                BuildCrossMidnightConflict),
            RunExample(
                "Weekly schedule different days",
                "Existing assignment is Mondays; new request is Tuesdays. Patterns do not intersect. Should not conflict.",
                expectConflict: false,
                BuildWeeklyDifferentDays),
            RunExample(
                "Limited occurrences overlap",
                "New request repeats daily but ends after 3 occurrences. Existing assignment overlaps within that window. Should conflict.",
                expectConflict: true,
                BuildAfterOccurrencesOverlap),
            RunExample(
                "Five-year horizon guard",
                "Existing assignment starts six years later. Within the five-year evaluation window nothing overlaps. Should not conflict.",
                expectConflict: false,
                BuildBeyondHorizon)
        };
    }

    /// <summary>
    /// Builds an HTML report summarizing all predefined scenarios and their outcomes.
    /// </summary>
    public string BuildHtmlReport()
    {
        var results = RunAll();
        var sb = new StringBuilder();

        sb.AppendLine("<html><head><style>");
        sb.AppendLine("body { font-family: 'Segoe UI', sans-serif; background:#0f172a; color:#e2e8f0; padding:24px; }");
        sb.AppendLine("h1 { color:#38bdf8; margin-bottom:24px; }");
        sb.AppendLine(".example { background:#111c34; border-radius:8px; padding:20px; margin-bottom:20px; border-left:4px solid rgba(56,189,248,0.4); }");
        sb.AppendLine(".pass { color:#34d399; font-weight:600; }");
        sb.AppendLine(".fail { color:#f87171; font-weight:600; }");
        sb.AppendLine(".meta { font-size:0.9rem; color:#94a3b8; margin-bottom:12px; }");
        sb.AppendLine("code { background:#1e293b; color:#f8fafc; padding:2px 6px; border-radius:4px; }");
        sb.AppendLine("table { width:100%; border-collapse:collapse; margin-top:12px; }");
        sb.AppendLine("th, td { padding:8px 10px; border-bottom:1px solid #1e293b; text-align:left; font-size:0.9rem; }");
        sb.AppendLine("th { color:#38bdf8; }");
        sb.AppendLine("</style></head><body>");
        sb.AppendLine("<h1>Shift Assignment Conflict Examples</h1>");

        foreach (var result in results)
        {
            var statusMatches = result.ExpectConflict == result.HasConflict;
            var statusClass = statusMatches ? "pass" : "fail";
            var statusLabel = statusMatches ? "Expectation met" : "Expectation mismatch";
            var expectedText = result.ExpectConflict ? "Conflict expected" : "No conflict expected";
            var actualText = result.HasConflict
                ? $"Conflict detected ({result.ConflictCount})"
                : "No conflict detected";

            sb.AppendLine("<div class='example'>");
            sb.AppendLine($"<h2>{Encode(result.Title)}</h2>");
            sb.AppendLine($"<p class='meta'>{Encode(result.Description)}</p>");
            sb.AppendLine($"<p><span class='{statusClass}'>{statusLabel}</span> — expected: <code>{Encode(expectedText)}</code>, actual: <code>{Encode(actualText)}</code></p>");

            var requestSchedule = result.Request.Schedules?.FirstOrDefault();
            if (requestSchedule != null)
            {
                sb.AppendLine("<p class='meta'>");
                sb.AppendLine($"New request: start {requestSchedule.StartFrom:yyyy-MM-dd}, pattern {(ScheduleType)requestSchedule.ScheduleType}");
                if (!string.IsNullOrEmpty(requestSchedule.StartTime) && !string.IsNullOrEmpty(requestSchedule.EndTime))
                {
                    sb.AppendLine($" ({requestSchedule.StartTime} - {requestSchedule.EndTime})");
                }
                sb.AppendLine("</p>");
            }

            if (result.HasConflict && result.Conflicts.Any())
            {
                sb.AppendLine("<table>");
                sb.AppendLine("<thead><tr>");
                sb.AppendLine("<th>Date</th><th>Existing Shift</th><th>Existing Window</th><th>Requested Window</th><th>Reason</th>");
                sb.AppendLine("</tr></thead><tbody>");

                foreach (var conflict in result.Conflicts)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine($"<td>{conflict.Date:yyyy-MM-dd}</td>");
                    sb.AppendLine($"<td>{Encode(conflict.ExistingShiftName ?? $"Assignment {conflict.ExistingAssignmentId}")}</td>");
                    sb.AppendLine($"<td>{Encode(FormatWindow(conflict.ExistingWindow))}</td>");
                    sb.AppendLine($"<td>{Encode(FormatWindow(conflict.RequestedWindow))}</td>");
                    sb.AppendLine($"<td>{Encode(conflict.Reason ?? "Overlap detected")}</td>");
                    sb.AppendLine("</tr>");
                }

                sb.AppendLine("</tbody></table>");
            }
            else
            {
                sb.AppendLine("<p>This assignment is clear — no overlapping occurrences were detected.</p>");
            }

            sb.AppendLine("</div>");
        }

        sb.AppendLine("</body></html>");

        return sb.ToString();
    }

    private ShiftAssignmentConflictExampleResult RunExample(
        string title,
        string description,
        bool expectConflict,
        Func<ExampleContext> contextFactory)
    {
        var context = contextFactory();
        var conflicts = _conflictService.DetectConflicts(
            context.Request,
            context.ExistingAssignments,
            context.ExistingSchedules);

        return new ShiftAssignmentConflictExampleResult
        {
            Title = title,
            Description = description,
            ExpectConflict = expectConflict,
            HasConflict = conflicts != null && conflicts.Any(),
            ConflictCount = conflicts?.Count ?? 0,
            Conflicts = conflicts ?? new List<ScheduleConflictDetail>(),
            Request = context.Request,
            ExistingAssignments = context.ExistingAssignments,
            ExistingSchedules = context.ExistingSchedules
        };
    }

    #region Example builders

    private ExampleContext BuildDailyOverlap()
    {
        var request = CreateDailyRequest(
            userId: 1001,
            shiftId: 2001,
            startDate: new DateTime(2025, 11, 5),
            startTime: "13:00",
            endTime: "21:00");

        var assignment = CreateAssignment(3001, shiftId: 9001, request.UserId, "Warehouse Day Shift");
        var schedule = CreateDailyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4001,
            startDate: new DateTime(2025, 11, 5),
            startTime: 9,
            endTime: 17);

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    private ExampleContext BuildDailyNonOverlap()
    {
        var request = CreateDailyRequest(
            userId: 1002,
            shiftId: 2002,
            startDate: new DateTime(2025, 11, 5),
            startTime: "13:00",
            endTime: "21:00");

        var assignment = CreateAssignment(3002, shiftId: 9002, request.UserId, "Prep Morning Shift");
        var schedule = CreateDailyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4002,
            startDate: new DateTime(2025, 11, 5),
            startTime: 6,
            endTime: 12);

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    private ExampleContext BuildCrossMidnightConflict()
    {
        var request = CreateDailyRequest(
            userId: 1003,
            shiftId: 2003,
            startDate: new DateTime(2025, 11, 6),
            startTime: "01:00",
            endTime: "05:00");

        var assignment = CreateAssignment(3003, shiftId: 9003, request.UserId, "Security Night Watch");
        var schedule = CreateDailyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4003,
            startDate: new DateTime(2025, 11, 5),
            startTime: 20,
            endTime: 2); // Cross-midnight

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    private ExampleContext BuildWeeklyDifferentDays()
    {
        var request = CreateWeeklyRequest(
            userId: 1004,
            shiftId: 2004,
            startDate: new DateTime(2025, 11, 4), // Tuesday
            dayOfWeek: DayOfWeek.Tuesday,
            startHour: 9,
            endHour: 17);

        var assignment = CreateAssignment(3004, shiftId: 9004, request.UserId, "Front Desk Monday Shift");
        var schedule = CreateWeeklyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4004,
            startDate: new DateTime(2025, 11, 3), // Monday
            dayOfWeek: DayOfWeek.Monday,
            startHour: 9,
            endHour: 17);

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    private ExampleContext BuildAfterOccurrencesOverlap()
    {
        var request = CreateDailyRequest(
            userId: 1005,
            shiftId: 2005,
            startDate: new DateTime(2025, 11, 5),
            startTime: "07:00",
            endTime: "11:00",
            endType: EndType.AfterOccurrences,
            maxOccurrences: 3);

        var assignment = CreateAssignment(3005, shiftId: 9005, request.UserId, "Training Block");
        var schedule = CreateDailyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4005,
            startDate: new DateTime(2025, 11, 5),
            startTime: 8,
            endTime: 10);

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    private ExampleContext BuildBeyondHorizon()
    {
        var request = CreateDailyRequest(
            userId: 1006,
            shiftId: 2006,
            startDate: new DateTime(2025, 11, 5),
            startTime: "09:00",
            endTime: "12:00");

        var assignment = CreateAssignment(3006, shiftId: 9006, request.UserId, "Future Project Shift");
        var schedule = CreateDailyScheduleResponse(
            assignmentId: assignment.Id,
            scheduleId: 4006,
            startDate: new DateTime(2031, 11, 6), // Starts six years later
            startTime: 9,
            endTime: 12);

        return new ExampleContext(request, new List<ShiftAssignmentDetailDto> { assignment }, new List<ScheduleResponse> { schedule });
    }

    #endregion

    #region Helpers

    private ScheduleEmployeeRequest CreateDailyRequest(
        int userId,
        int shiftId,
        DateTime startDate,
        string startTime,
        string endTime,
        EndType endType = EndType.Never,
        int? maxOccurrences = null)
    {
        return new ScheduleEmployeeRequest
        {
            UserId = userId,
            ShiftId = shiftId,
            Schedules = new List<ScheduleRequest>
            {
                new()
                {
                    ShiftId = shiftId,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = startDate,
                    ScheduleType = (int)ScheduleType.Daily,
                    RepeatEvery = 1,
                    ScheduleWithoutTimes = false,
                    StartTime = startTime,
                    EndTime = endTime,
                    EndType = (int)endType,
                    MaxOccurrences = maxOccurrences,
                    IsActive = true
                }
            }
        };
    }

    private ScheduleEmployeeRequest CreateWeeklyRequest(
        int userId,
        int shiftId,
        DateTime startDate,
        DayOfWeek dayOfWeek,
        int startHour,
        int endHour)
    {
        return new ScheduleEmployeeRequest
        {
            UserId = userId,
            ShiftId = shiftId,
            Schedules = new List<ScheduleRequest>
            {
                new()
                {
                    ShiftId = shiftId,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = startDate,
                    ScheduleType = (int)ScheduleType.Weekly,
                    RepeatEvery = 1,
                    ScheduleWithoutTimes = false,
                    StartTime = $"{startHour:00}:00",
                    EndTime = $"{endHour:00}:00",
                    EndType = (int)EndType.Never,
                    IsActive = true,
                    Frequency = new List<ScheduleFrequencyRequest>
                    {
                        new()
                        {
                            Day = (int)dayOfWeek,
                            DayType = 0
                        }
                    }
                }
            }
        };
    }

    private ShiftAssignmentDetailDto CreateAssignment(int assignmentId, int shiftId, int userId, string shiftName)
    {
        return new ShiftAssignmentDetailDto
        {
            Id = assignmentId,
            UserId = userId,
            ShiftId = shiftId,
            ShiftName = shiftName
        };
    }

    private ScheduleResponse CreateDailyScheduleResponse(
        int assignmentId,
        int scheduleId,
        DateTime startDate,
        int startTime,
        int endTime)
    {
        return new ScheduleResponse
        {
            Id = scheduleId,
            SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
            SourceId = assignmentId,
            StartFrom = startDate,
            ScheduleType = (int)ScheduleType.Daily,
            RepeatEvery = 1,
            ScheduleWithoutTimes = false,
            StartTime = TimeSpan.FromHours(startTime),
            EndTime = TimeSpan.FromHours(endTime),
            IsActive = true,
            EndType = EndType.Never.ToString()
        };
    }

    private ScheduleResponse CreateWeeklyScheduleResponse(
        int assignmentId,
        int scheduleId,
        DateTime startDate,
        DayOfWeek dayOfWeek,
        int startHour,
        int endHour)
    {
        return new ScheduleResponse
        {
            Id = scheduleId,
            SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
            SourceId = assignmentId,
            StartFrom = startDate,
            ScheduleType = (int)ScheduleType.Weekly,
            RepeatEvery = 1,
            ScheduleWithoutTimes = false,
            StartTime = TimeSpan.FromHours(startHour),
            EndTime = TimeSpan.FromHours(endHour),
            IsActive = true,
            EndType = EndType.Never.ToString(),
            Frequency = new List<ScheduleFrequencyResponse>
            {
                new()
                {
                    Day = (int)dayOfWeek,
                    DayType = 0
                }
            }
        };
    }

    private record ExampleContext(
        ScheduleEmployeeRequest Request,
        List<ShiftAssignmentDetailDto> ExistingAssignments,
        List<ScheduleResponse> ExistingSchedules);

    private static string FormatWindow(TimeWindow window)
    {
        if (window == null)
        {
            return "-";
        }

        if (window.IsAllDay)
        {
            return "All day";
        }

        var start = window.Start?.ToString("HH:mm") ?? "??";
        var end = window.End?.ToString("HH:mm") ?? "??";
        return $"{start} - {end}";
    }

    private static string Encode(string value) => WebUtility.HtmlEncode(value ?? string.Empty);

    #endregion

}

/// <summary>
/// Represents the result of a conflict detection example run.
/// </summary>
public class ShiftAssignmentConflictExampleResult
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool ExpectConflict { get; set; }
    public bool HasConflict { get; set; }
    public int ConflictCount { get; set; }
    public List<ScheduleConflictDetail> Conflicts { get; set; } = new();
    public ScheduleEmployeeRequest Request { get; set; } = new();
    public List<ShiftAssignmentDetailDto> ExistingAssignments { get; set; } = new();
    public List<ScheduleResponse> ExistingSchedules { get; set; } = new();
}

