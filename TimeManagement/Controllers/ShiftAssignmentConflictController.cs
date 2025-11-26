using Microsoft.AspNetCore.Mvc;
using TimeManagement.Application.Services;
using TimeManagement.Infra.Extensions;

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
        CustomLogger.Log(LogLevel.Error, new Exception() { }, "This is a test");//Just by default set here log level as error type

        var html = _examples.BuildHtmlReport();
        return Content(html, "text/html");
    }
}
