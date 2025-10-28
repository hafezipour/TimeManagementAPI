using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Shifts
{
    /// <summary>
    /// Represents a shift assigned to a column with schedule information
    /// </summary>
    public class ColumnShift
    {
        public int ColumnId { get; set; }

        public int ColumnShiftId { get; set; }
        public int ShiftId { get; set; }
        public int DisplayOrder { get; set; }
    }
}

