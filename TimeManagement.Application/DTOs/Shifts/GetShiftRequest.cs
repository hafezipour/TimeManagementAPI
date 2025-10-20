using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Request model for getting shifts with server-side paging
    /// Used with usp_Shifts_Get stored procedure
    /// </summary>
    public class GetShiftRequest
    {
        public int? ShiftId { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public string? SortColumn { get; set; }
        public string? SortDirection { get; set; }
        public string? SearchTerm { get; set; }
        public int? StatusCustomTableValueId { get; set; }
    }

}
