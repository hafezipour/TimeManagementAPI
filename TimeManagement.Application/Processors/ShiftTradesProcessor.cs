using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.DTOs.ShiftTrades;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Enums;
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
    private readonly ShiftAssignmentRepository _shiftAssignmentRepository;
    private readonly ShiftAssignmentProcessor _shiftAssignmentProcessor;

    public ShiftTradesProcessor(
        ShiftTradesRepository shiftTradesRepository,
        EmployeeJobCodeAssignmentRepository employeeJobCodeAssignmentRepository,
        EmployeeWorkCodeAssignmentRepository employeeWorkCodeAssignmentRepository,
        ShiftsRepository shiftsRepository,
        ShiftAssignmentRepository shiftAssignmentRepository,
        ShiftAssignmentProcessor shiftAssignmentProcessor)
    {
        _shiftTradesRepository = shiftTradesRepository;
        _employeeJobCodeAssignmentRepository = employeeJobCodeAssignmentRepository;
        _employeeWorkCodeAssignmentRepository = employeeWorkCodeAssignmentRepository;
        _shiftsRepository = shiftsRepository;
        _shiftAssignmentRepository = shiftAssignmentRepository;
        _shiftAssignmentProcessor = shiftAssignmentProcessor;
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
                "gettraderequests" => await GetTradeRequests(jsonData.FromJson<GetTradeRequestsRequest>()),
                "deletetraderequest" => await DeleteTradeRequest(jsonData.FromJson<DeleteTradeRequest>()),
                "denytraderequest" => await DenyTradeRequest(jsonData.FromJson<DenyTradeRequest>()),
                "approvetraderequest" => await ApproveTradeRequest(jsonData.FromJson<ApproveTradeRequest>()),
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

    #region Send Trade Request

    /// <summary>
    /// Send a trade request (mock implementation)
    /// </summary>
    public async Task<string> SendTradeRequest(SendTradeRequest request)
    {
        try
        {
            #region Request Validation

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

            #endregion

            #region Validation Data Fetching and Validation

            // Validate job codes and work codes before sending trade request
            var validationRequest = new ValidateJobCodesAndWorkCodesRequest
            {
                TradingEmployeeId = request.TradingEmployeeId.Value,
                TradingShiftId = request.TradingShiftId.Value,
                TradingAssignmentId = request.TradingAssignmentId,
                IsSwap = request.IsSwap,
                AcceptingEmployeeId = request.AcceptingEmployeeId,
                AcceptingShiftId = request.AcceptingShiftId,
                AcceptingAssignmentId = request.AcceptingAssignmentId
            };

            var validationData = await FetchValidationData(validationRequest);
            var validationResult = ValidateAllDatasets(validationData);

            // Check assignment conflicts
            var conflictResult = await CheckAssignmentConflicts(request, validationData, validationResult);
            if (!conflictResult.IsValid)
            {
                return new
                {
                    success = false,
                    message = "Trade request validation failed",
                    tradeRequestId = (int?)null,
                    validationResult = conflictResult
                }.ToJson();
            }

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

            #endregion

            #region Save Trade Request

            // Call repository method
            var result = await _shiftTradesRepository.SendTradeRequest(
                request.ToJson(),
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            // Parse repository result
            var repositoryResponse = JsonConvert.DeserializeObject<dynamic>(result);
            bool success = repositoryResponse?.success ?? false;
            string message = repositoryResponse?.message?.ToString() ?? "Failed to process trade request";
            int? tradeRequestId = repositoryResponse?.tradeRequestId != null ? (int?)repositoryResponse.tradeRequestId : null;

            if (!success || !tradeRequestId.HasValue)
            {
                return new
                {
                    success = false,
                    message = message,
                    tradeRequestId = tradeRequestId,
                    validationResult = validationResult
                }.ToJson();
            }

            #endregion

            #region Return Response

            // Include validation result in response
            return new
            {
                success = success,
                message = message,
                tradeRequestId = tradeRequestId,
                validationResult = validationResult
            }.ToJson();

            #endregion
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

        var acceptingEmployeeJobCodesJson = await _employeeJobCodeAssignmentRepository.GetShortList(
            request.AcceptingEmployeeId.Value, false, null, CurrentUser.TenantID);
        validationData.AcceptingEmployeeJobCodes = JsonConvert.DeserializeObject<List<EmployeeJobCodeAssignmentDto>>(acceptingEmployeeJobCodesJson)
            ?? new List<EmployeeJobCodeAssignmentDto>();

        var acceptingEmployeeWorkCodesJson = await _employeeWorkCodeAssignmentRepository.GetShortList(
            request.AcceptingEmployeeId.Value, false, null, CurrentUser.TenantID);
        validationData.AcceptingEmployeeWorkCodes = JsonConvert.DeserializeObject<List<EmployeeWorkCodeAssignmentDto>>(acceptingEmployeeWorkCodesJson)
            ?? new List<EmployeeWorkCodeAssignmentDto>();

        // Dataset 4: Accepting Employee and Shift (if swap)
        if (request.IsSwap && request.AcceptingEmployeeId.HasValue && request.AcceptingShiftId.HasValue)
        {
            var acceptingShiftJson = await _shiftsRepository.GetShift(request.AcceptingShiftId.Value, CurrentUser.TenantID);
            var acceptingShift = JsonConvert.DeserializeObject<SchedulingShift>(acceptingShiftJson) ?? new SchedulingShift
            {
                JobCodes = new List<ShiftJobCode>(),
                WorkCodes = new List<ShiftWorkCode>()
            };
            validationData.AcceptingShiftJobCodes = acceptingShift.JobCodes ?? new List<ShiftJobCode>();
            validationData.AcceptingShiftWorkCodes = acceptingShift.WorkCodes ?? new List<ShiftWorkCode>();
        }

        // Dataset 3b & 4b: Fetch assignments once for both trading and accepting (if they exist)
        var assignmentIds = new List<int>();
        if (request.TradingAssignmentId.HasValue)
        {
            assignmentIds.Add(request.TradingAssignmentId.Value);
        }
        if (request.IsSwap && request.AcceptingAssignmentId.HasValue)
        {
            assignmentIds.Add(request.AcceptingAssignmentId.Value);
        }

        if (assignmentIds.Any())
        {
            var assignmentIdsString = string.Join(",", assignmentIds);
            var assignmentsJson = await _shiftAssignmentRepository.GetShortListByAssignmentIds(
                assignmentIdsString, CurrentUser.TenantID);
            var allAssignments = JsonConvert.DeserializeObject<List<ShiftAssignmentShortListDto>>(assignmentsJson)
                ?? new List<ShiftAssignmentShortListDto>();

            // Find trading assignment
            if (request.TradingAssignmentId.HasValue)
            {
                validationData.TradingAssignment = allAssignments
                    .FirstOrDefault(a => a.id == request.TradingAssignmentId.Value);
            }

            // Find accepting assignment
            if (request.IsSwap && request.AcceptingAssignmentId.HasValue)
            {
                validationData.AcceptingAssignment = allAssignments
                    .FirstOrDefault(a => a.id == request.AcceptingAssignmentId.Value);
            }
        }

        return validationData;
    }

    /// <summary>
    /// Single method to validate all datasets (employee, shift, and assignment level)
    /// </summary>
    private ValidateJobCodesAndWorkCodesResponse ValidateAllDatasets(ValidationDataDto data)
    {
        bool isValid = true;
        List<string> validationMessages = new List<string>();

        #region Shift-Level Validations: Trading Employee

        // Validate Trading Employee Job Codes (only if shift has job codes)
        if (data.TradingShiftJobCodes != null && data.TradingShiftJobCodes.Any())
        {
            var missingJobCodes = data.TradingShiftJobCodes.Where(sjc =>
                !data.TradingEmployeeJobCodes.Any(ejc => ejc.jobCodeId == sjc.id)).ToList();

            if (missingJobCodes.Any())
            {
                isValid = false;
                validationMessages.Add("Trading employee is missing required job codes for the shift.");
            }
        }

        // Validate Trading Employee Work Codes (only if shift has work codes)
        if (data.TradingShiftWorkCodes != null && data.TradingShiftWorkCodes.Any())
        {
            var missingWorkCodes = data.TradingShiftWorkCodes.Where(swc =>
                !data.TradingEmployeeWorkCodes.Any(ewc => ewc.workCodeId == swc.id)).ToList();

            if (missingWorkCodes.Any())
            {
                isValid = false;
                validationMessages.Add("Trading employee is missing required work codes for the shift.");
            }
        }

        #endregion

        #region Shift-Level Validations: Accepting Employee (Swap Only)

        if (data.IsSwap)
        {
            // Validate Accepting Employee Job Codes (only if shift has job codes)
            if (data.AcceptingShiftJobCodes != null && data.AcceptingShiftJobCodes.Any())
            {
                var missingJobCodes = data.AcceptingShiftJobCodes.Where(sjc =>
                    !data.AcceptingEmployeeJobCodes.Any(ejc => ejc.jobCodeId == sjc.id)).ToList();

                if (missingJobCodes.Any())
                {
                    isValid = false;
                    validationMessages.Add("Accepting employee is missing required job codes for the shift.");
                }
            }

            // Validate Accepting Employee Work Codes (only if shift has work codes)
            if (data.AcceptingShiftWorkCodes != null && data.AcceptingShiftWorkCodes.Any())
            {
                var missingWorkCodes = data.AcceptingShiftWorkCodes.Where(swc =>
                    !data.AcceptingEmployeeWorkCodes.Any(ewc => ewc.workCodeId == swc.id)).ToList();

                if (missingWorkCodes.Any())
                {
                    isValid = false;
                    validationMessages.Add("Accepting employee is missing required work codes for the shift.");
                }
            }
        }

        #endregion

        #region Assignment-Level Validations

        if (data.TradingAssignment != null)
        {
            var tradingJobCodeIds = data.TradingAssignment.JobCodes?.Select(jc => jc.Id).ToList() ?? new List<int>();
            var tradingWorkCodeIds = data.TradingAssignment.WorkCodes?.Select(wc => wc.Id).ToList() ?? new List<int>();

            if (data.IsSwap)
            {
                // Swap: Check if trading assignment codes are present in accepting employee codes
                if (tradingJobCodeIds.Any())
                {
                    var acceptingEmployeeHasAnyTradingJobCode = tradingJobCodeIds.Any(tjc =>
                        data.AcceptingEmployeeJobCodes.Any(ejc => ejc.jobCodeId == tjc));

                    if (!acceptingEmployeeHasAnyTradingJobCode)
                    {
                        isValid = false;
                        validationMessages.Add("Accepting employee does not have any of the job codes assigned to the trading assignment.");
                    }
                }

                if (tradingWorkCodeIds.Any())
                {
                    var acceptingEmployeeHasAnyTradingWorkCode = tradingWorkCodeIds.Any(twc =>
                        data.AcceptingEmployeeWorkCodes.Any(ewc => ewc.workCodeId == twc));

                    if (!acceptingEmployeeHasAnyTradingWorkCode)
                    {
                        isValid = false;
                        validationMessages.Add("Accepting employee does not have any of the work codes assigned to the trading assignment.");
                    }
                }

                // Swap: Check if accepting assignment codes are present in trading employee codes
                if (data.AcceptingAssignment != null)
                {
                    var acceptingJobCodeIds = data.AcceptingAssignment.JobCodes?.Select(jc => jc.Id).ToList() ?? new List<int>();
                    var acceptingWorkCodeIds = data.AcceptingAssignment.WorkCodes?.Select(wc => wc.Id).ToList() ?? new List<int>();

                    if (acceptingJobCodeIds.Any())
                    {
                        var tradingEmployeeHasAnyAcceptingJobCode = acceptingJobCodeIds.Any(ajc =>
                            data.TradingEmployeeJobCodes.Any(ejc => ejc.jobCodeId == ajc));

                        if (!tradingEmployeeHasAnyAcceptingJobCode)
                        {
                            isValid = false;
                            validationMessages.Add("Trading employee does not have any of the job codes assigned to the accepting assignment.");
                        }
                    }

                    if (acceptingWorkCodeIds.Any())
                    {
                        var tradingEmployeeHasAnyAcceptingWorkCode = acceptingWorkCodeIds.Any(awc =>
                            data.TradingEmployeeWorkCodes.Any(ewc => ewc.workCodeId == awc));

                        if (!tradingEmployeeHasAnyAcceptingWorkCode)
                        {
                            isValid = false;
                            validationMessages.Add("Trading employee does not have any of the work codes assigned to the accepting assignment.");
                        }
                    }
                }
            }
            else
            {
                // One-way trade: Check if trading assignment codes are present in accepting employee codes
                // If assignment has job codes only → employee must have at least one matching job code
                // If assignment has work codes only → employee must have at least one matching work code
                // If assignment has both → both conditions must be met
                bool hasJobCodeRequirement = tradingJobCodeIds.Any();
                bool hasWorkCodeRequirement = tradingWorkCodeIds.Any();

                bool hasMatchingJobCode = false;
                bool hasMatchingWorkCode = false;

                if (hasJobCodeRequirement)
                {
                    hasMatchingJobCode = tradingJobCodeIds.Any(tjc =>
                        data.AcceptingEmployeeJobCodes.Any(ejc => ejc.jobCodeId == tjc));

                    if (!hasMatchingJobCode)
                    {
                        isValid = false;
                        validationMessages.Add("Accepting employee must have at least one job code from the trading assignment.");
                    }
                }

                if (hasWorkCodeRequirement)
                {
                    hasMatchingWorkCode = tradingWorkCodeIds.Any(twc =>
                        data.AcceptingEmployeeWorkCodes.Any(ewc => ewc.workCodeId == twc));

                    if (!hasMatchingWorkCode)
                    {
                        isValid = false;
                        validationMessages.Add("Accepting employee must have at least one work code from the trading assignment.");
                    }
                }
            }
        }

        #endregion

        #region Build Response

        return new ValidateJobCodesAndWorkCodesResponse
        {
            IsValid = isValid,
            ValidationMessages = validationMessages
        };

        #endregion
    }

    /// <summary>
    /// Check assignment conflicts for trade requests
    /// </summary>
    private async Task<ValidateJobCodesAndWorkCodesResponse> CheckAssignmentConflicts(
        SendTradeRequest request,
        ValidationDataDto validationData,
        ValidateJobCodesAndWorkCodesResponse validationResult)
    {
        _shiftAssignmentProcessor.SetCurrentUser(this.CurrentUser);

        bool isValid = validationResult.IsValid;
        var validationMessages = new List<string>(validationResult.ValidationMessages);

        // Check conflicts for trading assignment -> accepting employee (for both swap and one-way trade)
        if (request.TradingAssignmentId.HasValue && request.TradingDate.HasValue &&
            validationData.TradingAssignment != null && request.AcceptingEmployeeId.HasValue)
        {
            // Filter job codes and work codes to only those the accepting employee has
            var acceptingEmployeeJobCodeIds = validationData.AcceptingEmployeeJobCodes.Select(ejc => ejc.jobCodeId).ToList();
            var acceptingEmployeeWorkCodeIds = validationData.AcceptingEmployeeWorkCodes.Select(ewc => ewc.workCodeId).ToList();

            var filteredJobCodeIds = validationData.TradingAssignment.JobCodes?
                .Where(jc => acceptingEmployeeJobCodeIds.Contains(jc.Id))
                .Select(jc => jc.Id.ToString())
                .ToList() ?? new List<string>();

            var filteredWorkCodeIds = validationData.TradingAssignment.WorkCodes?
                .Where(wc => acceptingEmployeeWorkCodeIds.Contains(wc.Id))
                .Select(wc => wc.Id.ToString())
                .ToList() ?? new List<string>();

            // Build schedule: Daily type, StartFrom and ValidUntil same as selected date
            var selectedDate = request.TradingDate.Value.Date;
            var schedule = new ScheduleRequest
            {
                ShiftId = request.TradingShiftId.Value,
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1,
                StartFrom = selectedDate,
                ValidUntil = selectedDate,
                EndType = (int)EndType.OnDate,
                IsActive = true,
                ScheduleWithoutTimes = false
            };

            // Use times from request if available
            if (request.TradingUserAssignmentFromTime.HasValue && request.TradingUserAssignmentToTime.HasValue)
            {
                schedule.StartTime = request.TradingUserAssignmentFromTime.Value.ToString(@"hh\:mm\:ss");
                schedule.EndTime = request.TradingUserAssignmentToTime.Value.ToString(@"hh\:mm\:ss");
                schedule.ScheduleWithoutTimes = false;
            }
            else
            {
                schedule.ScheduleWithoutTimes = true;
            }

            var conflictRequest = new ScheduleEmployeeRequest
            {
                ShiftId = request.TradingShiftId.Value,
                UserId = request.AcceptingEmployeeId.Value,
                JobCodeIds = filteredJobCodeIds.Any() ? string.Join(",", filteredJobCodeIds) : null,
                WorkCodeIds = filteredWorkCodeIds.Any() ? string.Join(",", filteredWorkCodeIds) : null,
                Schedules = new List<ScheduleRequest> { schedule },
                TradingAssignmentId = request.AcceptingAssignmentId
            };

            var conflicts = await _shiftAssignmentProcessor.GetAssignmentConflictsAsync(conflictRequest);
            if (conflicts != null && conflicts.Any())
            {
                isValid = false;
                validationMessages.Add($"Conflicts detected for accepting employee on {selectedDate:yyyy-MM-dd}. " +
                    $"Conflicting assignments: {string.Join(", ", conflicts.Select(c => c.ExistingShiftName ?? "Unknown"))}");
            }
        }

        // For swaps: Check conflicts for accepting assignment -> trading employee
        if (request.IsSwap && request.AcceptingAssignmentId.HasValue && request.AcceptingDate.HasValue &&
            validationData.AcceptingAssignment != null && request.AcceptingShiftId.HasValue)
        {
            // Filter job codes and work codes to only those the trading employee has
            var tradingEmployeeJobCodeIds = validationData.TradingEmployeeJobCodes.Select(ejc => ejc.jobCodeId).ToList();
            var tradingEmployeeWorkCodeIds = validationData.TradingEmployeeWorkCodes.Select(ewc => ewc.workCodeId).ToList();

            var filteredJobCodeIds = validationData.AcceptingAssignment.JobCodes?
                .Where(jc => tradingEmployeeJobCodeIds.Contains(jc.Id))
                .Select(jc => jc.Id.ToString())
                .ToList() ?? new List<string>();

            var filteredWorkCodeIds = validationData.AcceptingAssignment.WorkCodes?
                .Where(wc => tradingEmployeeWorkCodeIds.Contains(wc.Id))
                .Select(wc => wc.Id.ToString())
                .ToList() ?? new List<string>();

            // Build schedule: Daily type, StartFrom and ValidUntil same as selected date
            var selectedDate = request.AcceptingDate.Value.Date;
            var schedule = new ScheduleRequest
            {
                ShiftId = request.AcceptingShiftId.Value,
                ScheduleType = (int)ScheduleType.Daily,
                RepeatEvery = 1,
                StartFrom = selectedDate,
                ValidUntil = selectedDate,
                EndType = (int)EndType.OnDate,
                IsActive = true,
                ScheduleWithoutTimes = false
            };

            // Use times from request if available
            if (request.AcceptingUserAssignmentFromTime.HasValue && request.AcceptingUserAssignmentToTime.HasValue)
            {
                schedule.StartTime = request.AcceptingUserAssignmentFromTime.Value.ToString(@"hh\:mm\:ss");
                schedule.EndTime = request.AcceptingUserAssignmentToTime.Value.ToString(@"hh\:mm\:ss");
                schedule.ScheduleWithoutTimes = false;
            }
            else
            {
                schedule.ScheduleWithoutTimes = true;
            }

            var conflictRequest = new ScheduleEmployeeRequest
            {
                ShiftId = request.AcceptingShiftId.Value,
                UserId = request.TradingEmployeeId.Value,
                JobCodeIds = filteredJobCodeIds.Any() ? string.Join(",", filteredJobCodeIds) : null,
                WorkCodeIds = filteredWorkCodeIds.Any() ? string.Join(",", filteredWorkCodeIds) : null,
                Schedules = new List<ScheduleRequest> { schedule },
                TradingAssignmentId = request.TradingAssignmentId
            };

            var conflicts = await _shiftAssignmentProcessor.GetAssignmentConflictsAsync(conflictRequest);
            if (conflicts != null && conflicts.Any())
            {
                isValid = false;
                validationMessages.Add($"Conflicts detected for trading employee on {selectedDate:yyyy-MM-dd}. " +
                    $"Conflicting assignments: {string.Join(", ", conflicts.Select(c => c.ExistingShiftName ?? "Unknown"))}");
            }
        }

        return new ValidateJobCodesAndWorkCodesResponse
        {
            IsValid = isValid,
            ValidationMessages = validationMessages
        };
    }

    #endregion

    /// <summary>
    /// Get trade requests with server-side paging
    /// </summary>
    public async Task<string> GetTradeRequests(GetTradeRequestsRequest request)
    {
        try
        {
            var pageNumber = request?.PageNumber ?? 1;
            var pageSize = request?.PageSize ?? 10;
            var sortColumn = request?.SortColumn ?? "DateCreated";
            var sortDirection = request?.SortDirection ?? "DESC";

            var result = await _shiftTradesRepository.GetTradeRequests(
                request?.UserId,
                request?.StatusCustomTableValueId,
                pageNumber,
                pageSize,
                sortColumn,
                sortDirection,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving trade requests: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a trade request and associated shift assignments
    /// </summary>
    public async Task<string> DeleteTradeRequest(DeleteTradeRequest request)
    {
        try
        {
            if (request == null || request.TradeRequestId <= 0)
            {
                return new { success = false, message = "Invalid trade request ID" }.ToJson();
            }

            var result = await _shiftTradesRepository.DeleteTradeRequest(
                request.TradeRequestId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting trade request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Deny a trade request (set StatusCustomTableValueId to 3)
    /// </summary>
    public async Task<string> DenyTradeRequest(DenyTradeRequest request)
    {
        try
        {
            if (request == null || request.TradeRequestId <= 0)
            {
                return new { success = false, message = "Invalid trade request ID" }.ToJson();
            }

            var result = await _shiftTradesRepository.DenyTradeRequest(
                request.TradeRequestId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error denying trade request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Approve a trade request (set StatusCustomTableValueId to 2)
    /// </summary>
    public async Task<string> ApproveTradeRequest(ApproveTradeRequest approvalRequest)
    {
        try
        {
            if (approvalRequest == null || approvalRequest.TradeRequestId <= 0)
            {
                return new { success = false, message = "Invalid trade request ID" }.ToJson();
            }

            var data = await _shiftTradesRepository.GetTradesDataForApproval(approvalRequest.TradeRequestId.ToString(), CurrentUser.TenantID);
            var request = (JsonConvert.DeserializeObject<List<SendTradeRequest>>(data)).FirstOrDefault();

            #region Validation Data Fetching and Validation

            // Validate job codes and work codes before sending trade request
            var validationRequest = new ValidateJobCodesAndWorkCodesRequest
            {
                TradingEmployeeId = request.TradingEmployeeId.Value,
                TradingShiftId = request.TradingShiftId.Value,
                TradingAssignmentId = request.TradingAssignmentId,
                IsSwap = request.IsSwap,
                AcceptingEmployeeId = request.AcceptingEmployeeId,
                AcceptingShiftId = request.AcceptingShiftId,
                AcceptingAssignmentId = request.AcceptingAssignmentId
            };

            var validationData = await FetchValidationData(validationRequest);
            var validationResult = ValidateAllDatasets(validationData);

            // Check assignment conflicts
            var conflictResult = await CheckAssignmentConflicts(request, validationData, validationResult);
            if (!conflictResult.IsValid)
            {
                return new
                {
                    success = false,
                    message = "Trade request validation failed",
                    tradeRequestId = (int?)null,
                    validationResult = conflictResult
                }.ToJson();
            }

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

            #endregion

            #region Create Assignment for Accepting Employee

            // Create shift assignments for both users after trade request is saved
            _shiftAssignmentProcessor.SetCurrentUser(this.CurrentUser);
            int? tradingAssignmentId = null;
            int? acceptingAssignmentId = null;

            // Create assignment for accepting employee (taking trading assignment)
            if (request.TradingAssignmentId.HasValue && request.TradingDate.HasValue &&
                request.AcceptingEmployeeId.HasValue && validationData.TradingAssignment != null)
            {
                // Filter job codes and work codes to only those the accepting employee has
                var acceptingEmployeeJobCodeIds = validationData.AcceptingEmployeeJobCodes.Select(ejc => ejc.jobCodeId).ToList();
                var acceptingEmployeeWorkCodeIds = validationData.AcceptingEmployeeWorkCodes.Select(ewc => ewc.workCodeId).ToList();

                var filteredJobCodeIds = validationData.TradingAssignment.JobCodes?
                    .Where(jc => acceptingEmployeeJobCodeIds.Contains(jc.Id))
                    .Select(jc => jc.Id.ToString())
                    .ToList() ?? new List<string>();

                var filteredWorkCodeIds = validationData.TradingAssignment.WorkCodes?
                    .Where(wc => acceptingEmployeeWorkCodeIds.Contains(wc.Id))
                    .Select(wc => wc.Id.ToString())
                    .ToList() ?? new List<string>();

                // Build schedule: Daily type, StartFrom and ValidUntil same as selected date
                var selectedDate = request.TradingDate.Value.Date;
                var schedule = new ScheduleRequest
                {
                    ShiftId = request.TradingShiftId.Value,
                    ScheduleType = (int)ScheduleType.Daily,
                    RepeatEvery = 1,
                    StartFrom = selectedDate,
                    ValidUntil = selectedDate,
                    EndType = (int)EndType.OnDate,
                    IsActive = true,
                    ScheduleWithoutTimes = false,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment
                };

                // Use times from request if available
                if (request.TradingUserAssignmentFromTime.HasValue && request.TradingUserAssignmentToTime.HasValue)
                {
                    schedule.StartTime = request.TradingUserAssignmentFromTime.Value.ToString(@"hh\:mm\:ss");
                    schedule.EndTime = request.TradingUserAssignmentToTime.Value.ToString(@"hh\:mm\:ss");
                    schedule.ScheduleWithoutTimes = false;
                }
                else
                {
                    schedule.ScheduleWithoutTimes = true;
                }

                var acceptingAssignmentRequest = new ScheduleEmployeeRequest
                {
                    ShiftId = request.TradingShiftId.Value,
                    UserId = request.AcceptingEmployeeId.Value,
                    JobCodeIds = filteredJobCodeIds.Any() ? string.Join(",", filteredJobCodeIds) : null,
                    WorkCodeIds = filteredWorkCodeIds.Any() ? string.Join(",", filteredWorkCodeIds) : null,
                    Schedules = new List<ScheduleRequest> { schedule },
                    IsTraded = true,
                    TradingUserAssignmentId = request.TradingAssignmentId,
                    IsSwap = request.IsSwap,
                    AcceptingUserAssignmentId = null, // This is the new accepting assignment
                    TradeRequestId = approvalRequest.TradeRequestId
                };

                var acceptingAssignmentResult = await _shiftAssignmentProcessor.SaveAssignmentAndProcessSchedules(acceptingAssignmentRequest);
                var acceptingAssignmentResponse = JsonConvert.DeserializeObject<dynamic>(acceptingAssignmentResult);
                if (acceptingAssignmentResponse?.success == true && acceptingAssignmentResponse?.id != null)
                {
                    acceptingAssignmentId = (int?)acceptingAssignmentResponse.id;
                }
            }

            #endregion

            #region Create Assignment for Trading Employee (Swap)

            // For swaps: Create assignment for trading employee (taking accepting assignment)
            if (request.IsSwap && request.AcceptingAssignmentId.HasValue && request.AcceptingDate.HasValue &&
                validationData.AcceptingAssignment != null && request.AcceptingShiftId.HasValue)
            {
                // Filter job codes and work codes to only those the trading employee has
                var tradingEmployeeJobCodeIds = validationData.TradingEmployeeJobCodes.Select(ejc => ejc.jobCodeId).ToList();
                var tradingEmployeeWorkCodeIds = validationData.TradingEmployeeWorkCodes.Select(ewc => ewc.workCodeId).ToList();

                var filteredJobCodeIds = validationData.AcceptingAssignment.JobCodes?
                    .Where(jc => tradingEmployeeJobCodeIds.Contains(jc.Id))
                    .Select(jc => jc.Id.ToString())
                    .ToList() ?? new List<string>();

                var filteredWorkCodeIds = validationData.AcceptingAssignment.WorkCodes?
                    .Where(wc => tradingEmployeeWorkCodeIds.Contains(wc.Id))
                    .Select(wc => wc.Id.ToString())
                    .ToList() ?? new List<string>();

                // Build schedule: Daily type, StartFrom and ValidUntil same as selected date
                var selectedDate = request.AcceptingDate.Value.Date;
                var schedule = new ScheduleRequest
                {
                    ShiftId = request.AcceptingShiftId.Value,
                    ScheduleType = (int)ScheduleType.Daily,
                    RepeatEvery = 1,
                    StartFrom = selectedDate,
                    ValidUntil = selectedDate,
                    EndType = (int)EndType.OnDate,
                    IsActive = true,
                    ScheduleWithoutTimes = false,
                    SourceType = (int)ScheduleSourceTypes.ShiftAssignment
                };

                // Use times from request if available
                if (request.AcceptingUserAssignmentFromTime.HasValue && request.AcceptingUserAssignmentToTime.HasValue)
                {
                    schedule.StartTime = request.AcceptingUserAssignmentFromTime.Value.ToString(@"hh\:mm\:ss");
                    schedule.EndTime = request.AcceptingUserAssignmentToTime.Value.ToString(@"hh\:mm\:ss");
                    schedule.ScheduleWithoutTimes = false;
                }
                else
                {
                    schedule.ScheduleWithoutTimes = true;
                }

                var tradingAssignmentRequest = new ScheduleEmployeeRequest
                {
                    ShiftId = request.AcceptingShiftId.Value,
                    UserId = request.TradingEmployeeId.Value,
                    JobCodeIds = filteredJobCodeIds.Any() ? string.Join(",", filteredJobCodeIds) : null,
                    WorkCodeIds = filteredWorkCodeIds.Any() ? string.Join(",", filteredWorkCodeIds) : null,
                    Schedules = new List<ScheduleRequest> { schedule },
                    IsTraded = true,
                    TradingUserAssignmentId = null, // This is the new trading assignment
                    IsSwap = request.IsSwap,
                    AcceptingUserAssignmentId = request.AcceptingAssignmentId, // Original accepting assignment
                    TradeRequestId = approvalRequest.TradeRequestId
                };

                var tradingAssignmentResult = await _shiftAssignmentProcessor.SaveAssignmentAndProcessSchedules(tradingAssignmentRequest);
                var tradingAssignmentResponse = JsonConvert.DeserializeObject<dynamic>(tradingAssignmentResult);
                if (tradingAssignmentResponse?.success == true && tradingAssignmentResponse?.id != null)
                {
                    tradingAssignmentId = (int?)tradingAssignmentResponse.id;
                }
            }

            #endregion

            #region Update Assignments with Trade Fields

            // Update assignments with trade-related fields
            // Accepting assignment: accepting employee taking trading assignment
            if (acceptingAssignmentId.HasValue)
            {
                await _shiftAssignmentRepository.UpdateTradeFields(
                    acceptingAssignmentId.Value,
                    isTraded: true,
                    tradingUserAssignmentId: request.TradingAssignmentId, // Original trading assignment
                    isSwap: request.IsSwap,
                    acceptingUserAssignmentId: null, // This is the new accepting assignment
                    tradeRequestId: approvalRequest.TradeRequestId,
                    userId: CurrentUser.LoginId,
                    tenantId: CurrentUser.TenantID);
            }

            // Trading assignment: trading employee taking accepting assignment (swap only)
            if (tradingAssignmentId.HasValue)
            {
                await _shiftAssignmentRepository.UpdateTradeFields(
                    tradingAssignmentId.Value,
                    isTraded: true,
                    tradingUserAssignmentId: null, // This is the new trading assignment
                    isSwap: request.IsSwap,
                    acceptingUserAssignmentId: request.AcceptingAssignmentId, // Original accepting assignment
                    tradeRequestId: approvalRequest.TradeRequestId,
                    userId: CurrentUser.LoginId,
                    tenantId: CurrentUser.TenantID);
            }

            #endregion


            var result = await _shiftTradesRepository.ApproveTradeRequest(
                approvalRequest.TradeRequestId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error approving trade request: {ex.Message}" }.ToJson();
        }
    }
}

