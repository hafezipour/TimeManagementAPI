namespace TimeManagement.Application.DTOs.Layouts
{
    /// <summary>
    /// Layout model for saving rows and columns
    /// </summary>
    public class LayoutRowsColumnsRequest
    {
        public int LayoutId { get; set; }
        public int? Rows { get; set; }
        public int? Columns { get; set; }
    }
}
