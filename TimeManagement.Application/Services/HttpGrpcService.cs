using Grpc.Core;
using GrpcProtoLibrary.Protos;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Security;

namespace TimeManagement.Application.Services;

public class HttpGrpcService : HttpService.HttpServiceBase
{
    private readonly ProcessorRequestRouter _processorRequestRouter;
    private readonly ValidateToken _validateToken;

    public HttpGrpcService(
        ProcessorRequestRouter processorRequestRouter,
        ValidateToken validateToken)
    {
        _processorRequestRouter = processorRequestRouter;
        _validateToken = validateToken;
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

            var routedResponse = await _processorRequestRouter.RouteAsync(
                request.ServiceName,
                request.MethodName,
                request.JsonData,
                authResult.User);

            return routedResponse;
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
