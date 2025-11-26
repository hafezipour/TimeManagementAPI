namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class CheckAndCreateBanksResponse
{
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int AccrualTypeId { get; set; }
    public int AccrualRuleId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public int BankId { get; set; }
    public bool IsNew { get; set; }
    public decimal CurrentBalance { get; set; }
}

