using Grpc.Core;
using GrpcProtoLibrary.Protos;
using TimeManagement.Application.Processors;

namespace TimeManagement.Application.Services;

public class HttpGrpcService : HttpService.HttpServiceBase
{
    private readonly JobCodeProcessor _jobCodeProcessor;
    private readonly WorkCodeProcessor _workCodeProcessor;

    public HttpGrpcService(JobCodeProcessor jobCodeProcessor, WorkCodeProcessor workCodeProcessor)
    {
        _jobCodeProcessor = jobCodeProcessor;
        _workCodeProcessor = workCodeProcessor;
    }

    public override async Task<HttpResponse> Get(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request);
        
        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Post(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request);
        
        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Put(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request);
        
        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Delete(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request);
        
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
    private async Task<(int StatusCode, string Data)> RouteRequest(HttpRequest request)
    {
        try
        {
            string result;

            switch (request.ServiceName.ToLower())
            {
                case "jobcode":
                    result = await _jobCodeProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                case "workcode":
                    result = await _workCodeProcessor.ProcessRequest(
                        request.ServiceName, 
                        request.MethodName, 
                        request.JsonData);
                    break;

                default:
                    result = System.Text.Json.JsonSerializer.Serialize(new
                    {
                        success = false,
                        message = $"Unknown service: {request.ServiceName}"
                    });
                    return (404, result);
            }

            return (200, result);
        }
        catch (Exception ex)
        {
            var errorResult = System.Text.Json.JsonSerializer.Serialize(new
            {
                success = false,
                message = $"Error processing request: {ex.Message}"
            });
            return (500, errorResult);
        }
    }
}
