using System.Text.Json.Serialization;

namespace TimeManagement.Application.DTOs.Columns;

/// <summary>
/// Request model for getting columns
/// </summary>
public class GetColumnsRequest
{
    /// <summary>
    /// Layout ID to exclude columns already assigned to this layout (optional)
    /// </summary>
    [JsonPropertyName("layoutId")]
    public int? LayoutId { get; set; }
}
