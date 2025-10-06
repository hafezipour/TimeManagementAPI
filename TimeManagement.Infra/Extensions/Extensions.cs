using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

namespace TimeManagement.Infra.Extensions
{
    public static class CustomLogger
    {
        public static ILoggerFactory LoggerFactory { get; set; }
        public static ILogger CreateLogger<T>() => LoggerFactory.CreateLogger<T>();
        public static ILogger CreateLogger(string categoryName) => LoggerFactory.CreateLogger(categoryName);
        public static void Log(LogLevel level, Exception ex, string message)
        {
            ILogger logger = LoggerFactory.CreateLogger<object>();
            if (level == LogLevel.Debug)
                logger.LogDebug(ex, message);
            else if (level == LogLevel.Trace)
                logger.LogTrace(ex, message);
            else if (level == LogLevel.Information)
                logger.LogInformation(ex, message);
            else if (level == LogLevel.Warning)
                logger.LogWarning(ex, message);
            else if (level == LogLevel.Error)
                logger.LogError(ex, message);
            else if (level == LogLevel.Critical)
                logger.LogCritical(ex, message);
        }
    }

    public static class Extensions
    {
        public static string ToJson(this object obj)
        {
            return JsonSerializer.Serialize(obj);
        }

        public static T ChangeType<T>(object value)
        {
            var t = typeof(T);

            if (t.IsGenericType && t.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
            {
                if (value == null)
                {
                    return default(T);
                }

                t = Nullable.GetUnderlyingType(t);
            }

            return (T)Convert.ChangeType(value, t);
        }

        public static bool IsNull(this object value)
        {
            if (value == null)
                return true;
            else
                return false;
        }
    }
}
