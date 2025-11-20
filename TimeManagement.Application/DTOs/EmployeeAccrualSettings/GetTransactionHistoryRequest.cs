namespace TimeManagement.Application.DTOs.EmployeeAccrualSettings;

public class GetTransactionHistoryRequest
{
    public int AccrualBankId { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
    public string SortColumn { get; set; } = "ProcessedDate";
    public string SortDirection { get; set; } = "DESC";
}

