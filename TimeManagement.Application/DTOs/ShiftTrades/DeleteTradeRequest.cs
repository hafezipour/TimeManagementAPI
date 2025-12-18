namespace TimeManagement.Application.DTOs.ShiftTrades;

/// <summary>
/// Request model for deleting a trade request
/// </summary>
public class DeleteTradeRequest
{
    public int TradeRequestId { get; set; }
}

/// <summary>
/// Response model for deleting a trade request
/// </summary>
public class DeleteTradeResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
}

/// <summary>
/// Request model for denying a trade request
/// </summary>
public class DenyTradeRequest
{
    public int TradeRequestId { get; set; }
}

/// <summary>
/// Response model for denying a trade request
/// </summary>
public class DenyTradeResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
}

