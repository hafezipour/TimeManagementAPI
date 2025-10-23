using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.Columns
{
    /// <summary>
    /// Represents the grid layout information for a column
    /// </summary>
    public class GridColumn
    {
        public int? RowNumber { get; set; }

        public int? ColumnNumber { get; set; }

        public int ColumnId { get; set; }

        public int DisplayOrder { get; set; }

        public string ColumnName { get; set; }

        public string BackgroundColor { get; set; }
    }

}
