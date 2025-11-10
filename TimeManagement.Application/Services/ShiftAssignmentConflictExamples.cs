using System;
using System.Collections.Generic;
using System.Linq;
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
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services;

/// <summary>
/// Builds HTML demonstrations for shift-assignment conflict detection scenarios.
/// </summary>
public class ShiftAssignmentConflictExamples
{
    private readonly ShiftAssignmentConflictService _conflictService;

    public ShiftAssignmentConflictExamples(ShiftAssignmentConflictService conflictService)
    {
        _conflictService = conflictService;
    }

    /// <summary>
    /// Generates a rich HTML report showcasing conflict edge cases.
    /// </summary>
    public string BuildHtmlReport()
    {
        var html = new StringBuilder();

        html.AppendLine("<html><head><style>");
        html.AppendLine("body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #10131a; color: #f1f5f9; padding: 24px; }");
        html.AppendLine("h1 { color: #38bdf8; margin-bottom: 12px; }");
        html.AppendLine("h2 { color: #94a3b8; margin-top: 32px; border-bottom: 1px solid #1e293b; padding-bottom: 8px; }");
        html.AppendLine(".scenario { background: #111827; border: 1px solid #1f2937; border-radius: 12px; margin-bottom: 24px; padding: 20px; box-shadow: 0 8px 18px rgba(15, 23, 42, 0.4); }");
        html.AppendLine(".meta { margin-bottom: 16px; padding: 16px; background: #0f172a; border-radius: 8px; line-height: 1.6; }");
        html.AppendLine(".meta strong { color: #38bdf8; }");
        html.AppendLine(".no-conflict { color: #34d399; font-weight: 600; }");
        html.AppendLine(".conflict { color: #f87171; font-weight: 600; }");
        html.AppendLine("table { width: 100%; border-collapse: collapse; margin-top: 16px; }");
        html.AppendLine("th, td { padding: 10px; border-bottom: 1px solid #1f2937; text-align: left; font-size: 0.95rem; }");
        html.AppendLine("th { color: #60a5fa; font-weight: 600; background: rgba(30, 64, 175, 0.2); }");
        html.AppendLine("tr:hover td { background: rgba(30, 41, 59, 0.35); }");
        html.AppendLine(".timestamp { font-family: 'Courier New', monospace; color: #e2e8f0; }");
        html.AppendLine("</style></head><body>");
        html.AppendLine("<h1>Shift Assignment Conflict Demonstrations</h1>");
        html.AppendLine("<p>Below are curated scenarios that exercise the conflict detector, including overlapping windows, overnight shifts, " +
                        "bounded occurrences, and schedules that safely coexist.</p>");

        html.AppendLine(BuildScenario(
            "Scenario 1 · Same-Day Overlap",
            "New assignment overlaps an existing task on the same day and within the same time range.",
            CreateScenarioRequest(
                userId: 1001,
                shiftId: 501,
                newSchedule: new ScheduleRequest
                {
                    ShiftId = 501,
                    StartFrom = new DateTime(2025, 11, 14),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = "09:00",
                    EndTime = "17:00",
                    EndType = (int)EndType.Never,
                    IsActive = true
                }),
            new List<ShiftAssignmentDetailDto>
            {
                new ShiftAssignmentDetailDto
                {
                    Id = 2001,
                    ShiftId = 777,
                    UserId = 1001,
                    ShiftName = "Customer Support (Day)",
                    ScheduleId = 3001
                }
            },
            new List<ScheduleResponse>
            {
                new ScheduleResponse
                {
                    Id = 3001,
                    SourceId = 2001,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = new DateTime(2025, 11, 14),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = TimeSpan.FromHours(8),
                    EndTime = TimeSpan.FromHours(17),
                    EndType = EndType.Never.ToString(),
                    IsActive = true
                }
            }));

        html.AppendLine(BuildScenario(
            "Scenario 2 · Safe Gap · No Conflict",
            "Existing assignment ends before the requested assignment starts, leaving a 30 minute buffer.",
            CreateScenarioRequest(
                userId: 1002,
                shiftId: 502,
                newSchedule: new ScheduleRequest
                {
                    ShiftId = 502,
                    StartFrom = new DateTime(2025, 11, 14),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = "13:30",
                    EndTime = "17:30",
                    EndType = (int)EndType.Never,
                    IsActive = true
                }),
            new List<ShiftAssignmentDetailDto>
            {
                new ShiftAssignmentDetailDto
                {
                    Id = 2002,
                    ShiftId = 778,
                    UserId = 1002,
                    ShiftName = "Inventory Count",
                    ScheduleId = 3002
                }
            },
            new List<ScheduleResponse>
            {
                new ScheduleResponse
                {
                    Id = 3002,
                    SourceId = 2002,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = new DateTime(2025, 11, 14),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = TimeSpan.FromHours(9),
                    EndTime = TimeSpan.FromHours(13),
                    EndType = EndType.Never.ToString(),
                    IsActive = true
                }
            }));

        html.AppendLine(BuildScenario(
            "Scenario 3 · Overnight Clash",
            "Existing graveyard shift spans midnight; requested shift starts before the first one ends.",
            CreateScenarioRequest(
                userId: 1003,
                shiftId: 503,
                newSchedule: new ScheduleRequest
                {
                    ShiftId = 503,
                    StartFrom = new DateTime(2025, 11, 15),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = "04:00",
                    EndTime = "12:00",
                    EndType = (int)EndType.Never,
                    IsActive = true
                }),
            new List<ShiftAssignmentDetailDto>
            {
                new ShiftAssignmentDetailDto
                {
                    Id = 2003,
                    ShiftId = 779,
                    UserId = 1003,
                    ShiftName = "Night Audit",
                    ScheduleId = 3003
                }
            },
            new List<ScheduleResponse>
            {
                new ScheduleResponse
                {
                    Id = 3003,
                    SourceId = 2003,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = new DateTime(2025, 11, 14),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = TimeSpan.FromHours(22), // 10 PM
                    EndTime = TimeSpan.FromHours(4),    // 4 AM (next day)
                    EndType = EndType.Never.ToString(),
                    IsActive = true
                }
            }));

        html.AppendLine(BuildScenario(
            "Scenario 4 · Bounded by Occurrences",
            "Existing recurring assignment stops after 3 occurrences; new assignment starts later still inside 5 year horizon.",
            CreateScenarioRequest(
                userId: 1004,
                shiftId: 504,
                newSchedule: new ScheduleRequest
                {
                    ShiftId = 504,
                    StartFrom = new DateTime(2025, 11, 20),
                    ScheduleType = (int)ScheduleType.DoesNotRepeat,
                    StartTime = "08:00",
                    EndTime = "12:00",
                    EndType = (int)EndType.Never,
                    IsActive = true
                }),
            new List<ShiftAssignmentDetailDto>
            {
                new ShiftAssignmentDetailDto
                {
                    Id = 2004,
                    ShiftId = 780,
                    UserId = 1004,
                    ShiftName = "Orientation Series",
                    ScheduleId = 3004
                }
            },
            new List<ScheduleResponse>
            {
                new ScheduleResponse
                {
                    Id = 3004,
                    SourceId = 2004,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment,
                    StartFrom = new DateTime(2025, 11, 10),
                    ScheduleType = (int)ScheduleType.Daily,
                    RepeatEvery = 1,
                    MaxOccurrences = 3,
                    EndType = EndType.AfterOccurrences.ToString(),
                    StartTime = TimeSpan.FromHours(8),
                    EndTime = TimeSpan.FromHours(11),
                    IsActive = true
                }
            }));

        html.AppendLine("</body></html>");

        return html.ToString();
    }

