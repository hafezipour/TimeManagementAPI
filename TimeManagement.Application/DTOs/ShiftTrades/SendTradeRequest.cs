using System;
using TimeManagement.Domain.Models;
using TimeManagement.Application.DTOs.ShiftAssignments;

namespace TimeManagement.Application.DTOs.ShiftTrades;

public class SendTradeRequest
{
    public int? TradingEmployeeId { get; set; }
    public int? TradingShiftId { get; set; }
    public int? TradingAssignmentId { get; set; }
    public DateTime? TradingDate { get; set; }
    public TimeSpan? TradingUserAssignmentFromTime { get; set; }
    public TimeSpan? TradingUserAssignmentToTime { get; set; }
    public bool IsSwap { get; set; }
    public int? AcceptingEmployeeId { get; set; }
    public int? AcceptingShiftId { get; set; }
    public int? AcceptingAssignmentId { get; set; }
    public DateTime? AcceptingDate { get; set; }
    public TimeSpan? AcceptingUserAssignmentFromTime { get; set; }
    public TimeSpan? AcceptingUserAssignmentToTime { get; set; }
}

public class SendTradeResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int? TradeRequestId { get; set; }
}

public class ValidateJobCodesAndWorkCodesRequest
{
    public int TradingEmployeeId { get; set; }
    public int TradingShiftId { get; set; }
    public int? TradingAssignmentId { get; set; }
    public int? AcceptingAssignmentId { get; set; }
    public int? AcceptingEmployeeId { get; set; }
    public int? AcceptingShiftId { get; set; }
    public bool IsSwap { get; set; }
}

public class JobCodeValidationResult
{
    public int JobCodeId { get; set; }
    public string JobCodeName { get; set; }
    public string JobCode { get; set; }
    public bool EmployeeHasJobCode { get; set; }
    public bool IsValid { get; set; }
}

public class WorkCodeValidationResult
{
    public int WorkCodeId { get; set; }
    public string WorkCodeName { get; set; }
    public string WorkCode { get; set; }
    public bool IsRequired { get; set; }
    public bool EmployeeHasWorkCode { get; set; }
    public bool IsValid { get; set; }
}

public class ValidateJobCodesAndWorkCodesResponse
{
    public bool IsValid { get; set; }
    public List<string> ValidationMessages { get; set; } = new List<string>();

    // Assignment-level validation details (job codes and work codes)
    public List<JobCodeValidationResult>? TradingAssignmentJobCodes { get; set; }
    public List<WorkCodeValidationResult>? TradingAssignmentWorkCodes { get; set; }
    public List<JobCodeValidationResult>? AcceptingAssignmentJobCodes { get; set; }
    public List<WorkCodeValidationResult>? AcceptingAssignmentWorkCodes { get; set; }
}

// DTOs for employee job code and work code assignments from GetShortList
// Note: Property names match the stored procedure output (camelCase)
public class EmployeeJobCodeAssignmentDto
{
    public int id { get; set; }
    public int userId { get; set; }
    public int jobCodeId { get; set; }
    public string jobTitle { get; set; }
    public string jobCode { get; set; }
    public bool isActive { get; set; }
}

public class EmployeeWorkCodeAssignmentDto
{
    public int id { get; set; }
    public int userId { get; set; }
    public int workCodeId { get; set; }
    public string workCodeName { get; set; }
    public string workCode { get; set; }
    public string colorCode { get; set; }
    public bool isActive { get; set; }
}

// DTO for assignment short list (from usp_ShiftAssignment_GetShortListByAssignmentIds)
// Note: Property names match the stored procedure output (camelCase)
public class ShiftAssignmentShortListDto
{
    public int id { get; set; }
    public int userId { get; set; }
    public List<AssignmentWorkCode>? WorkCodes { get; set; }
    public List<AssignmentJobCode>? JobCodes { get; set; }
}

// DTO containing all 4 datasets for validation
public class ValidationDataDto
{
    public List<EmployeeJobCodeAssignmentDto> TradingEmployeeJobCodes { get; set; } = new List<EmployeeJobCodeAssignmentDto>();
    public List<EmployeeWorkCodeAssignmentDto> TradingEmployeeWorkCodes { get; set; } = new List<EmployeeWorkCodeAssignmentDto>();
    public List<ShiftJobCode> TradingShiftJobCodes { get; set; } = new List<ShiftJobCode>();
    public List<ShiftWorkCode> TradingShiftWorkCodes { get; set; } = new List<ShiftWorkCode>();
    public List<EmployeeJobCodeAssignmentDto> AcceptingEmployeeJobCodes { get; set; } = new List<EmployeeJobCodeAssignmentDto>();
    public List<EmployeeWorkCodeAssignmentDto> AcceptingEmployeeWorkCodes { get; set; } = new List<EmployeeWorkCodeAssignmentDto>();
    public List<ShiftJobCode> AcceptingShiftJobCodes { get; set; } = new List<ShiftJobCode>();
    public List<ShiftWorkCode> AcceptingShiftWorkCodes { get; set; } = new List<ShiftWorkCode>();
    public bool IsSwap { get; set; }

    // Assignment-level data for validation (using short list DTO)
    public ShiftAssignmentShortListDto? TradingAssignment { get; set; }
    public ShiftAssignmentShortListDto? AcceptingAssignment { get; set; }
}

