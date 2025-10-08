using Grpc.Core;
using GrpcProtoLibrary.Protos;

namespace TimeManagement.Application.Services;

public class HttpGrpcService : HttpService.HttpServiceBase
{
    public override Task<HttpResponse> Get(HttpRequest request, ServerCallContext context)
    {
        // Return some raw data for now
        var response = new HttpResponse
        {
            StatusCode = 200,
            Data = $"{{\"message\": \"GET request received\", \"serviceName\": \"{request.ServiceName}\", \"methodName\": \"{request.MethodName}\", \"receivedData\": {request.JsonData}}}"
        };

        return Task.FromResult(response);
    }

    public override Task<HttpResponse> Post(HttpRequest request, ServerCallContext context)
    {
        // Return some raw data for now
        var response = new HttpResponse
        {
            StatusCode = 201,
            Data = $"{{\"message\": \"POST request received\", \"serviceName\": \"{request.ServiceName}\", \"methodName\": \"{request.MethodName}\", \"receivedData\": {request.JsonData}}}"
        };

        return Task.FromResult(response);
    }

    public override Task<HttpResponse> Put(HttpRequest request, ServerCallContext context)
    {
        // Return some raw data for now
        var response = new HttpResponse
        {
            StatusCode = 200,
            Data = $"{{\"message\": \"PUT request received\", \"serviceName\": \"{request.ServiceName}\", \"methodName\": \"{request.MethodName}\", \"receivedData\": {request.JsonData}}}"
        };

        return Task.FromResult(response);
    }

    public override Task<HttpResponse> Delete(HttpRequest request, ServerCallContext context)
    {
        // Return some raw data for now
        var response = new HttpResponse
        {
            StatusCode = 200,
            Data = $"{{\"message\": \"DELETE request received\", \"serviceName\": \"{request.ServiceName}\", \"methodName\": \"{request.MethodName}\", \"receivedData\": {request.JsonData}}}"
        };

        return Task.FromResult(response);
    }
}
