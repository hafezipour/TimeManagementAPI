namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class EmployeeAccrualSettingsEvaluationResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int? AccrualProfileId { get; set; }
    public DateTime AccrualStartDate { get; set; }
    public bool IsActive { get; set; }
    public int TenantId { get; set; }
    public int CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTimeOffset DateCreated { get; set; }
    public DateTimeOffset? DateUpdated { get; set; }
    
    // Accrual Profile Information (for tenure checking)
    public bool IsBaseOnYearsServed { get; set; }
    public decimal? FromYears { get; set; }
    public decimal? ToYears { get; set; }
}

