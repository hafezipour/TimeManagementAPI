namespace TimeManagement.Application.DTOs.AccrualRules;

public class SaveAccrualRuleRequest
{
    public int? Id { get; set; }
    public int AccrualProfileId { get; set; }
    public int AccrualTypeId { get; set; }
    public decimal DeductionMultiplier { get; set; } = 1.00m;
    public bool IsStopAccruingEnabled { get; set; }
    public decimal? StopAccruingAfterReaching { get; set; }
    public List<SaveAccrualRuleSlotRequest> Slots { get; set; } = new();
}

public class SaveAccrualRuleSlotRequest
{
    public int? Id { get; set; }
    public decimal AccrueAmount { get; set; }
    public string AccrueUnit { get; set; } = string.Empty;
    public string AccrueFrequency { get; set; } = string.Empty;
    public int? AccrueFrequencyValue { get; set; }
    public int? WorkCodeId { get; set; }
    public int SortOrder { get; set; }
}

