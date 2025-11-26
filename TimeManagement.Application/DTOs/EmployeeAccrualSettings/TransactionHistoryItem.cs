namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class TransactionHistoryItem
{
    public int TransactionId { get; set; }
    public DateTime ProcessedOn { get; set; }
    public decimal Adjustment { get; set; }
    public string Details { get; set; } = string.Empty;
    public decimal BalanceAfter { get; set; }
}

public class GetTransactionHistoryResponse
{
    public List<TransactionHistoryItem> Data { get; set; } = new();
    public int TotalCount { get; set; }
}

