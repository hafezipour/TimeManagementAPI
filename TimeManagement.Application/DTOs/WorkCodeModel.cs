namespace TimeManagement.Application.DTOs;

/// <summary>
/// Request model for saving a WorkCode (Create/Update)
/// Used with usp_WorkCodes_Save stored procedure
/// </summary>
public class SaveWorkCodeRequest
{
    public int? Id { get; set; }
    public string WorkCode { get; set; } = string.Empty;
    public string WorkCodeName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Category { get; set; }
    public string? ColorCode { get; set; }
    public string? TextColor { get; set; }
    public decimal? PayMultiplier { get; set; }
    public decimal? PayRate { get; set; }
    public bool? IsDefault { get; set; }
    public int? DisplayOrder { get; set; }
    public bool? IsCountsTowardWeeklyLimit { get; set; }
    public bool? IsCountsTowardMonthlyLimit { get; set; }
    public bool? IsIncludeInCallbackRankings { get; set; }
    public bool? IsExcludesFromCallbacks { get; set; }
    public bool? IsTradeable { get; set; }
    public decimal? MinTimeBufferHours { get; set; }
    public decimal? MaxTimeBufferHours { get; set; }
    public decimal? ExclusionRuleHours { get; set; }
    public int? LimitPerEmployeePerYear { get; set; }
    public bool? IsRequestable { get; set; }
    public bool? IsMasked { get; set; }
    public bool? IsActive { get; set; }
}

