using DbOperations;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using TimeManagement.Application.Processors;
using TimeManagement.Application.Security;
using TimeManagement.Application.Services;
using TimeManagement.Infra.Extensions;
using TimeManagement.Infra.Logging;
using TimeManagement.Infra.Repositories;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortalSecurityManager;
using log4net;
using log4net.Config;
using System.Reflection;

namespace TimeManagement.Application.DependencyInjection;

public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers all common services, processors, and repositories for Time Management
    /// This method is used by both the API project and Windows Service project
    /// </summary>
    public static IServiceCollection AddTimeManagementServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Configure database connection
        var dbVersionStr = configuration["WebPortalDBVersion"];
        new WebPortalCredentialsHandler(new WebPortalSecurityManager.Models.WPSecurityCredentialsDto())
            .LoadCredentials(configuration["FilePath"], Convert.ToInt32(dbVersionStr)).Wait();
        
        DbOperationsConfiguration.ConnectionString = WebPortalCredentials.ConnectionStrings.TimeManagementDB;

        // Register processors
        services.AddScoped<JobCodeProcessor>();
        services.AddScoped<WorkCodeProcessor>();
        services.AddScoped<AccrualTypesProcessor>();
        services.AddScoped<AccrualProfilesProcessor>();
        services.AddScoped<AccrualTracksProcessor>();
        services.AddScoped<AccrualRulesProcessor>();
        services.AddScoped<EmployeeAccrualSettingsProcessor>();
        services.AddScoped<AccrualBanksProcessor>();
        services.AddScoped<AccrualTransactionsProcessor>();
        services.AddScoped<HolidayProcessor>();
        services.AddScoped<HolidayAssignmentProcessor>();
        services.AddScoped<ShiftProcessor>();
        services.AddScoped<ScheduleProcessor>();
        services.AddScoped<LayoutProcessor>();
        services.AddScoped<ColumnProcessor>();
        services.AddScoped<EmployeeJobCodeAssignmentProcessor>();
        services.AddScoped<EmployeeWorkCodeAssignmentProcessor>();
        services.AddScoped<EmployeeLabelAssignmentProcessor>();
        services.AddScoped<GroupsProcessor>();
        services.AddScoped<LabelsProcessor>();
        services.AddScoped<AssistantQualifiersProcessor>();
        services.AddScoped<TradeBoardSettingsProcessor>();
        services.AddScoped<ShiftAssignmentProcessor>();
        services.AddScoped<ShiftTradesProcessor>();
        services.AddScoped<CustomTableValuesProcessor>();
        services.AddScoped<ValidateToken>();
        services.AddScoped<EmployeeAvailabilityProcessor>();
        services.AddScoped<TimeOffCodesProcessor>();
        services.AddScoped<TimeOffRequestsProcessor>();

        // Register application services
        services.AddScoped<ScheduleEvaluator>();
        services.AddScoped<ShiftAssignmentConflictService>();
        services.AddScoped<ShiftAssignmentConflictExamples>();
        services.AddSingleton<AccrualEvaluator>();

        // Register repositories
        services.AddScoped<HolidaysRepository>();
        services.AddScoped<HolidayAssignmentRepository>();
        services.AddScoped<JobCodesRepository>();
        services.AddScoped<WorkCodesRepository>();
        services.AddScoped<AccrualTypesRepository>();
        services.AddScoped<AccrualProfilesRepository>();
        services.AddScoped<AccrualTracksRepository>();
        services.AddScoped<AccrualRulesRepository>();
        services.AddScoped<EmployeeAccrualSettingsRepository>();
        services.AddScoped<AccrualBanksRepository>();
        services.AddScoped<AccrualTransactionsRepository>();
        services.AddScoped<SchedulesRepository>();
        services.AddScoped<ShiftsRepository>();
        services.AddScoped<LayoutRepository>();
        services.AddScoped<ColumnRepository>();
        services.AddScoped<EmployeeJobCodeAssignmentRepository>();
        services.AddScoped<EmployeeWorkCodeAssignmentRepository>();
        services.AddScoped<EmployeeLabelAssignmentRepository>();
        services.AddScoped<GroupsRepository>();
        services.AddScoped<LabelsRepository>();
        services.AddScoped<AssistantQualifiersRepository>();
        services.AddScoped<TradeBoardSettingsRepository>();
        services.AddScoped<ShiftAssignmentRepository>();
        services.AddScoped<ShiftTradesRepository>();
        services.AddScoped<CustomTableValuesRepository>();
        services.AddScoped<EmployeeAvailabilityRepository>();
        services.AddScoped<TimeOffCodesRepository>();
        services.AddScoped<TimeOffRequestsRepository>();
        services.AddScoped<EfDbOperationsRepository>();

        return services;
    }

    /// <summary>
    /// Configures log4net and custom logging for Time Management
    /// This method is used by both the API project and Windows Service project
    /// </summary>
    public static IServiceCollection AddTimeManagementLogging(this IServiceCollection services, IConfiguration? configuration = null, Assembly? entryAssembly = null)
    {
        // Configure log4net
        var logRepository = LogManager.GetRepository(entryAssembly ?? Assembly.GetEntryAssembly());
        var logConfigPath = Path.Combine(AppContext.BaseDirectory, "Logging", "log4net.config");
        
        // Try multiple possible paths for the config file
        var possiblePaths = new[]
        {
            logConfigPath,
            Path.Combine(Directory.GetCurrentDirectory(), "Logging", "log4net.config"),
            Path.Combine(AppContext.BaseDirectory, "TimeManagement.Infra", "Logging", "log4net.config"),
            Path.Combine(AppContext.BaseDirectory, "..", "TimeManagement.Infra", "Logging", "log4net.config"),
            "Logging\\log4net.config"
        };

        string? foundConfigPath = null;
        foreach (var path in possiblePaths)
        {
            if (File.Exists(path))
            {
                foundConfigPath = path;
                break;
            }
        }

        if (foundConfigPath != null)
        {
            XmlConfigurator.Configure(logRepository, new FileInfo(foundConfigPath));
        }

        // Configure custom logging - the provider will be added after Build() via ConfigureTimeManagementLoggerFactory

        return services;
    }

    /// <summary>
    /// Configures custom logger factory after the service provider is built
    /// This is typically called after Build() in the host/application
    /// </summary>
    public static void ConfigureTimeManagementLoggerFactory(this IServiceProvider serviceProvider)
    {
        var loggerFactory = serviceProvider.GetRequiredService<ILoggerFactory>();
        TimeManagement.Infra.Extensions.CustomLogger.LoggerFactory = loggerFactory;

        var configs = GetLoggerConfigurations();
        
        if (configs.Count > 0)
        {
            loggerFactory.AddProvider(new LoggerProvider(configs));
        }
    }

    private static List<LoggerConfiguration> GetLoggerConfigurations()
    {
        var configs = new List<LoggerConfiguration>();
        
        // Use WebPortalCredentials directly
        string? logLevelDebug = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Debug;
        string? logLevelTrace = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Trace;
        string? logLevelInformation = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Information;
        string? logLevelWarning = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Warning;
        string? logLevelError = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Error;
        string? logLevelCritical = WebPortalCredentials.TimeManagementServiceLogging?.LogLevel?.Critical;

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

        return configs;
    }
}

