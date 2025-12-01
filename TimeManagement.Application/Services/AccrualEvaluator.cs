using Azure.Core;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using TimeManagement.Application.DTOs.AccrualEvaluations;
using TimeManagement.Application.DTOs.AccrualProfiles;
using TimeManagement.Application.DTOs.AccrualRules;
using TimeManagement.Application.DTOs.EmployeeAccrualSettings;
using TimeManagement.Application.Processors;
using TimeManagement.Infra.Extensions;
using TimeManagement.Infra.Repositories;
using WebPortal_TM.API.ExternalAuth;

namespace TimeManagement.Application.Services;

public class AccrualEvaluator
{
    private readonly IServiceScopeFactory _serviceScopeFactory;

    private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    public AccrualEvaluator(IServiceScopeFactory serviceScopeFactory)
    {
        _serviceScopeFactory = serviceScopeFactory;
    }

    #region Get Data Methods

    private async Task<List<EmployeeAccrualSettingsEvaluationResponse>> GetAccrualProfilesByProfileOrTrackIds(
        List<AccrualRuleEvaluationResponse> accrualRules, IServiceScope scope)
    {
        var accrualProfilesRepository = scope.ServiceProvider.GetRequiredService<AccrualProfilesRepository>();
        var employeeAccrualSettingsRepository = scope.ServiceProvider.GetRequiredService<EmployeeAccrualSettingsRepository>();
        var accrualBanksProcessor = scope.ServiceProvider.GetRequiredService<AccrualBanksProcessor>();
        // Call second stored procedure to get employee accrual settings
        string tenantIds = string.Join(',', accrualRules.Select(c => c.TenantId).Distinct().ToList());
        var employeeSettingsJson = await employeeAccrualSettingsRepository.GetEmployeeAccrualSettings(0, tenantIds);

        // Deserialize employee accrual settings response
        var employeeSettings = JsonSerializer.Deserialize<List<EmployeeAccrualSettingsEvaluationResponse>>(employeeSettingsJson, JsonOptions);
        var profileIds = employeeSettings.Where(e => e.AccrualProfileId.HasValue).Select(e => e.AccrualProfileId!.Value).Distinct().ToList();
        var trackIds = employeeSettings.Where(e => e.AccrualTrackId.HasValue).Select(e => e.AccrualTrackId!.Value).Distinct().ToList();

        var profileIdsJson = profileIds.Count > 0 ? JsonSerializer.Serialize(profileIds) : null;
        var trackIdsJson = trackIds.Count > 0 ? JsonSerializer.Serialize(trackIds) : null;

        var profilesJson = await accrualProfilesRepository.GetAccrualProfilesByProfileOrTrackIds(profileIdsJson, trackIdsJson, 0);
        var trackProfiles = JsonSerializer.Deserialize<List<AccrualProfileResponse>>(profilesJson, JsonOptions);

        var employeeSettingsWithProfileIds = employeeSettings.Where(c => c.AccrualProfileId > 0).ToList();
        var tracks = JsonSerializer.Deserialize<List<EmployeeAccrualSettingsEvaluationResponse>>(employeeSettings.Where(c => c.AccrualTrackId > 0).ToJson(), JsonOptions);

        foreach (var track in tracks)
        {
            //var hehe = data.Where(c => c.AccrualTrackId == track.AccrualTrackId).ToList();
            await accrualBanksProcessor.GetAccrualProfileIdFromTrack(, track.AccrualStartDate);
            //employeeSettingsWithProfileIds.Add
        }

        return employeeSettings;
    }

    #endregion

