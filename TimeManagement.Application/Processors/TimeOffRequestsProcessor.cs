using TimeManagement.Application.DTOs.TimeOffRequests;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Enums;
using TimeManagement.Infra.Repositories;
using System.Text.Json;

namespace TimeManagement.Application.Processors;

public class TimeOffRequestsProcessor : BaseProcessor
{
    private readonly TimeOffRequestsRepository _timeOffRequestsRepository;
    private readonly AccrualBanksRepository _accrualBanksRepository;
    private readonly AccrualTransactionsRepository _accrualTransactionsRepository;

    public TimeOffRequestsProcessor(
        TimeOffRequestsRepository timeOffRequestsRepository,
        AccrualBanksRepository accrualBanksRepository,
        AccrualTransactionsRepository accrualTransactionsRepository)
    {
        _timeOffRequestsRepository = timeOffRequestsRepository;
        _accrualBanksRepository = accrualBanksRepository;
        _accrualTransactionsRepository = accrualTransactionsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get"         => await GetTimeOffRequestsList(jsonData.FromJson<GetTimeOffRequestRequest>()),
                "save"        => await SaveTimeOffRequest(jsonData.FromJson<SaveTimeOffRequestRequest>()),
                "approve"     => await ApproveTimeOffRequest(jsonData.FromJson<ApproveTimeOffRequestRequest>()),
                "reject"      => await RejectTimeOffRequest(jsonData.FromJson<RejectTimeOffRequestRequest>()),
                "delete"      => await DeleteTimeOffRequest(jsonData.FromJson<DeleteTimeOffRequestRequest>()),
                _             => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
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

    public async Task<string> GetTimeOffRequestsList(GetTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.GetTimeOffRequestsList(
                request.TimeOffRequestId,
                request.UserId,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "DateCreated",
                request.SortDirection ?? "DESC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving time off requests: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> SaveTimeOffRequest(SaveTimeOffRequestRequest request)
    {
        try
        {
            // Check for overlap before saving (only for new requests, not updates)
            if (request.Id == null || request.Id == 0)
            {
                var overlapRequest = new CheckTimeOffOverlapRequest
                {
                    UserIds = request.UserId.HasValue ? new List<int> { request.UserId.Value } : new List<int>(),
                    FromDate = request.FromDate,
                    ToDate = request.ToDate,
                    FromTime = request.FromTime,
                    ToTime = request.ToTime,
                    ExcludeId = null // excludeId is null for new requests
                };
                
                var overlappingRequests = await CheckTimeOffOverlap(overlapRequest);
                if (overlappingRequests.Any())
                {
                    return new { 
                        success = false, 
                        message = "This user is already scheduled for the time off we are adding.",
                        overlappingRequests = overlappingRequests
                    }.ToJson();
                }
            }

            // Serialize request to JSON using camelCase to match usp_TimeOffRequests_Save OPENJSON contract
            var json = request.ToJson();

            var result = await _timeOffRequestsRepository.SaveTimeOffRequest(
                json,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving time off request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Check for overlapping time off requests for given users
    /// </summary>
    /// <param name="request">The overlap check request containing user IDs and date/time ranges</param>
    /// <returns>List of overlapping time off requests, empty list if no overlaps</returns>
    private async Task<List<OverlappingTimeOffRequest>> CheckTimeOffOverlap(CheckTimeOffOverlapRequest request)
    {
        var overlappingRequests = new List<OverlappingTimeOffRequest>();

        // Fetch candidate entries from database
        // StatusFilter = null means fetch both Pending (1) and Approved (2) for overlap checking
        var candidatesJson = await _timeOffRequestsRepository.GetTimeOffRequestsForUsers(
            request.UserIds,
            request.FromDate,
            request.ExcludeId,
            null, // StatusFilter = null (both Pending and Approved) for overlap checking
            CurrentUser.TenantID
        );

        // Parse candidates
        var candidates = candidatesJson.FromJson<List<TimeOffRequestsForUsers>>() ?? new List<TimeOffRequestsForUsers>();

        // Generate all occurrences for the new request
        var newOccurrences = GenerateOccurrences(
            request.FromDate.Date,
            request.ToDate.Date,
            request.FromTime,
            request.ToTime
        );

        // Generate all occurrences for existing requests and check for overlap
        foreach (var candidate in candidates)
        {
            if (candidate.StartFrom.HasValue && candidate.ValidUntil.HasValue && 
                candidate.StartTime.HasValue && candidate.EndTime.HasValue)
            {
                var existingOccurrences = GenerateOccurrences(
                    candidate.StartFrom.Value.Date,
                    candidate.ValidUntil.Value.Date,
                    candidate.StartTime.Value,
                    candidate.EndTime.Value
                );

                // Find all overlapping occurrences for this candidate
                var overlappingOccurrences = new List<TimeOffOccurrence>();
                
                foreach (var newOcc in newOccurrences)
                {
                    foreach (var existingOcc in existingOccurrences)
                    {
                        // Two datetime ranges overlap if: newStart < existingEnd AND newEnd > existingStart
                        if (newOcc.StartDateTime < existingOcc.EndDateTime && newOcc.EndDateTime > existingOcc.StartDateTime)
                        {
                            overlappingOccurrences.Add(existingOcc);
                        }
                    }
                }

                // If any overlaps found, add this candidate to the list
                if (overlappingOccurrences.Any())
                {
                    overlappingRequests.Add(new OverlappingTimeOffRequest
                    {
                        Id = candidate.Id,
                        TimeOffTypeName = candidate.TimeOffTypeName,
                        AccrualTypeName = candidate.AccrualTypeName,
                        StartFrom = candidate.StartFrom,
                        ValidUntil = candidate.ValidUntil,
                        StartTime = candidate.StartTime,
                        EndTime = candidate.EndTime,
                        OverlappingOccurrences = overlappingOccurrences
                            .GroupBy(o => new { o.StartDateTime, o.EndDateTime })
                            .Select(g => g.First())
                            .ToList()
                    });
                }
            }
        }

        return overlappingRequests;
    }

    public async Task<string> ApproveTimeOffRequest(ApproveTimeOffRequestRequest request)
    {
        try
        {
            // Validate balance and create transactions before approving
            var validationResult = await ValidateAndDeductBalance(request.Id);
            if (!validationResult.Success)
            {
                return new { success = false, message = validationResult.Message }.ToJson();
            }

            // Approve the time off request
            var result = await _timeOffRequestsRepository.ApproveTimeOffRequest(
                request.Id,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error approving time off request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Validates balance availability and deducts from accrual banks before approving time off request
    /// </summary>
    private async Task<(bool Success, string Message)> ValidateAndDeductBalance(int timeOffRequestId)
    {
        try
        {
            // First get the time off request by ID to get userId
            var requestListJson = await _timeOffRequestsRepository.GetTimeOffRequestsList(
                timeOffRequestId, null, CurrentUser.TenantID, 1, 1, "DateCreated", "DESC", null);
            
            var requestList = requestListJson.FromJson<List<TimeOffRequestResponse>>() ?? new List<TimeOffRequestResponse>();
            if (!requestList.Any())
            {
                return (false, "Time off request not found.");
            }

            var requestInfo = requestList.First();
            if (requestInfo.UserId == 0)
            {
                return (false, "Time off request is missing required information.");
            }

            var userId = requestInfo.UserId;

            // Validate schedule information is present in the request from GetTimeOffRequestsList
            if (!requestInfo.StartFrom.HasValue || !requestInfo.ValidUntil.HasValue ||
                !requestInfo.StartTime.HasValue || !requestInfo.EndTime.HasValue)
            {
                return (false, "Time off request schedule information is missing.");
            }

            // If no accrual type, no need to deduct balance
            if (!requestInfo.AccrualTypeId.HasValue || requestInfo.AccrualTypeId.Value == 0)
            {
                return (true, string.Empty);
            }

            var accrualTypeId = requestInfo.AccrualTypeId.Value;

            // Get accrual banks for this accrual type
            var banksJson = await _accrualBanksRepository.GetAccrualBanksByAccrualType(
                userId, accrualTypeId, CurrentUser.TenantID);

            var banks = banksJson.FromJson<List<AccrualBankForDeduction>>() ?? new List<AccrualBankForDeduction>();
            if (!banks.Any())
            {
                return (false, "No accrual banks found for this accrual type.");
            }

            // Calculate total hours/minutes using GenerateOccurrences
            var occurrences = GenerateOccurrences(
                requestInfo.StartFrom.Value.Date,
                requestInfo.ValidUntil.Value.Date,
                requestInfo.StartTime.Value,
                requestInfo.EndTime.Value
            );

            double totalHours = occurrences.Sum(o => (o.EndDateTime - o.StartDateTime).TotalHours);
            double totalMinutes = occurrences.Sum(o => (o.EndDateTime - o.StartDateTime).TotalMinutes);

            // Calculate required amount and normalized values (in hours) for each bank
            var bankReqs = banks.Select(b => new
            {
                Bank = b,
                Required = (b.AccrueUnit == (int)AccrueUnit.Minutes ? (decimal)totalMinutes : (decimal)totalHours) * b.DeductionMultiplier,
                RequiredInHours = (b.AccrueUnit == (int)AccrueUnit.Minutes ? (decimal)totalMinutes : (decimal)totalHours) * b.DeductionMultiplier / (b.AccrueUnit == (int)AccrueUnit.Minutes ? 60m : 1m),
                BalanceInHours = b.AccrueUnit == (int)AccrueUnit.Minutes ? b.CurrentBalance / 60m : b.CurrentBalance
            }).ToList();

            // Compare using normalized balances (all in hours)
            decimal combinedBalanceInHours = bankReqs.Sum(br => br.BalanceInHours);
            decimal combinedRequiredInHours = bankReqs.Sum(br => br.RequiredInHours);

            if (combinedBalanceInHours < combinedRequiredInHours)
            {
                return (false, $"Insufficient combined balance. Required: {combinedRequiredInHours} hours, Available: {combinedBalanceInHours} hours");
            }

            // Deduct proportionally from all banks based on their balance ratio
            var balanceUpdates = new List<object>();
            decimal remainingInHours = combinedRequiredInHours;

            for (int i = 0; i < bankReqs.Count; i++)
            {
                var br = bankReqs[i];
                decimal amountInHours = i == bankReqs.Count - 1 
                    ? remainingInHours 
                    : Math.Min(br.RequiredInHours * (br.BalanceInHours / combinedBalanceInHours), br.BalanceInHours);
                
                remainingInHours -= amountInHours;

                // Convert back to bank's original unit for deduction
                decimal deductionAmount = br.Bank.AccrueUnit == (int)AccrueUnit.Minutes ? amountInHours * 60m : amountInHours;

                balanceUpdates.Add(new
                {
                    bankId = br.Bank.Id,
                    userId = br.Bank.UserId,
                    accrualProfileId = br.Bank.AccrualProfileId,
                    accrualRulesSlotId = br.Bank.AccrualRulesSlotId,
                    currentBalance = br.Bank.CurrentBalance,
                    @operator = "-",
                    adjustmentAmount = deductionAmount,
                    notes = $"Time off request #{timeOffRequestId} deduction"
                });
            }

            // Update balances in bulk - this returns the result in the format needed for LogTransactions
            var balanceUpdatesJson = JsonSerializer.Serialize(balanceUpdates);
            var updateResult = await _accrualBanksRepository.UpdateBalances(
                balanceUpdatesJson, CurrentUser.LoginId, CurrentUser.TenantID);

            // Log transactions in bulk using the result from UpdateBalances
            // Pass SourceTypeID = 3 (TimeOffRequest) and SourceID = timeOffRequestId
            await _accrualTransactionsRepository.LogTransactions(
                updateResult, 
                CurrentUser.LoginId, 
                CurrentUser.TenantID,
                (int)AccrualTransactionSourceType.TimeOffRequest,
                timeOffRequestId);

            return (true, string.Empty);
        }
        catch (Exception ex)
        {
            return (false, $"Error validating balance: {ex.Message}");
        }
    }

    public async Task<string> RejectTimeOffRequest(RejectTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.RejectTimeOffRequest(
                request.Id,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error rejecting time off request: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> DeleteTimeOffRequest(DeleteTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.DeleteTimeOffRequest(
                request.TimeOffRequestId,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting time off request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Generate all occurrences (date-time ranges) for a time off request
    /// Example: fromDate = 12 Oct 2025, toDate = 16 Oct 2025, fromTime = 10pm, toTime = 2am
    /// Returns:
    /// - 12 Oct 2025 10pm - 13 Oct 2025 2am
    /// - 13 Oct 2025 10pm - 14 Oct 2025 2am
    /// - 14 Oct 2025 10pm - 15 Oct 2025 2am
    /// - 15 Oct 2025 10pm - 16 Oct 2025 2am
    /// </summary>
    private List<TimeOffOccurrence> GenerateOccurrences(DateTime startDate, DateTime endDate, TimeSpan startTime, TimeSpan endTime)
    {
        var occurrences = new List<TimeOffOccurrence>();
        var currentDate = startDate;
        bool spansMidnight = endTime < startTime;

        while (currentDate <= endDate)
        {
            var occurrenceStart = currentDate.Date.Add(startTime);
            DateTime occurrenceEnd;

            if (spansMidnight)
            {
                // Time spans midnight, so end is next day
                occurrenceEnd = currentDate.Date.AddDays(1).Add(endTime);
            }
            else
            {
                // Normal case, end is same day
                occurrenceEnd = currentDate.Date.Add(endTime);
            }

            occurrences.Add(new TimeOffOccurrence
            {
                StartDateTime = occurrenceStart,
                EndDateTime = occurrenceEnd
            });

            currentDate = currentDate.AddDays(1);
        }

        return occurrences;
    }
}

