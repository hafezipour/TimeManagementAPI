using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Net;
using System.Text;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Services;

namespace TimeManagement.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShiftAssignmentConflictController : ControllerBase
{
    private readonly ShiftAssignmentConflictExamples _examples;

    public ShiftAssignmentConflictController(ShiftAssignmentConflictExamples examples)
    {
        _examples = examples;
    }

    /// <summary>
    /// Runs predefined shift assignment conflict scenarios and returns an HTML report.
    /// </summary>
    [HttpGet("examples")]
    public IActionResult RunExamples()
    {
        var results = _examples.RunAll();
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
            var statusLabel = statusMatches
                ? "Expectation met"
                : "Expectation mismatch";
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
                    sb.AppendLine($"<td>{FormatWindow(conflict.ExistingWindow)}</td>");
                    sb.AppendLine($"<td>{FormatWindow(conflict.RequestedWindow)}</td>");
                    sb.AppendLine($"<td>{Encode(conflict.Reason ?? "Overlap detected")}</td>");
                    sb.AppendLine("</tr>");
                }

                sb.AppendLine("</tbody></table>");
            }

            sb.AppendLine("</div>");
        }

        sb.AppendLine("</body></html>");

        return Content(sb.ToString(), "text/html");
    }

    private static string Encode(string value) => WebUtility.HtmlEncode(value ?? string.Empty);

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
}
using Microsoft.AspNetCore.Mvc;
using TimeManagement.Application.Services;

namespace TimeManagement.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShiftAssignmentConflictController : ControllerBase
{
    private readonly ShiftAssignmentConflictExamples _examples;

    public ShiftAssignmentConflictController(ShiftAssignmentConflictExamples examples)
    {
        _examples = examples;
    }

    /// <summary>
    /// Renders an HTML page demonstrating conflict detection scenarios.
    /// </summary>
    [HttpGet("demo")]
    public IActionResult Demo()
    {
        var html = _examples.BuildHtmlReport();
        return Content(html, "text/html");
    }
}

