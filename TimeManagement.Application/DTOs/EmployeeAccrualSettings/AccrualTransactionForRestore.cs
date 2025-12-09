namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class AccrualTransactionForRestore
{
    public int Id { get; set; }
    public int AccrualBankId { get; set; }
    public decimal Amount { get; set; }
    public decimal BalanceAfter { get; set; }
    public string? Description { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public decimal CurrentBalance { get; set; }
    public decimal DeductionMultiplier { get; set; }
    public int AccrueUnit { get; set; }
}

