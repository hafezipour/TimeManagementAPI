using TimeManagement.Application.Services;

namespace TimeManagement.AccrualService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly AccrualEvaluator _accrualEvaluator;

        public Worker(ILogger<Worker> logger, AccrualEvaluator accrualEvaluator)
        {
            _logger = logger;
            _accrualEvaluator = accrualEvaluator;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    // Call AccrualEvaluator to process accruals
                    await _accrualEvaluator.Evaluate(stoppingToken);
                    
                    // Run every 5 minutes (300000 milliseconds)
                    await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Expected when cancellation is requested
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred in worker execution");
                    await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                }
            }
        }
    }
}
