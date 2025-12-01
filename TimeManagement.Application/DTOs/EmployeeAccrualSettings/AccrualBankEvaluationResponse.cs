namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class AccrualBankEvaluationResponse
{
    public int Id { get; set; }
    public int TenantId { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int AccrualTypeId { get; set; }
    public int AccrualRuleId { get; set; }
    public decimal CurrentBalance { get; set; }
    public decimal UsedBalance { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public int CreatedBy { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    public int? UpdatedBy { get; set; }
    //public DateTime? AccrualStartDate { get; set; }
    public DateTime? LastAccruedPeriodDate { get; set; }
}

