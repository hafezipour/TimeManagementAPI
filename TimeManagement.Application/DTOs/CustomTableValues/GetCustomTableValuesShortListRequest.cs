namespace TimeManagement.Application.DTOs.CustomTableValues;

public class GetCustomTableValuesShortListRequest
{
    public int? CustomTableId { get; set; }
    public bool IncludeInactive { get; set; } = false;
}


