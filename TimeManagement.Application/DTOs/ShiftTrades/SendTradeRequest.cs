namespace TimeManagement.Application.DTOs.ShiftTrades;

public class SendTradeRequest
{
    public int? TradingEmployeeId { get; set; }
    public int? TradingShiftId { get; set; }
    public int? TradingAssignmentId { get; set; }
    public DateTime? TradingDate { get; set; }
    public bool IsSwap { get; set; }
    public int? AcceptingEmployeeId { get; set; }
    public int? AcceptingShiftId { get; set; }
    public int? AcceptingAssignmentId { get; set; }
    public DateTime? AcceptingDate { get; set; }
}

public class SendTradeResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int? TradeRequestId { get; set; }
}

