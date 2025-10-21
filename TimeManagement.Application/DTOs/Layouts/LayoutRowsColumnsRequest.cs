namespace TimeManagement.Application.DTOs.Layouts
{
    /// <summary>
    /// Request model for saving layout rows and columns
    /// </summary>
    public class LayoutRowsColumnsRequest
    {
        public int LayoutId { get; set; }
        public int? Rows { get; set; }
        public int? Columns { get; set; }
    }
}