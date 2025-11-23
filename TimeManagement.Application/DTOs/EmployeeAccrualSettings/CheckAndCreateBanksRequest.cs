namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class CheckAndCreateBanksRequest
{
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int AccrualTypeId { get; set; }
    public int AccrualRuleId { get; set; }
    public int AccrualRulesSlotId { get; set; }

    public int TenantId { get; set; }
}

