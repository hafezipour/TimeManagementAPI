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
    [HttpGet("examples")]
    [HttpGet("demo")]
    public IActionResult Examples()
    {
        var html = _examples.BuildHtmlReport();
        return Content(html, "text/html");
    }
}
