using Grpc.Core;
using GrpcProtoLibrary.Protos;
using TimeManagement.Application.Processors;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Security;

namespace TimeManagement.Application.Services;

public class HttpGrpcService : HttpService.HttpServiceBase
{
    private readonly JobCodeProcessor _jobCodeProcessor;
    private readonly WorkCodeProcessor _workCodeProcessor;
    private readonly HolidayProcessor _holidayProcessor;
    private readonly HolidayAssignmentProcessor _holidayAssignmentProcessor;
    private readonly ValidateToken _validateToken;

    public HttpGrpcService(JobCodeProcessor jobCodeProcessor, WorkCodeProcessor workCodeProcessor, HolidayProcessor holidayProcessor, HolidayAssignmentProcessor holidayAssignmentProcessor)
    {
        _jobCodeProcessor = jobCodeProcessor;
        _workCodeProcessor = workCodeProcessor;
        _holidayProcessor = holidayProcessor;
        _holidayAssignmentProcessor = holidayAssignmentProcessor;
        _validateToken = new ValidateToken();
    }

    public override async Task<HttpResponse> Get(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Post(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Put(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Delete(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    /// <summary>
    /// Routes the request to the appropriate processor based on ServiceName
    /// </summary>
    private async Task<(int StatusCode, string Data)> RouteRequest(HttpRequest request, ServerCallContext context)
    {
        try
        {
            // Generic authentication check using ValidateToken
            var authResult = await _validateToken.AuthenticateRequest(context);
            if (!authResult.IsAuthenticated)
            {
                var unauthorizedResult = new
                {
                    success = false,
                    message = "Unauthorized"
                }.ToJson();
                return (401, unauthorizedResult);
            }

            string result;

            switch (request.ServiceName.ToLower())
            {
                case "jobcode":
                    _jobCodeProcessor.SetCurrentUser(authResult.User);
                    result = await _jobCodeProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                case "workcode":
                    _workCodeProcessor.SetCurrentUser(authResult.User);
                    result = await _workCodeProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                case "holidays":
                    _holidayProcessor.SetCurrentUser(authResult.User);
                    result = await _holidayProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                case "holiday-assignments":
                    _holidayAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _holidayAssignmentProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                default:
                    result = new
                    {
                        success = false,
                        message = $"Unknown service: {request.ServiceName}"
                    }.ToJson();
                    return (404, result);
            }

            return (200, result);
        }
        catch (Exception ex)
        {
            var errorResult = new
            {
                success = false,
                message = $"Error processing request: {ex.Message}"
            }.ToJson();
            return (500, errorResult);
        }
    }
}
