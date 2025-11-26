namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class UpdateBalancesResponse
{
    public int BankId { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public decimal OldBalance { get; set; }
    public decimal NewBalance { get; set; }
    public string Operator { get; set; } = string.Empty;
    public decimal AdjustmentAmount { get; set; }
    public string? Notes { get; set; }
    public string? ErrorMessage { get; set; }
    public string Success { get; set; } = string.Empty;
}

