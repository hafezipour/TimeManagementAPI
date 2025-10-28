using System.ComponentModel.DataAnnotations;

namespace TimeManagement.Domain.Models;

public class BatchUpdateShiftOrderRequest
{
    [Required]
    public int ColumnId { get; set; }
    
    [Required]
    public int LayoutId { get; set; }
    
    [Required]
    public List<ShiftDisplayOrderItem> Shifts { get; set; }
}

public class ShiftDisplayOrderItem
{
    [Required]
    public int ShiftId { get; set; }
    
    [Required]
    public int DisplayOrder { get; set; }
}

