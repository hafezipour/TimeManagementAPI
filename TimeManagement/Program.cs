using DbOperations;
using WebPortalSecurityManager;
using TimeManagement.Infra.Extensions;
using TimeManagement.Infra.Logging;
using Microsoft.Extensions.Logging;
using log4net;
using log4net.Config;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);
var services = builder.Services;

IConfiguration configuration = builder.Configuration;

#region ConfigureServices

services.AddHttpContextAccessor();
var dbVersionStr = configuration["WebPortalDBVersion"];
new WebPortalCredentialsHandler(new WebPortalSecurityManager.Models.WPSecurityCredentialsDto() { }).LoadCredentials(builder.Configuration["FilePath"], Convert.ToInt32(dbVersionStr)).Wait();

DbOperationsConfiguration.ConnectionString = WebPortalCredentials.ConnectionStrings.TimeManagementDB;


#endregion

// Add services to the container.
builder.Services.AddGrpc();

// Register processors for dependency injection
builder.Services.AddScoped<TimeManagement.Application.Processors.JobCodeProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.WorkCodeProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.AccrualTypesProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.HolidayProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.HolidayAssignmentProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.ShiftProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.ScheduleProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.LayoutProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.ColumnProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.EmployeeJobCodeAssignmentProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.EmployeeWorkCodeAssignmentProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.EmployeeLabelAssignmentProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.GroupsProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.LabelsProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.AssistantQualifiersProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.TradeBoardSettingsProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.ShiftAssignmentProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Processors.CustomTableValuesProcessor>();
builder.Services.AddScoped<TimeManagement.Application.Services.ProcessorRequestRouter>();
builder.Services.AddScoped<TimeManagement.Application.Security.ValidateToken>();

// Register services
builder.Services.AddScoped<TimeManagement.Application.Services.ScheduleEvaluator>();
builder.Services.AddScoped<TimeManagement.Application.Services.ShiftAssignmentConflictService>();
builder.Services.AddScoped<TimeManagement.Application.Services.ShiftAssignmentConflictExamples>();

// Register repositories for dependency injection
builder.Services.AddScoped<TimeManagement.Infra.Repositories.HolidaysRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.HolidayAssignmentRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.JobCodesRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.WorkCodesRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.AccrualTypesRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.SchedulesRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.ShiftsRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.LayoutRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.ColumnRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.EmployeeJobCodeAssignmentRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.EmployeeWorkCodeAssignmentRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.EmployeeLabelAssignmentRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.GroupsRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.LabelsRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.AssistantQualifiersRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.TradeBoardSettingsRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.ShiftAssignmentRepository>();
builder.Services.AddScoped<TimeManagement.Infra.Repositories.CustomTableValuesRepository>();
builder.Services.AddScoped<WebPortal.EF.Repository.DataBaseRepo.EfDbOperationsRepository>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Time Management API",
        Version = "v1",
        Description = "API for managing time management operations including shifts, schedules, columns, and layouts",
        Contact = new Microsoft.OpenApi.Models.OpenApiContact
        {
            Name = "Time Management Team"
        }
    });
});

var app = builder.Build();

// Configure log4net
var logRepository = LogManager.GetRepository(Assembly.GetEntryAssembly());
var logConfigPath = Path.Combine(AppContext.BaseDirectory, "Logging", "log4net.config");
Console.WriteLine($"Looking for log4net config at: {logConfigPath}");
Console.WriteLine($"Config file exists: {File.Exists(logConfigPath)}");
Console.WriteLine($"App base directory: {AppContext.BaseDirectory}");

// Try multiple possible paths for the config file
var possiblePaths = new[]
{
    logConfigPath,
    Path.Combine(Directory.GetCurrentDirectory(), "Logging", "log4net.config"),
    Path.Combine(AppContext.BaseDirectory, "TimeManagement.Infra", "Logging", "log4net.config"),
    "Logging\\log4net.config"
};

string foundConfigPath = null;
foreach (var path in possiblePaths)
{
    Console.WriteLine($"Checking: {path} - Exists: {File.Exists(path)}");
    if (File.Exists(path))
    {
        foundConfigPath = path;
        break;
    }
}

if (foundConfigPath != null)
{
    XmlConfigurator.Configure(logRepository, new FileInfo(foundConfigPath));
    Console.WriteLine($"log4net configured successfully with: {foundConfigPath}");
}
else
{
    Console.WriteLine("log4net config file not found in any expected location!");
    Console.WriteLine("Current directory: " + Directory.GetCurrentDirectory());
}

// Configure ApiContext and logging
ApiContext.Configure(app.Services.GetRequiredService<IHttpContextAccessor>());

// Configure custom logging like survey_api
var loggerFactory = app.Services.GetRequiredService<ILoggerFactory>();
TimeManagement.Infra.Extensions.CustomLogger.LoggerFactory = loggerFactory;
string logLevelDebug = WebPortalCredentials.TestingServiceLogging.LogLevel.Debug;
string logLevelTrace = WebPortalCredentials.TestingServiceLogging.LogLevel.Trace;
string logLevelInformation = WebPortalCredentials.TestingServiceLogging.LogLevel.Information;
string logLevelWarning = WebPortalCredentials.TestingServiceLogging.LogLevel.Warning;
string logLevelError = WebPortalCredentials.TestingServiceLogging.LogLevel.Error;
string logLevelCritical = WebPortalCredentials.TestingServiceLogging.LogLevel.Critical;

var configs = new List<LoggerConfiguration>();
if (!string.IsNullOrEmpty(logLevelDebug))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelDebug)
    });
}
if (!string.IsNullOrEmpty(logLevelTrace))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelTrace)
    });
}
if (!string.IsNullOrEmpty(logLevelInformation))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelInformation)
    });
}
if (!string.IsNullOrEmpty(logLevelWarning))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelWarning)
    });
}
if (!string.IsNullOrEmpty(logLevelError))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelError)
    });
}
if (!string.IsNullOrEmpty(logLevelCritical))
{
    configs.Add(new LoggerConfiguration
    {
        LogLevel = (LogLevel)Enum.Parse(typeof(LogLevel), logLevelCritical)
    });
}
if (configs.Count() > 0)
{
    loggerFactory.AddProvider(new LoggerProvider(configs));
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(c =>
    {
    });
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Time Management API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseHttpsRedirection();

app.UseAuthorization();

// Map gRPC service
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>();

app.MapControllers();

app.Run();
