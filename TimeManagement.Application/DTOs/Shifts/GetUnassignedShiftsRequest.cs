using System.Text.Json.Serialization;

namespace TimeManagement.Application.DTOs.Shifts;

/// <summary>
/// Request model for getting unassigned shifts
/// </summary>
public class GetUnassignedShiftsRequest
{
    /// <summary>
    /// Layout ID to check for unassigned shifts within this layout
    /// </summary>
    [JsonPropertyName("layoutId")]
    public int LayoutId { get; set; }
}

/// <summary>
/// Short shift information for dropdowns/lookups
/// </summary>
public class ShiftShortInfo
{
    /// <summary>
    /// Shift ID
    /// </summary>
    [JsonPropertyName("id")]
    public int Id { get; set; }

    /// <summary>
    /// Shift name
    /// </summary>
    [JsonPropertyName("shiftName")]
    public string ShiftName { get; set; } = string.Empty;

    /// <summary>
    /// Shift code
    /// </summary>
    [JsonPropertyName("shiftCode")]
    public string ShiftCode { get; set; } = string.Empty;

    /// <summary>
    /// Background color
    /// </summary>
    [JsonPropertyName("backgroundColour")]
    public string BackgroundColour { get; set; } = string.Empty;

    /// <summary>
    /// Minimum positions
    /// </summary>
    [JsonPropertyName("minimumPositions")]
    public int MinimumPositions { get; set; }

    /// <summary>
    /// Maximum timeoffs
    /// </summary>
    [JsonPropertyName("maxTimeoffs")]
    public int MaxTimeoffs { get; set; }

    /// <summary>
    /// Is work shift
    /// </summary>
    [JsonPropertyName("isWorkShift")]
    public bool IsWorkShift { get; set; }

    /// <summary>
    /// Is self scheduling enabled
    /// </summary>
    [JsonPropertyName("isSelfSchedulingEnabled")]
    public bool IsSelfSchedulingEnabled { get; set; }
}
