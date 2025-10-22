using System.ComponentModel.DataAnnotations;

namespace TimeManagement.Domain.Models;

public class SaveColumnShiftRequest
{
    [Required]
    public int ColumnId { get; set; }
    
    [Required]
    public int ShiftId { get; set; }
    
    [Required]
    public int LayoutId { get; set; }
    
    public int? DisplayOrder { get; set; }
}
