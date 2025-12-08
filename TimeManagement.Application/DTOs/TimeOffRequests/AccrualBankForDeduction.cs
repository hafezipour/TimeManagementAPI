namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class AccrualBankForDeduction
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public decimal CurrentBalance { get; set; }
    public int AccrueUnit { get; set; } // 1 = Minutes, 2 = Hours (AccrueUnit enum)
    public decimal DeductionMultiplier { get; set; }
}
