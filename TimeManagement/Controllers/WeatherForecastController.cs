using Microsoft.AspNetCore.Mvc;
using TimeManagement.Infra.Extensions;
using log4net;

namespace TimeManagement.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;
        private static readonly ILog log4netLogger = LogManager.GetLogger(typeof(WeatherForecastController));

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public IEnumerable<WeatherForecast> Get()
        {
            // Test direct log4net logging
            log4netLogger.Error("Direct log4net ERROR test");
            log4netLogger.Warn("Direct log4net WARNING test");
            log4netLogger.Info("Direct log4net INFO test");
            log4netLogger.Debug("Direct log4net DEBUG test");

            // Test custom logger
            CustomLogger.Log(
                LogLevel.Error,
                new Exception() { Source = "JJMM" },
                "Here more info will come up"
                );

            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();
        }
    }
}