    /// <summary>
    /// Evaluates accrual rules and processes accruals
    /// </summary>
    public async Task Evaluate(CancellationToken cancellationToken = default)
    {
        // Create a scope to access scoped services
        using var scope = _serviceScopeFactory.CreateScope();
        var accrualRulesRepository = scope.ServiceProvider.GetRequiredService<AccrualRulesRepository>();
        var employeeAccrualSettingsRepository = scope.ServiceProvider.GetRequiredService<EmployeeAccrualSettingsRepository>();
        var accrualBanksRepository = scope.ServiceProvider.GetRequiredService<AccrualBanksRepository>();
        var accrualBanksProcessor = scope.ServiceProvider.GetRequiredService<AccrualBanksProcessor>();
        var accrualProfilesRepository = scope.ServiceProvider.GetRequiredService<AccrualProfilesRepository>();

        try
        {
            #region Get Accrual Rules

            var jsonResult = await accrualRulesRepository.GetAccrualRulesForEvaluation();
            var accrualRules = JsonSerializer.Deserialize<List<AccrualRuleEvaluationResponse>>(jsonResult, JsonOptions);

            #endregion

            #region Create Banks for missing banks using employee accrual settings table

            var employeeSettings = await GetAccrualProfilesByProfileOrTrackIds(accrualRules, accrualProfilesRepository, employeeAccrualSettingsRepository);
            List<CheckAndCreateBanksRequest> requests = new List<CheckAndCreateBanksRequest>();
            foreach (var accrualRule in accrualRules)
            {
                var settings = employeeSettings.Where(c => c.AccrualProfileId == accrualRule.AccrualProfileId).ToList();
                foreach (var setting in settings)
                {
                    var checkRequest = new CheckAndCreateBanksRequest
                    {
                        UserId = setting.UserId,
                        AccrualProfileId = setting.AccrualProfileId ?? 0,
                        AccrualTrackId = setting.AccrualTrackId,
                        AccrualTypeId = accrualRule.AccrualTypeId,
                        AccrualRuleId = accrualRule.AccrualRuleId,
                        AccrualRulesSlotId = accrualRule.Id,
                        TenantId = accrualRule.TenantId,
                    };
                    requests.Add(checkRequest);
                }
            }
            var tenants = requests.Select(c => c.TenantId).Distinct().ToList();
            foreach (var tenantId in tenants)
            {
                accrualBanksProcessor.SetCurrentUser(new Domain.Models.LoggedInUser() { LoginId = -1, TenantID = tenantId });
                var bankInfo = await accrualBanksProcessor.CheckAndCreateBank(requests);
            }

            #endregion

            #region Fetch Accrual Banks for all users and tenants

            var banksJson = await accrualBanksRepository.GetAccrualBanksForEvaluation();
            var banks = JsonSerializer.Deserialize<List<AccrualBankEvaluationResponse>>(banksJson, JsonOptions);

            #endregion

            #region Proceed here Rule by rule Evaluation for each accrual bank

            var banksByTenant = banks.GroupBy(b => b.TenantId).ToList();
            foreach (var tenantGroup in banksByTenant)
            {
                var tenantId = tenantGroup.Key;
                var tenantBanks = tenantGroup.ToList();
                var tenantEmployeeSettings = employeeSettings.Where(s => s.TenantId == tenantId).ToList();
                await GetAccrualBanksToUpdate(tenantBanks, accrualRules, tenantId, tenantEmployeeSettings, scope);
            }

            #endregion

        }
        catch (JsonException ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, "Error deserializing evaluation response");
            throw;
        }
        catch (Exception ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, "Error during accrual evaluation");
            throw;
        }
    }

    /// <summary>
    /// Processes accrual banks for a tenant in bulk - calculates missing accruals and updates banks
    /// </summary>
    private async Task GetAccrualBanksToUpdate(List<AccrualBankEvaluationResponse> banks, List<AccrualRuleEvaluationResponse> accrualRules,
        int tenantId, List<EmployeeAccrualSettingsEvaluationResponse> employeeSettings, IServiceScope scope)
    {
        var accrualTransactionsRepository = scope.ServiceProvider.GetRequiredService<AccrualTransactionsRepository>();
        var accrualBanksRepository = scope.ServiceProvider.GetRequiredService<AccrualBanksRepository>();
        var accrualTransactionsProcessor = scope.ServiceProvider.GetRequiredService<AccrualTransactionsProcessor>();

        try
        {
            // Set current user for processors
            accrualTransactionsProcessor.SetCurrentUser(new Domain.Models.LoggedInUser() { LoginId = -1, TenantID = tenantId });

            // Get all bank IDs for this tenant
            var bankIds = banks.Select(b => b.Id).ToList();

            // Get existing transactions for all banks
            var existingTransactions = await GetExistingTransactionsByBankIds(bankIds, tenantId, accrualTransactionsRepository);

            // Process each bank and rule combination
            var transactionsToAdd = new List<AccrualTransactionRequest>();
            var banksToUpdate = new List<AccrualBankUpdateRequest>();

            foreach (var bank in banks)
            {
                var accrualRule = accrualRules.FirstOrDefault(r => r.Id == bank.AccrualRulesSlotId);
                var employeeSetting = employeeSettings.FirstOrDefault(s => s.UserId == bank.UserId && s.AccrualProfileId == bank.AccrualProfileId && s.TenantId == tenantId);
                // Check tenure requirements if profile is based on years served
                if (employeeSetting != null && employeeSetting.IsBaseOnYearsServed)
                {
                    decimal tenure = CalculateTenure(bank.AccrualStartDate.Value);
                    bool isTenureValid = CheckTenureAgainstProfile(tenure, employeeSetting.FromYears, employeeSetting.ToYears);
                    if (!isTenureValid)
                    {
                        continue;
                    }
                }

                var result = CalculateAccrualPeriodsAndTransactions(bank, accrualRule, existingTransactions.Where(t => t.AccrualBankId == bank.Id).ToList());
                if (result.MissingTransactions.Count > 0)
                {
                    transactionsToAdd.AddRange(result.MissingTransactions);
                }

                if (result.BankUpdate != null)
                {
                    banksToUpdate.Add(result.BankUpdate);
                }
            }

            // Bulk insert transactions for this tenant
            if (transactionsToAdd.Count > 0)
            {
                await InsertAccrualTransactionsBulk(transactionsToAdd, tenantId, accrualTransactionsRepository);
            }

            // Bulk update banks for this tenant
            if (banksToUpdate.Count > 0)
            {
                await UpdateAccrualBanksBulk(banksToUpdate, tenantId, accrualBanksRepository);
            }
        }
        catch (Exception ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, $"Error processing accrual banks for tenant {tenantId}");
            throw;
        }
    }

    /// <summary>
    /// Gets existing transactions by bank IDs
    /// </summary>
    private async Task<List<AccrualTransactionResponse>> GetExistingTransactionsByBankIds(List<int> bankIds, int tenantId, AccrualTransactionsRepository repository)
    {
        try
        {
            // Convert bank IDs to JSON array
            var bankIdsJson = JsonSerializer.Serialize(bankIds);

            // Call stored procedure to get existing transactions
            var transactionsJson = await repository.GetTransactionsByBankIds(bankIdsJson, tenantId);

            if (string.IsNullOrEmpty(transactionsJson))
            {
                return new List<AccrualTransactionResponse>();
            }

            var transactions = JsonSerializer.Deserialize<List<AccrualTransactionResponse>>(transactionsJson, JsonOptions);
            return transactions ?? new List<AccrualTransactionResponse>();
        }
        catch (Exception ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, "Error getting existing transactions");
            return new List<AccrualTransactionResponse>();
        }
    }

    /// <summary>
    /// Calculates accrual periods and determines missing transactions
    /// </summary>
    private AccrualCalculationResult CalculateAccrualPeriodsAndTransactions(AccrualBankEvaluationResponse bank, AccrualRuleEvaluationResponse accrualRule, List<AccrualTransactionResponse> existingTransactions)
    {
        var result = new AccrualCalculationResult();
        DateTime? startDate = bank.LastAccruedPeriodDate ?? bank.AccrualStartDate;
        if (!startDate.HasValue)
        {
            CustomLogger.Log(LogLevel.Warning, null, $"No start date found for bank {bank.Id}");
            return result;
        }

        var allPeriods = CalculateAllAccrualPeriods(startDate.Value, DateTime.UtcNow.Date, accrualRule.AccrueFrequency, accrualRule.AccrueFrequencyValue);
        var existingPeriodDates = existingTransactions.Where(t => t.AccrualPeriodDate.HasValue).Select(t => t.AccrualPeriodDate!.Value.Date).ToHashSet();
        var missingPeriods = allPeriods.Where(p => !existingPeriodDates.Contains(p)).OrderBy(p => p).ToList();

        // Check if stop accruing is enabled and if limit is already reached
        if (accrualRule.IsStopAccruingEnabled && accrualRule.StopAccruingAfterReaching.HasValue)
        {
            if (bank.CurrentBalance >= accrualRule.StopAccruingAfterReaching.Value)
            {
                return result;
            }
        }

        // Calculate new balance
        decimal runningBalance = bank.CurrentBalance;
        DateTime? lastAccruedDate = bank.LastAccruedPeriodDate;

        foreach (var periodDate in missingPeriods)
        {
            // Calculate accrual amount for this period (always accrue full amount)
            decimal accrualAmount = CalculateAccrualAmount(accrualRule, periodDate);

            // Check if stop accruing is enabled and if adding this accrual would exceed the limit
            if (accrualRule.IsStopAccruingEnabled && accrualRule.StopAccruingAfterReaching.HasValue)
            {
                decimal potentialNewBalance = runningBalance + accrualAmount;

                // If adding this accrual would exceed the limit, stop processing
                if (potentialNewBalance > accrualRule.StopAccruingAfterReaching.Value)
                {
                    break;
                }
            }

            // Store old balance before adding accrual
            decimal oldBalance = runningBalance;
            runningBalance += accrualAmount;
            lastAccruedDate = periodDate;

            result.MissingTransactions.Add(new AccrualTransactionRequest
            {
                AccrualBankId = bank.Id,
                UserId = bank.UserId,
                AccrualProfileId = bank.AccrualProfileId,
                AccrualRulesSlotId = bank.AccrualRulesSlotId,
                AccrualPeriodDate = periodDate,
                Amount = accrualAmount,
                OldBalance = oldBalance,
                NewBalance = runningBalance,
                Description = $"Accrual for period {periodDate:yyyy-MM-dd}"
            });
        }

        // Create bank update request if there are new transactions
        if (result.MissingTransactions.Count > 0)
        {
            result.BankUpdate = new AccrualBankUpdateRequest
            {
                BankId = bank.Id,
                UserId = bank.UserId,
                AccrualProfileId = bank.AccrualProfileId,
                AccrualRulesSlotId = bank.AccrualRulesSlotId,
                CurrentBalance = bank.CurrentBalance,
                NewBalance = runningBalance,
                LastAccruedPeriodDate = lastAccruedDate
            };
        }

        return result;
    }

    /// <summary>
    /// Calculates all accrual period dates based on frequency
    /// </summary>
    private List<DateTime> CalculateAllAccrualPeriods(DateTime startDate, DateTime endDate, int accrueFrequency, decimal? accrueFrequencyValue)
    {
        var periods = new List<DateTime>();
        var currentDate = startDate.Date;

        // If frequency value is null or 0, default to 1
        decimal frequencyValue = accrueFrequencyValue ?? 1;

        // Add the start date as the first period
        if (currentDate <= endDate)
        {
            periods.Add(currentDate);
        }

        // Calculate subsequent periods
        while (currentDate <= endDate)
        {
            // Calculate next period based on frequency type
            currentDate = accrueFrequency switch
            {
                1 => currentDate.AddYears((int)frequencyValue), // Year
                2 => currentDate.AddMonths((int)(frequencyValue * 3)), // Quarter (3 months)
                3 => currentDate.AddMonths((int)frequencyValue), // Month
                4 => currentDate.AddMonths((int)frequencyValue), // Months
                5 => currentDate.AddDays((int)frequencyValue), // Days
                _ => currentDate.AddMonths(1) // Default to monthly
            };

            if (currentDate <= endDate)
            {
                periods.Add(currentDate);
            }
        }

        return periods;
    }

    /// <summary>
    /// Calculates accrual amount for a given period
    /// </summary>
    private decimal CalculateAccrualAmount(AccrualRuleEvaluationResponse accrualRule, DateTime periodDate)
    {
        // For now, return the base accrual amount
        // This can be extended to handle different accrual units (hours, days, etc.)
        return accrualRule.AccrueAmount;
    }

    /// <summary>
    /// Inserts accrual transactions in bulk
    /// </summary>
    private async Task InsertAccrualTransactionsBulk(List<AccrualTransactionRequest> transactions, int tenantId, AccrualTransactionsRepository repository)
    {
        try
        {
            // Convert to LogTransactionsRequest format
            var logRequests = transactions.Select(t => new LogTransactionsRequest
            {
                BankId = t.AccrualBankId,
                UserId = t.UserId,
                AccrualProfileId = t.AccrualProfileId,
                AccrualRulesSlotId = t.AccrualRulesSlotId,
                OldBalance = t.OldBalance,
                NewBalance = t.NewBalance,
                Operator = "+",
                AdjustmentAmount = t.Amount,
                Notes = t.Description
            }).ToList();

            // Note: We need to extend LogTransactionsRequest or create a new method
            // that accepts AccrualPeriodDate. For now, we'll use the existing method
            // and update the stored procedure to handle AccrualPeriodDate
            var json = JsonSerializer.Serialize(logRequests);
            await repository.LogTransactionsWithPeriodDate(json, -1, tenantId);
        }
        catch (Exception ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, "Error inserting accrual transactions in bulk");
            throw;
        }
    }

    /// <summary>
    /// Updates accrual banks in bulk
    /// </summary>
    private async Task UpdateAccrualBanksBulk(List<AccrualBankUpdateRequest> bankUpdates, int tenantId, AccrualBanksRepository repository)
    {
        try
        {
            // Convert to UpdateBalancesRequest format
            var updateRequests = bankUpdates.Select(b => new UpdateBalancesRequest
            {
                BankId = b.BankId,
                UserId = b.UserId,
                AccrualProfileId = b.AccrualProfileId,
                AccrualRulesSlotId = b.AccrualRulesSlotId,
                CurrentBalance = b.CurrentBalance,
                Operator = "+",
                AdjustmentAmount = b.NewBalance - b.CurrentBalance,
                Notes = $"Accrual update - Last accrued: {b.LastAccruedPeriodDate:yyyy-MM-dd}"
            }).ToList();

            var json = JsonSerializer.Serialize(updateRequests);
            await repository.UpdateBalancesWithLastAccruedDate(json, -1, tenantId);
        }
        catch (Exception ex)
        {
            CustomLogger.Log(LogLevel.Error, ex, "Error updating accrual banks in bulk");
            throw;
        }
    }

    /// <summary>
    /// Checks if tenure falls within the profile's tenure range
    /// Logic: "Includes employees who worked at least the first number of years, but less than the second number"
    /// </summary>
    private bool CheckTenureAgainstProfile(decimal tenure, decimal? fromYears, decimal? toYears)
    {
        if (!fromYears.HasValue)
        {
            return true; // No tenure requirement
        }

        if (toYears.HasValue)
        {
            // Range: FromYears <= tenure < ToYears
            return tenure >= fromYears.Value && tenure < toYears.Value;
        }
        else
        {
            // Open-ended: tenure >= FromYears
            return tenure >= fromYears.Value;
        }
    }

    /// <summary>
    /// Calculates tenure (years of service) from AccrualStartDate
    /// </summary>
    private decimal CalculateTenure(DateTime accrualStartDate)
    {
        var now = DateTime.UtcNow;
        var years = now.Year - accrualStartDate.Year;

        // Adjust if the anniversary hasn't occurred this year
        if (now.Month < accrualStartDate.Month || (now.Month == accrualStartDate.Month && now.Day < accrualStartDate.Day))
        {
            years--;
        }

        // Calculate fractional years (months and days)
        var months = now.Month - accrualStartDate.Month;
        if (months < 0)
        {
            months += 12;
        }

        var days = now.Day - accrualStartDate.Day;
        if (days < 0)
        {
            // Adjust for month boundaries
            var daysInPreviousMonth = DateTime.DaysInMonth(now.Year, now.Month == 1 ? 12 : now.Month - 1);
            days += daysInPreviousMonth;
            months--;
            if (months < 0)
            {
                months += 12;
                years--;
            }
        }

        // Convert to decimal years (approximate: 1 month = 1/12 year, 1 day = 1/365.25 year)
        decimal fractionalYears = years + (months / 12.0m) + (days / 365.25m);

        return Math.Max(0, fractionalYears);
    }

    #region Helper Classes

    private class AccrualCalculationResult
    {
        public List<AccrualTransactionRequest> MissingTransactions { get; set; } = new();
        public AccrualBankUpdateRequest? BankUpdate { get; set; }
    }

    private class AccrualTransactionRequest
    {
        public int AccrualBankId { get; set; }
        public int UserId { get; set; }
        public int AccrualProfileId { get; set; }
        public int AccrualRulesSlotId { get; set; }
        public DateTime AccrualPeriodDate { get; set; }
        public decimal Amount { get; set; }
        public decimal OldBalance { get; set; }
        public decimal NewBalance { get; set; }
        public string Description { get; set; } = string.Empty;
    }

    private class AccrualTransactionResponse
    {
        public int AccrualBankId { get; set; }
        public DateTime? AccrualPeriodDate { get; set; }
        public decimal? Amount { get; set; }
        public decimal? BalanceAfter { get; set; }
        public DateTimeOffset? ProcessedDate { get; set; }
    }

    private class AccrualBankUpdateRequest
    {
        public int BankId { get; set; }
        public int UserId { get; set; }
        public int AccrualProfileId { get; set; }
        public int AccrualRulesSlotId { get; set; }
        public decimal CurrentBalance { get; set; }
        public decimal NewBalance { get; set; }
        public DateTime? LastAccruedPeriodDate { get; set; }
    }

    #endregion
}

