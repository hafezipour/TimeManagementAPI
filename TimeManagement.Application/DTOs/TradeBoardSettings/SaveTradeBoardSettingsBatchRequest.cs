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
    public int Id { get; set; }
    public string SettingsName { get; set; } = string.Empty;
    public bool IsLimitTradesToMatchingLists { get; set; }
    public bool IsOnlyAllowDirectTrades { get; set; }
    public bool IsRequireApprovalBeforeSent { get; set; }
    public bool IsRequireApprovalAfterAccepted { get; set; }
    public bool IsRequireSecondApproval { get; set; }
    public bool IsApprovingUsersSeeOnlyTheirRequests { get; set; }
    public bool IsEnableShiftSwapFeature { get; set; }
    public bool IsColorCodeTradedShifts { get; set; }
    public string? TradedShiftColorCode { get; set; }
    public bool IsRequireManualLedgerApproval { get; set; }
    public bool IsUserSelectsApproval { get; set; }
    public bool IsActive { get; set; }
    public List<object> Rules { get; set; } = new();
}
