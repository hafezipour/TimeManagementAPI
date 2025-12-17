using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using TimeManagement.Application.DTOs.ShiftTrades;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;
using TimeManagement.Domain.Models;

namespace TimeManagement.Application.Processors;

public class ShiftTradesProcessor : BaseProcessor
{
    private readonly ShiftTradesRepository _shiftTradesRepository;
    private readonly EmployeeJobCodeAssignmentRepository _employeeJobCodeAssignmentRepository;
    private readonly EmployeeWorkCodeAssignmentRepository _employeeWorkCodeAssignmentRepository;
    private readonly ShiftsRepository _shiftsRepository;

    public ShiftTradesProcessor(
        ShiftTradesRepository shiftTradesRepository,
        EmployeeJobCodeAssignmentRepository employeeJobCodeAssignmentRepository,
        EmployeeWorkCodeAssignmentRepository employeeWorkCodeAssignmentRepository,
        ShiftsRepository shiftsRepository)
    {
        _shiftTradesRepository = shiftTradesRepository;
        _employeeJobCodeAssignmentRepository = employeeJobCodeAssignmentRepository;
        _employeeWorkCodeAssignmentRepository = employeeWorkCodeAssignmentRepository;
        _shiftsRepository = shiftsRepository;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "sendtraderequest" => await SendTradeRequest(jsonData.FromJson<SendTradeRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (System.Text.Json.JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Send a trade request (mock implementation)
    /// </summary>
    public async Task<string> SendTradeRequest(SendTradeRequest request)
    {
        try
        {
            // Validate request
            if (request == null)
            {
                return new { success = false, message = "Request is required" }.ToJson();
            }

            if (!request.TradingEmployeeId.HasValue)
            {
                return new { success = false, message = "Trading employee is required" }.ToJson();
            }

            if (!request.TradingShiftId.HasValue)
            {
                return new { success = false, message = "Trading shift is required" }.ToJson();
            }

            if (!request.TradingAssignmentId.HasValue)
            {
                return new { success = false, message = "Trading assignment is required" }.ToJson();
            }

            if (!request.TradingDate.HasValue)
            {
                return new { success = false, message = "Trading date is required" }.ToJson();
            }

            // If it's a swap, validate accepting user fields
            if (request.IsSwap)
            {
                if (!request.AcceptingEmployeeId.HasValue)
                {
                    return new { success = false, message = "Accepting employee is required for swap" }.ToJson();
                }

                if (!request.AcceptingShiftId.HasValue)
                {
                    return new { success = false, message = "Accepting shift is required for swap" }.ToJson();
                }

                if (!request.AcceptingAssignmentId.HasValue)
                {
                    return new { success = false, message = "Accepting assignment is required for swap" }.ToJson();
                }

                if (!request.AcceptingDate.HasValue)
                {
                    return new { success = false, message = "Accepting date is required for swap" }.ToJson();
                }
            }

            // Validate job codes and work codes before sending trade request
            var validationRequest = new ValidateJobCodesAndWorkCodesRequest
            {
                TradingEmployeeId = request.TradingEmployeeId.Value,
                TradingShiftId = request.TradingShiftId.Value,
                IsSwap = request.IsSwap,
                AcceptingEmployeeId = request.AcceptingEmployeeId,
                AcceptingShiftId = request.AcceptingShiftId
            };

            var validationData = await FetchValidationData(validationRequest);
            var validationResult = ValidateAllDatasets(validationData);

            // If validation fails, return validation result immediately
            if (!validationResult.IsValid)
            {
                return new
                {
                    success = false,
                    message = "Trade request validation failed",
                    tradeRequestId = (int?)null,
                    validationResult = validationResult
                }.ToJson();
            }

            // Convert request to JSON for repository
            var jsonData = JsonConvert.SerializeObject(request);

            // Call repository method
            var result = await _shiftTradesRepository.SendTradeRequest(
                jsonData,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            // Parse repository result
            var repositoryResponse = JsonConvert.DeserializeObject<dynamic>(result);
            bool success = repositoryResponse?.success ?? false;
            string message = repositoryResponse?.message?.ToString() ?? "Failed to process trade request";
            int? tradeRequestId = repositoryResponse?.tradeRequestId != null ? (int?)repositoryResponse.tradeRequestId : null;

            // Include validation result in response
            return new
            {
                success = success,
                message = message,
                tradeRequestId = tradeRequestId,
                validationResult = validationResult
            }.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error sending trade request: {ex.Message}" }.ToJson();
        }
    }

    
    /// <summary>
    /// Fetch all validation data from repositories
    /// </summary>
    private async Task<ValidationDataDto> FetchValidationData(ValidateJobCodesAndWorkCodesRequest request)
    {
        var validationData = new ValidationDataDto
        {
            IsSwap = request.IsSwap
        };

        // Dataset 1: Trading Employee Job Codes
        var tradingEmployeeJobCodesJson = await _employeeJobCodeAssignmentRepository.GetShortList(
            request.TradingEmployeeId, false, null, CurrentUser.TenantID);
        validationData.TradingEmployeeJobCodes = JsonConvert.DeserializeObject<List<EmployeeJobCodeAssignmentDto>>(tradingEmployeeJobCodesJson) 
            ?? new List<EmployeeJobCodeAssignmentDto>();

        // Dataset 2: Trading Employee Work Codes
        var tradingEmployeeWorkCodesJson = await _employeeWorkCodeAssignmentRepository.GetShortList(
            request.TradingEmployeeId, false, null, CurrentUser.TenantID);
        validationData.TradingEmployeeWorkCodes = JsonConvert.DeserializeObject<List<EmployeeWorkCodeAssignmentDto>>(tradingEmployeeWorkCodesJson) 
            ?? new List<EmployeeWorkCodeAssignmentDto>();

        // Dataset 3: Trading Shift Job Codes and Work Codes
        var tradingShiftJson = await _shiftsRepository.GetShift(request.TradingShiftId, CurrentUser.TenantID);
        var tradingShift = JsonConvert.DeserializeObject<SchedulingShift>(tradingShiftJson) ?? new SchedulingShift
        {
            JobCodes = new List<ShiftJobCode>(),
            WorkCodes = new List<ShiftWorkCode>()
        };
        validationData.TradingShiftJobCodes = tradingShift.JobCodes ?? new List<ShiftJobCode>();
        validationData.TradingShiftWorkCodes = tradingShift.WorkCodes ?? new List<ShiftWorkCode>();

        // Dataset 4: Accepting Employee and Shift (if swap)
        if (request.IsSwap && request.AcceptingEmployeeId.HasValue && request.AcceptingShiftId.HasValue)
        {
            var acceptingEmployeeJobCodesJson = await _employeeJobCodeAssignmentRepository.GetShortList(
                request.AcceptingEmployeeId.Value, false, null, CurrentUser.TenantID);
            validationData.AcceptingEmployeeJobCodes = JsonConvert.DeserializeObject<List<EmployeeJobCodeAssignmentDto>>(acceptingEmployeeJobCodesJson) 
                ?? new List<EmployeeJobCodeAssignmentDto>();

            var acceptingEmployeeWorkCodesJson = await _employeeWorkCodeAssignmentRepository.GetShortList(
                request.AcceptingEmployeeId.Value, false, null, CurrentUser.TenantID);
            validationData.AcceptingEmployeeWorkCodes = JsonConvert.DeserializeObject<List<EmployeeWorkCodeAssignmentDto>>(acceptingEmployeeWorkCodesJson) 
                ?? new List<EmployeeWorkCodeAssignmentDto>();

            var acceptingShiftJson = await _shiftsRepository.GetShift(request.AcceptingShiftId.Value, CurrentUser.TenantID);
            var acceptingShift = JsonConvert.DeserializeObject<SchedulingShift>(acceptingShiftJson) ?? new SchedulingShift
            {
                JobCodes = new List<ShiftJobCode>(),
                WorkCodes = new List<ShiftWorkCode>()
            };
            validationData.AcceptingShiftJobCodes = acceptingShift.JobCodes ?? new List<ShiftJobCode>();
            validationData.AcceptingShiftWorkCodes = acceptingShift.WorkCodes ?? new List<ShiftWorkCode>();
        }

        return validationData;
    }

    /// <summary>
    /// Single method to validate all 4 datasets
    /// </summary>
    private ValidateJobCodesAndWorkCodesResponse ValidateAllDatasets(ValidationDataDto data)
    {
        bool isValid = true;
        List<string> validationMessages = new List<string>();

        // Validate Trading Employee Job Codes (only if shift has job codes)
        var tradingJobCodesResult = new List<JobCodeValidationResult>();
        if (data.TradingShiftJobCodes != null && data.TradingShiftJobCodes.Any())
        {
            foreach (var shiftJobCode in data.TradingShiftJobCodes)
            {
                var employeeHasJobCode = data.TradingEmployeeJobCodes.Any(ejc => 
                    ejc.jobCodeId == shiftJobCode.id);

                tradingJobCodesResult.Add(new JobCodeValidationResult
                {
                    JobCodeId = shiftJobCode.id,
                    JobCodeName = shiftJobCode.jobTitle,
                    JobCode = shiftJobCode.jobCode,
                    EmployeeHasJobCode = employeeHasJobCode,
                    IsValid = employeeHasJobCode // All job codes are required
                });

                if (!employeeHasJobCode)
                {
                    isValid = false;
                }
            }

            if (tradingJobCodesResult.Any(jc => !jc.IsValid))
            {
                validationMessages.Add("Trading employee is missing required job codes for the shift.");
            }
        }

        // Validate Trading Employee Work Codes (only if shift has work codes)
        var tradingWorkCodesResult = new List<WorkCodeValidationResult>();
        if (data.TradingShiftWorkCodes != null && data.TradingShiftWorkCodes.Any())
        {
            foreach (var shiftWorkCode in data.TradingShiftWorkCodes)
            {
                var employeeHasWorkCode = data.TradingEmployeeWorkCodes.Any(ewc => 
                    ewc.workCodeId == shiftWorkCode.id);

                // All work codes are required
                tradingWorkCodesResult.Add(new WorkCodeValidationResult
                {
                    WorkCodeId = shiftWorkCode.id,
                    WorkCodeName = shiftWorkCode.workCodeName,
                    WorkCode = shiftWorkCode.workCode,
                    IsRequired = true,
                    EmployeeHasWorkCode = employeeHasWorkCode,
                    IsValid = employeeHasWorkCode
                });

                if (!employeeHasWorkCode)
                {
                    isValid = false;
                }
            }

            if (tradingWorkCodesResult.Any(wc => !wc.IsValid))
            {
                validationMessages.Add("Trading employee is missing required work codes for the shift.");
            }
        }

        // Validate Accepting Employee (if swap)
        var acceptingJobCodesResult = new List<JobCodeValidationResult>();
        var acceptingWorkCodesResult = new List<WorkCodeValidationResult>();

        if (data.IsSwap)
        {
            // Validate Accepting Employee Job Codes (only if shift has job codes)
            if (data.AcceptingShiftJobCodes != null && data.AcceptingShiftJobCodes.Any())
            {
                foreach (var shiftJobCode in data.AcceptingShiftJobCodes)
                {
                    var employeeHasJobCode = data.AcceptingEmployeeJobCodes.Any(ejc => 
                        ejc.jobCodeId == shiftJobCode.id);

                    acceptingJobCodesResult.Add(new JobCodeValidationResult
                    {
                        JobCodeId = shiftJobCode.id,
                        JobCodeName = shiftJobCode.jobTitle,
                        JobCode = shiftJobCode.jobCode,
                        EmployeeHasJobCode = employeeHasJobCode,
                        IsValid = employeeHasJobCode // All job codes are required
                    });

                    if (!employeeHasJobCode)
                    {
                        isValid = false;
                    }
                }

                if (acceptingJobCodesResult.Any(jc => !jc.IsValid))
                {
                    validationMessages.Add("Accepting employee is missing required job codes for the shift.");
                }
            }

            // Validate Accepting Employee Work Codes (only if shift has work codes)
            if (data.AcceptingShiftWorkCodes != null && data.AcceptingShiftWorkCodes.Any())
            {
                foreach (var shiftWorkCode in data.AcceptingShiftWorkCodes)
                {
                    var employeeHasWorkCode = data.AcceptingEmployeeWorkCodes.Any(ewc => 
                        ewc.workCodeId == shiftWorkCode.id);

                    // All work codes are required
                    acceptingWorkCodesResult.Add(new WorkCodeValidationResult
                    {
                        WorkCodeId = shiftWorkCode.id,
                        WorkCodeName = shiftWorkCode.workCodeName,
                        WorkCode = shiftWorkCode.workCode,
                        IsRequired = true,
                        EmployeeHasWorkCode = employeeHasWorkCode,
                        IsValid = employeeHasWorkCode
                    });

                    if (!employeeHasWorkCode)
                    {
                        isValid = false;
                    }
                }

                if (acceptingWorkCodesResult.Any(wc => !wc.IsValid))
                {
                    validationMessages.Add("Accepting employee is missing required work codes for the shift.");
                }
            }
        }

        return new ValidateJobCodesAndWorkCodesResponse
        {
            IsValid = isValid,
            ValidationMessages = validationMessages,
            //TradingJobCodes = tradingJobCodesResult,
            //TradingWorkCodes = tradingWorkCodesResult,
            //AcceptingJobCodes = acceptingJobCodesResult.Any() ? acceptingJobCodesResult : null,
            //AcceptingWorkCodes = acceptingWorkCodesResult.Any() ? acceptingWorkCodesResult : null
        };
    }
}

