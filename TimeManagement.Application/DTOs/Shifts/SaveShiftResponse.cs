using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Response from usp_Shifts_Save
    /// </summary>
    public class SaveShiftResponse
    {
        public int Id { get; set; }
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
