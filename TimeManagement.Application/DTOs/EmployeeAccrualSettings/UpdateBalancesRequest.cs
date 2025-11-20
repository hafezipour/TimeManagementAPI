namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class UpdateBalancesRequest
{
    public int BankId { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public decimal CurrentBalance { get; set; }
    public string Operator { get; set; } = string.Empty;
    public decimal AdjustmentAmount { get; set; }
    public string? Notes { get; set; }
}

