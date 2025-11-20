namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class LogTransactionsResponse
{
    public int TransactionId { get; set; }
    public int AccrualBankId { get; set; }
    public int SourceTypeID { get; set; }
    public int SourceID { get; set; }
    public decimal Amount { get; set; }
    public decimal BalanceAfter { get; set; }
    public string? Description { get; set; }
    public DateTime ProcessedDate { get; set; }
    public bool Success { get; set; }
    public string? Message { get; set; }
}