    private static ScheduleEmployeeRequest CreateScenarioRequest(int userId, int shiftId, ScheduleRequest newSchedule)
    {
        newSchedule.SourceType ??= (int)ScheduleSourceTypes.ShiftAssignment;

        return new ScheduleEmployeeRequest
        {
            UserId = userId,
            ShiftId = shiftId,
            Schedules = new List<ScheduleRequest> { newSchedule }
        };
    }

    private string BuildScenario(
        string title,
        string summary,
        ScheduleEmployeeRequest request,
        List<ShiftAssignmentDetailDto> existingAssignments,
        List<ScheduleResponse> existingSchedules)
    {
        var conflicts = _conflictService.DetectConflicts(request, existingAssignments, existingSchedules);
        var hasConflicts = conflicts != null && conflicts.Any();

        var sb = new StringBuilder();
        sb.AppendLine("<div class='scenario'>");
        sb.AppendLine($"<h2>{title}</h2>");
        sb.AppendLine($"<div class='meta'><strong>Description:</strong> {summary}<br/>");
        sb.AppendLine($"<strong>User ID:</strong> {request.UserId} &nbsp;|&nbsp; <strong>Shift ID:</strong> {request.ShiftId}<br/>");
        sb.AppendLine($"<strong>Result:</strong> {(hasConflicts ? "<span class='conflict'>Conflict detected</span>" : "<span class='no-conflict'>No conflicts</span>")}</div>");

        if (!hasConflicts)
        {
            sb.AppendLine("<p>This assignment is clean — no overlapping occurrences were detected across the 5-year evaluation window.</p>");
        }
        else
        {
            sb.AppendLine("<table>");
            sb.AppendLine("<thead><tr><th>Date</th><th>Existing Shift</th><th>Existing Window</th><th>Requested Window</th><th>Reason</th></tr></thead>");
            sb.AppendLine("<tbody>");

            foreach (var conflict in conflicts!.OrderBy(c => c.Date).ThenBy(c => c.ExistingAssignmentId))
            {
                sb.AppendLine("<tr>");
                sb.AppendLine($"<td class='timestamp'>{conflict.Date:yyyy-MM-dd}</td>");
                sb.AppendLine($"<td>{conflict.ExistingShiftName ?? $"Assignment #{conflict.ExistingAssignmentId}"}</td>");
                sb.AppendLine($"<td class='timestamp'>{FormatWindow(conflict.ExistingWindow)}</td>");
                sb.AppendLine($"<td class='timestamp'>{FormatWindow(conflict.RequestedWindow)}</td>");
                sb.AppendLine($"<td>{conflict.Reason}</td>");
                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</tbody></table>");
        }

        sb.AppendLine("</div>");
        return sb.ToString();
    }

    private static string FormatWindow(TimeWindow window)
    {
        if (window.IsAllDay || !window.Start.HasValue || !window.End.HasValue)
        {
            return "All day";
        }

        var start = window.Start.Value;
        var end = window.End.Value;
        var needsNextDayBadge = end.Date > start.Date;

        var label = $"{start:HH:mm} - {end:HH:mm}";
        return needsNextDayBadge ? $"{label} <small>(+1 day)</small>" : label;
    }
}

