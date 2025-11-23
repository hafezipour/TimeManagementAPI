using Grpc.Core;
using Microsoft.Extensions.Logging;
using TimeManagement.Infra.Extensions;

namespace TimeManagement.Application.Services;

public class AccrualEvaluator
{
    public AccrualEvaluator()
    {
    }

    /// <summary>
    /// Evaluates accrual rules and processes accruals
    /// </summary>
    public async Task Evaluate(CancellationToken cancellationToken = default)
    {
        CustomLogger.Log(LogLevel.Error, new Exception() { }, "This is a test");//Just by default set here log level as error type


        // TODO: Implement accrual evaluation logic
        await Task.CompletedTask;
    }
}

