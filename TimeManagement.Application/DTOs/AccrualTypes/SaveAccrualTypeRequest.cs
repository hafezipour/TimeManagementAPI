namespace TimeManagement.Application.DTOs.AccrualTypes;

public class SaveAccrualTypeRequest
{
    public int? Id { get; set; }
    public string TypeCode { get; set; } = string.Empty;
    public string TypeName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CustomTableUnitId { get; set; }
    public bool? IsActive { get; set; }
}


