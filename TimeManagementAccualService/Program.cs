using TimeManagement.AccrualService;
using TimeManagement.Application.DependencyInjection;
using Microsoft.Extensions.Hosting.WindowsServices;

var builder = Host.CreateApplicationBuilder(args);

// Add Windows Service support
builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "TimeManagementAccrualService";
});

// Add common Time Management services (processors, repositories, application services)
builder.Services.AddTimeManagementServices(builder.Configuration);

// Add common Time Management logging (log4net and custom logger)
builder.Services.AddTimeManagementLogging(builder.Configuration);

// Register the worker service
builder.Services.AddHostedService<Worker>();

var host = builder.Build();

// Configure custom logger factory
host.Services.ConfigureTimeManagementLoggerFactory();

host.Run();
