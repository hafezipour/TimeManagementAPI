using System.ComponentModel.DataAnnotations;

namespace TimeManagement.Domain.Models;

public class DeleteColumnShiftRequest
{
    [Required]
    public int ColumnId { get; set; }
    
    [Required]
    public int ShiftId { get; set; }
    
    [Required]
    public int LayoutId { get; set; }
}

