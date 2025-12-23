using Microsoft.AspNetCore.Mvc;

namespace TimeManagement.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InfrastructureCheckController : ControllerBase
    {
        /// <summary>
        /// Check infrastructure settings - Protocol, headers, etc.
        /// </summary>
        [HttpGet("check")]
        public IActionResult CheckInfrastructure()
        {
            var headers = new Dictionary<string, string>();
            foreach (var header in Request.Headers)
            {
            }

            return Ok(new
            {
                protocol = Request.Protocol,
                scheme = Request.Scheme,
                method = Request.Method,
                host = Request.Host.Value,
                path = Request.Path.Value,
                pathBase = Request.PathBase.Value,
                isHttps = Request.IsHttps,
                contentType = Request.ContentType,
                headers = headers,
                http2Supported = Request.Protocol.StartsWith("HTTP/2", StringComparison.OrdinalIgnoreCase),
                timestamp = DateTime.UtcNow
            });
        }

        /// <summary>
        /// Test gRPC endpoint reachability
        /// </summary>
        [HttpGet("test-grpc-reachability")]
        public IActionResult TestGrpcReachability()
        {
            return Ok(new
            {
                message = "If you can see this, the API endpoint is reachable",
                gRpcEndpoint = "https://staff-scheduling-dev.vastpacific.com/httpservice.HttpService/Post",
                note = "Use grpcurl or Postman to test the actual gRPC endpoint",
                timestamp = DateTime.UtcNow
            });
        }
    }
}

