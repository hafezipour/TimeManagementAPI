using System;

namespace TimeManagement.Domain.Models
{
    public class ErrorLoggerModel
    {
        public string LogLevel { get; set; }
        public string Data { get; set; }
        public string ExceptionMessage { get; set; }
        public string StackTrace { get; set; }
        public bool? IsInnerException { get; set; }
        public int? EventId { get; set; }
        public string EventName { get; set; }
        public int? ParentId { get; set; }
        public int? InnerExceptionLevel { get; set; }
        public string Environment { get; set; }
        public int? CreatedBy { get; set; }
        public string UserAgent { get; set; }
        public DateTime DateCreated { get; set; }
        public int TenantID { get; set; }
        public string IPAddress { get; set; }
    }
}
