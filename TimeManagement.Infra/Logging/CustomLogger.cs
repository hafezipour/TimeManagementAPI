using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Text;
using TimeManagement.Domain.Models;
using TimeManagement.Infra.Extensions;
using log4net;
using log4net.Config;

namespace TimeManagement.Infra.Logging
{
    public class LoggerConfiguration
    {
        public LogLevel LogLevel { get; set; } = LogLevel.Error;
        public int EventId { get; set; } = 0;
    }

    public class CustomLogger : ILogger
    {
        private readonly string _name;
        private readonly List<LoggerConfiguration> _config;
        private readonly ILog _log4netLogger;

        public CustomLogger(string name, List<LoggerConfiguration> config)
        {
            _name = name;
            _config = config;
            _log4netLogger = LogManager.GetLogger(name);
        }

        public IDisposable BeginScope<TState>(TState state)
        {
            return null;
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return _config.Where(c => c.LogLevel == logLevel).Any();
        }

        /// <summary>
        /// this is automatically called and exception can be of any type and it can have # of inner exceptions so we extract all the inner exceptions as well
        /// </summary>
        /// <typeparam name="TState"></typeparam>
        /// <param name="logLevel"></param>
        /// <param name="eventId"></param>
        /// <param name="state"></param>
        /// <param name="exception"></param>
        /// <param name="formatter"></param>
        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            if (!IsEnabled(logLevel))
            {
                return;
            }
            try
            {
                List<ErrorLoggerModel> loggings = new List<ErrorLoggerModel>();
                var currentUser = new LoggedInUser();
                string ipAddress = "";
                if (ApiContext.Current != null && ApiContext.Current.User != null && ApiContext.Current.User.Identity != null)
                {
                    ipAddress = ApiContext.Current.Connection != null && ApiContext.Current.Connection.RemoteIpAddress != null ? ApiContext.Current.Connection.RemoteIpAddress.ToString() : "";
                    var identity = (ClaimsIdentity)ApiContext.Current.User.Identity;
                    if (identity.Claims != null && identity.Claims.Count() > 0)
                    {
                        currentUser = ApiContext.Current.User.Identity.LoginInfo();
                    }
                }
                var userAgent = ApiContext.Current != null && ApiContext.Current.Request != null && ApiContext.Current.Request.Headers != null ? ApiContext.Current.Request.Headers["User-Agent"].ToString() : "";
                
                if (exception != null)
                {
                    var listExceptions = new List<Exception>();
                    listExceptions.Add(exception);
                    Exception realerror = exception;

                    while (realerror.InnerException != null)//this is to fetch all the inner exceptions
                    {
                        realerror = realerror.InnerException;
                        listExceptions.Add(realerror);
                    }

                    int i = 0;
                    foreach (var exc in listExceptions)
                    {
                        loggings.Add(new ErrorLoggerModel()
                        {
                            LogLevel = logLevel.ToString(),
                            Data = exc.Data != null ? exc.Data.ToString() : null,
                            ExceptionMessage = state != null ? formatter(state, exc) : exc.Message,
                            StackTrace = exc.StackTrace,
                            IsInnerException = i > 0 ? true : false,
                            EventId = eventId != null ? eventId.Id : (int?)null,
                            EventName = eventId != null ? eventId.Name : null,
                            DateCreated = DateTime.Parse(DateTime.UtcNow.ToShortDateString() + " " + DateTime.UtcNow.ToShortTimeString()),
                            CreatedBy = currentUser?.LoginId,
                            InnerExceptionLevel = (i == 0 ? (int?)null : i),
                            Environment = "",
                            UserAgent = userAgent,
                            IPAddress = ipAddress,
                            TenantID = currentUser?.TenantID ?? 0
                        });
                        i++;
                    }
                }
                else
                {
                    loggings.Add(new ErrorLoggerModel()
                    {
                        LogLevel = logLevel.ToString(),
                        Data = null,
                        ExceptionMessage = formatter(state, exception),
                        StackTrace = null,
                        IsInnerException = false,
                        EventId = eventId != null ? eventId.Id : (int?)null,
                        EventName = eventId != null ? eventId.Name : null,
                        DateCreated = DateTime.Parse(DateTime.UtcNow.ToShortDateString() + " " + DateTime.UtcNow.ToShortTimeString()),
                        CreatedBy = currentUser?.LoginId,
                        InnerExceptionLevel = null,
                        Environment = "",
                        UserAgent = userAgent,
                        IPAddress = ipAddress,
                        TenantID = currentUser?.TenantID ?? 0
                    });
                }

                // Log to file using log4net with beautiful formatting
                foreach (var l in loggings)
                {
                    var logMessage = LogMessageFormatter.FormatLogMessage(l);
                    
                    switch (l.LogLevel.ToUpper())
                    {
                        case "DEBUG":
                            _log4netLogger.Debug(logMessage);
                            break;
                        case "TRACE":
                            _log4netLogger.Debug(logMessage); // log4net doesn't have trace, use debug
                            break;
                        case "INFORMATION":
                            _log4netLogger.Info(logMessage);
                            break;
                        case "WARNING":
                            _log4netLogger.Warn(logMessage);
                            break;
                        case "ERROR":
                            _log4netLogger.Error(logMessage);
                            break;
                        case "CRITICAL":
                            _log4netLogger.Fatal(logMessage);
                            break;
                        default:
                            _log4netLogger.Info(logMessage);
                            break;
                    }
                }
            }
            catch//Do Nothing here at all, it will create the deadlock, system down
            {

            }
        }
    }

    public class LoggerProvider : ILoggerProvider
    {
        private readonly List<LoggerConfiguration> _config;
        private readonly ConcurrentDictionary<string, CustomLogger> _loggers = new ConcurrentDictionary<string, CustomLogger>();
        
        public LoggerProvider(List<LoggerConfiguration> config)
        {
            _config = config;
        }
        
        public ILogger CreateLogger(string categoryName)
        {
            return _loggers.GetOrAdd(categoryName, name => new CustomLogger(name, _config));
        }
        
        public void Dispose()
        {
            _loggers.Clear();
        }
    }

    public static class LogMessageFormatter
    {
        public static string FormatLogMessage(ErrorLoggerModel logEntry)
        {
            var sb = new StringBuilder();
            sb.AppendLine("=================================================================");
            sb.AppendLine($"LOG ENTRY - {logEntry.LogLevel?.ToUpper()}");
            sb.AppendLine("=================================================================");
            sb.AppendLine($"Date Created: {logEntry.DateCreated:yyyy-MM-dd HH:mm:ss.fff}");
            sb.AppendLine($"User: {logEntry.CreatedBy?.ToString() ?? "Anonymous"}");
            sb.AppendLine($"Tenant ID: {logEntry.TenantID}");
            sb.AppendLine($"IP Address: {logEntry.IPAddress ?? "Unknown"}");
            sb.AppendLine($"User Agent: {logEntry.UserAgent ?? "Unknown"}");
            sb.AppendLine($"Event ID: {logEntry.EventId?.ToString() ?? "N/A"}");
            sb.AppendLine($"Event Name: {logEntry.EventName ?? "N/A"}");
            
            if (logEntry.IsInnerException == true)
            {
                sb.AppendLine($"Inner Exception Level: {logEntry.InnerExceptionLevel}");
            }
            
            sb.AppendLine("-----------------------------------------------------------------");
            sb.AppendLine($"Message: {logEntry.ExceptionMessage}");
            
            if (!string.IsNullOrEmpty(logEntry.Data))
            {
                sb.AppendLine($"Data: {logEntry.Data}");
            }
            
            if (!string.IsNullOrEmpty(logEntry.StackTrace))
            {
                sb.AppendLine("Stack Trace:");
                sb.AppendLine(logEntry.StackTrace);
            }
            
            sb.AppendLine("=================================================================");
            
            return sb.ToString();
        }
    }
}
