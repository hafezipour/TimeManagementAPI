using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Request model for deleting a shift
    /// Used with usp_Shifts_Delete stored procedure
    /// </summary>
    public class DeleteShiftRequest
    {
        public int ShiftId { get; set; }
    }
}
