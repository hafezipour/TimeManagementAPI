using System.Text.Json.Serialization;

namespace TimeManagement.Application.DTOs.Columns;

/// <summary>
/// Request model for getting columns
/// </summary>
public class GetColumnsRequest
{
    public int? LayoutId { get; set; }
}

