using System;

namespace TimeManagement.Application.DTOs.Columns
{
    /// <summary>
    /// Column model for staff scheduling columns
    /// </summary>
    public class Column
    {
        public int? Id { get; set; }
        public string? ColumnName { get; set; }
        public string? BackgroundColor { get; set; }
        public int TenantId { get; set; }
        public int CreatedBy { get; set; }
        public int? UpdatedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateUpdated { get; set; }
    }
}
