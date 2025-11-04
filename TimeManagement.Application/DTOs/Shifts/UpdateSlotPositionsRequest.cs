using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Request model for updating shift slot positions (increase/decrease minimumPositions)
    /// Used with usp_Shifts_UpdateSlotPositions stored procedure
    /// </summary>
    public class UpdateSlotPositionsRequest
    {
        public int ShiftId { get; set; }
        public string Action { get; set; } // "increase" or "decrease"
    }
}

