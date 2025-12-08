namespace TimeManagement.Application.DTOs.TimeOffRequests;

public class AccrualBankForDeduction
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualRulesSlotId { get; set; }
    public decimal CurrentBalance { get; set; }
    public int AccrueUnit { get; set; } // 1 = Hour, 2 = Minute (or as per your enum)
    public decimal DeductionMultiplier { get; set; }
}
