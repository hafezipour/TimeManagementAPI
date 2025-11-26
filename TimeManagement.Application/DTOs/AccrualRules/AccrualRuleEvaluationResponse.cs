namespace TimeManagement.Application.DTOs.AccrualRules;

public class AccrualRuleEvaluationResponse
{
    public int Id { get; set; }
    public int AccrualRuleId { get; set; }
    public decimal AccrueAmount { get; set; }
    public int AccrueUnit { get; set; }
    public int AccrueFrequency { get; set; }
    public decimal? AccrueFrequencyValue { get; set; }
    public int? WorkCodeId { get; set; }
    public int SortOrder { get; set; }
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    public int TenantId { get; set; }
    
    // Accrual Rule Information
    public int RuleId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualTypeId { get; set; }
    public decimal DeductionMultiplier { get; set; }
    public bool IsStopAccruingEnabled { get; set; }
    public decimal? StopAccruingAfterReaching { get; set; }
    public int RuleCreatedBy { get; set; }
    public int? RuleUpdatedBy { get; set; }
    public DateTimeOffset RuleDateCreated { get; set; }
    public DateTimeOffset? RuleDateUpdated { get; set; }
    
    // Accrual Type Information
    public int TypeId { get; set; }
    public string TypeCode { get; set; } = string.Empty;
    public string TypeName { get; set; } = string.Empty;
    public string? TypeDescription { get; set; }
    public int? CustomTableUnitId { get; set; }
    public decimal? MaxBalance { get; set; }
    public decimal? MaxCarryOver { get; set; }
    public int? CarryOverExpiryMonths { get; set; }
    public bool? TypeIsActive { get; set; }
}

