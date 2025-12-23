using Microsoft.AspNetCore.Mvc;
using Grpc.Net.Client;
using GrpcProtoLibrary.Protos;
using Grpc.Core;

namespace TimeManagement.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GrpcTestController : ControllerBase
    {
        private const string BaseUrl = "https://staff-scheduling-dev.vastpacific.com";
        private const string JwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkFBQSBCQkIgQ0NDIERERCBFRUUgRkZGIEdHRyBISEggSUlJIn0.eyJ1c2VybmFtZSI6ImVyaWMuYnJvd24iLCJ1c2VyaWQiOiIyIiwidGVuYW50aWQiOiI0MjAxIiwiY3VzdG9tZXJpZCI6IkRFVi00MjAxIiwib3JnYW5pemF0aW9uQWRtaW5FbWFpbCI6IiIsImVudGl0eU5hbWUiOiJERVYtNDIwMSIsImlzSW1wZXJzb25hdGVVc2VyIjoiZmFsc2UiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOlsiRW1wbG95ZWUiLCJDVE8gVHJhaW5lciJdLCJleHAiOjE3NjY0Mjc0ODMsImlzcyI6IndlYnBvcnRhbCIsImF1ZCI6Imh0dHA6Ly9sb2NhbGhvc3Q6NTg3NTEifQ.ZZrZS-mJIQwXgCFfTVMq6uHzhfF7Qww3ceQNpTWxpjg";

        /// <summary>
        /// Test gRPC endpoint - Calls remote gRPC service and returns result
        /// </summary>
        [HttpGet("test-all")]
        public async Task<IActionResult> TestGrpcEndpoint()
        {
            try
            {
                var result = await CallGrpcServiceAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    error = ex.Message,
                    details = ex.ToString()
                });
            }
        }

        private async Task<object> CallGrpcServiceAsync()
        {
            // Log what we're sending
            Console.WriteLine("=== gRPC Test Debug ===");
            Console.WriteLine($"Base URL: {BaseUrl}");
            Console.WriteLine($"JWT Token (first 50 chars): {JwtToken.Substring(0, Math.Min(50, JwtToken.Length))}...");
            Console.WriteLine($"Tenant ID: 4201");
            Console.WriteLine($"Login ID: 2");

            // Create gRPC channel with proper configuration
            var httpHandler = new System.Net.Http.SocketsHttpHandler
            {
                // Ensure HTTP/2 is enabled for gRPC
                EnableMultipleHttp2Connections = true
            };

            using var channel = GrpcChannel.ForAddress(BaseUrl, new GrpcChannelOptions
            {
                HttpHandler = httpHandler,
                MaxReceiveMessageSize = 10 * 1024 * 1024,
                MaxSendMessageSize = 10 * 1024 * 1024
            });

            var client = new HttpService.HttpServiceClient(channel);

            // Create metadata with headers - ensure exact format as Postman
            var metadata = new Metadata();
            
            // Add authorization header - ensure Bearer prefix is correct
            var authHeaderValue = $"Bearer {JwtToken}";
            metadata.Add("authorization", authHeaderValue);
            Console.WriteLine($"Authorization header: Bearer [TOKEN] (length: {authHeaderValue.Length})");
            
            metadata.Add("tenant_id", "4201");
            metadata.Add("login_id", "2");
            
            Console.WriteLine($"Total metadata headers: {metadata.Count}");
            foreach (var header in metadata)
            {
                var value = header.Key.ToLower().Contains("auth") ? "[REDACTED]" : header.Value;
                Console.WriteLine($"  Header: {header.Key} = {value}");
            }

            // Create request
            var request = new GrpcProtoLibrary.Protos.HttpRequest
            {
                ServiceName = "timeoffrequests",
                MethodName = "Get",
                JsonData = "{\"timeOffRequestId\":null,\"userId\":null,\"pageNumber\":1,\"pageSize\":10,\"sortColumn\":\"DateCreated\",\"sortDirection\":\"DESC\",\"searchTerm\":null}"
            };

            Console.WriteLine($"Request - Service: {request.ServiceName}, Method: {request.MethodName}");
            Console.WriteLine($"Request JsonData length: {request.JsonData?.Length ?? 0}");

            try
            {
                Console.WriteLine("Making gRPC call...");
                // Make the gRPC call
                var response = await client.PostAsync(request, headers: metadata);

                Console.WriteLine($"Response received - StatusCode: {response.StatusCode}");

                return new
                {
                    success = response.StatusCode == 200,
                    statusCode = response.StatusCode,
                    data = response.Data,
                    message = response.StatusCode == 200 ? "gRPC call successful" : "gRPC call returned non-200 status",
                    debug = new
                    {
                        headersSent = metadata.Count,
                        requestServiceName = request.ServiceName,
                        requestMethodName = request.MethodName
                    }
                };
            }
            catch (RpcException rpcEx)
            {
                Console.WriteLine($"RpcException caught - StatusCode: {rpcEx.StatusCode}, Detail: {rpcEx.Status.Detail}");
                
                var trailersDict = new Dictionary<string, string>();
                if (rpcEx.Trailers != null)
                {
                    foreach (var trailer in rpcEx.Trailers)
                    {
                        trailersDict[trailer.Key] = trailer.Value;
                    }
                }

                return new
                {
                    success = false,
                    error = "gRPC Error",
                    statusCode = rpcEx.StatusCode.ToString(),
                    detail = rpcEx.Status.Detail,
                    message = rpcEx.Message,
                    trailers = trailersDict,
                    debug = new
                    {
                        headersSent = metadata.Count,
                        requestServiceName = request.ServiceName,
                        requestMethodName = request.MethodName,
                        authorizationHeaderPresent = metadata.Any(m => m.Key == "authorization"),
                        tenantIdHeaderPresent = metadata.Any(m => m.Key == "tenant_id"),
                        loginIdHeaderPresent = metadata.Any(m => m.Key == "login_id")
                    }
                };
            }
        }
    }
}
