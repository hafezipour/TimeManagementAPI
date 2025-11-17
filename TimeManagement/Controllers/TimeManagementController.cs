using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using TimeManagement.Application.Security;
using TimeManagement.Application.Services;

namespace TimeManagement.Controllers;

[ApiController]
[Route("time-management")]
public class TimeManagementController : ControllerBase
{
    private readonly ProcessorRequestRouter _processorRequestRouter;
    private readonly ValidateToken _validateToken;

    public TimeManagementController(
        ProcessorRequestRouter processorRequestRouter,
        ValidateToken validateToken)
    {
        _processorRequestRouter = processorRequestRouter;
        _validateToken = validateToken;
    }

    [HttpPost("process-request")]
    public async Task<IActionResult> ProcessRequest(
        [FromQuery] string? serviceName,
        [FromQuery] string? methodName,
        [FromQuery] string? methodType,
        [FromBody] JsonElement? payload = null)
    {
        var authResult = await _validateToken.AuthenticateHttpRequest(HttpContext);
        if (!authResult.IsAuthenticated)
        {
            return Unauthorized(new { success = false, message = "Unauthorized" });
        }

        var jsonData = payload.HasValue ? payload.Value.GetRawText() : "{}";
        if (string.IsNullOrWhiteSpace(jsonData))
        {
            jsonData = "{}";
        }

        var routedResult = await _processorRequestRouter.RouteAsync(
            serviceName,
            methodName,
            jsonData,
            authResult.User);

        return new ContentResult
        {
            StatusCode = routedResult.StatusCode,
            Content = routedResult.Data,
            ContentType = "application/json"
        };
    }
}




