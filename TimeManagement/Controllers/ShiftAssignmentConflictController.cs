using Microsoft.AspNetCore.Mvc;
using TimeManagement.Application.Services;
using TimeManagement.Infra.Extensions;

namespace TimeManagement.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShiftAssignmentConflictController : ControllerBase
{

    public ShiftAssignmentConflictController( )
    {
    }

    /// <summary>
    /// Renders an HTML page demonstrating conflict detection scenarios.
    /// </summary>
    [HttpGet("examples")]
    [HttpGet("demo")]
    public IActionResult Examples()
    {
        CustomLogger.Log(LogLevel.Error, new Exception() { }, "This is a test");//Just by default set here log level as error type

        return Content("<h1>Welcome</h1>", "text/html");
    }
}
