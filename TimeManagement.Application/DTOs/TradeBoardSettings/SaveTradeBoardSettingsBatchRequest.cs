using System.Text.Json.Serialization;

namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request DTO for batch saving multiple trade board settings
/// </summary>
public class SaveTradeBoardSettingsBatchRequest
{
    [JsonPropertyName("settings")]
    public List<SaveTradeBoardSettingsRequest> Settings { get; set; } = new();
}

/// <summary>
/// Individual trade board settings item for batch save
/// </summary>
public class SaveTradeBoardSettingsRequest
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("settingsName")]
    public string SettingsName { get; set; } = string.Empty;

    [JsonPropertyName("isLimitTradesToMatchingLists")]
    public bool IsLimitTradesToMatchingLists { get; set; }

    [JsonPropertyName("isOnlyAllowDirectTrades")]
    public bool IsOnlyAllowDirectTrades { get; set; }

    [JsonPropertyName("isRequireApprovalBeforeSent")]
    public bool IsRequireApprovalBeforeSent { get; set; }

    [JsonPropertyName("isRequireApprovalAfterAccepted")]
    public bool IsRequireApprovalAfterAccepted { get; set; }

    [JsonPropertyName("isRequireSecondApproval")]
    public bool IsRequireSecondApproval { get; set; }

    [JsonPropertyName("isApprovingUsersSeeOnlyTheirRequests")]
    public bool IsApprovingUsersSeeOnlyTheirRequests { get; set; }

    [JsonPropertyName("isEnableShiftSwapFeature")]
    public bool IsEnableShiftSwapFeature { get; set; }

    [JsonPropertyName("isColorCodeTradedShifts")]
    public bool IsColorCodeTradedShifts { get; set; }

    [JsonPropertyName("tradedShiftColorCode")]
    public string? TradedShiftColorCode { get; set; }

    [JsonPropertyName("isRequireManualLedgerApproval")]
    public bool IsRequireManualLedgerApproval { get; set; }

    [JsonPropertyName("isUserSelectsApproval")]
    public bool IsUserSelectsApproval { get; set; }

    [JsonPropertyName("isActive")]
    public bool IsActive { get; set; }

    [JsonPropertyName("rules")]
    public List<object> Rules { get; set; } = new();
}
