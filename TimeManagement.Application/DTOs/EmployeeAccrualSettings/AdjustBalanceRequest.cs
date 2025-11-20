namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class AdjustBalanceRequest
{
    public int? AccrualProfileId { get; set; }
    public int AccrualRuleSlotId { get; set; }
    public int? AccrualTrackId { get; set; }
    public int? AccrualTypeId { get; set; }
    public int AccrualRuleId { get; set; }
    public string Operator { get; set; } = string.Empty; // '+' or '-'
    public decimal Balance { get; set; }
    public string? Notes { get; set; }
    public int? UserId { get; set; }
}

