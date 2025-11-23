using Azure.Core;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using System.Text.Json.Serialization;
using TimeManagement.Application.DTOs.AccrualRules;
using TimeManagement.Application.DTOs.EmployeeAccrualSettings;
using TimeManagement.Application.Processors;
using TimeManagement.Infra.Extensions;
using TimeManagement.Infra.Repositories;

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

        try
        {
            #region Get Accrual Rules

            // Call first stored procedure to get all accrual rules for evaluation
            var jsonResult = await accrualRulesRepository.GetAccrualRulesForEvaluation();

            // Deserialize JSON response to DTOs
            var accrualRules = JsonSerializer.Deserialize<List<AccrualRuleEvaluationResponse>>(jsonResult, JsonOptions);

            if (accrualRules == null || accrualRules.Count == 0)
            {
                CustomLogger.Log(LogLevel.Information, null, "No accrual rules found for evaluation");
                return;
            }

            #endregion

            #region Create Banks for missing banks using employee accrual settings table

            // Extract unique profile IDs from the first SP results
            var profileIds = accrualRules
                .Select(r => r.AccrualProfileId)
                .Distinct()
                .Where(id => id > 0)
                .ToList();

            if (profileIds.Count == 0)
            {
                CustomLogger.Log(LogLevel.Information, null, "No valid profile IDs found in accrual rules");
                return;
            }

            // Convert profile IDs to JSON array
            var profileIdsJson = JsonSerializer.Serialize(profileIds);

            // Call second stored procedure to get employee accrual settings
            var employeeSettingsJson = await employeeAccrualSettingsRepository.GetEmployeeAccrualSettingsForEvaluation(profileIdsJson);

            // Deserialize employee accrual settings response
            var employeeSettings = JsonSerializer.Deserialize<List<EmployeeAccrualSettingsEvaluationResponse>>(employeeSettingsJson, JsonOptions);

            if (employeeSettings == null || employeeSettings.Count == 0)
            {
                CustomLogger.Log(LogLevel.Information, null, "No employee accrual settings found for the provided profile IDs");
                return;
            }
            //employeeSettings, accrualRules

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

            // Fetch all banks for all tenants and users
            var banksJson = await accrualBanksRepository.GetAccrualBanksForEvaluation();
            var banks = JsonSerializer.Deserialize<List<AccrualBankEvaluationResponse>>(banksJson, JsonOptions);

            if (banks == null || banks.Count == 0)
            {
                CustomLogger.Log(LogLevel.Information, null, "No accrual banks found");
            }
            else
            {
                CustomLogger.Log(LogLevel.Information, null, $"Retrieved {banks.Count} accrual banks for evaluation");
            }

            #endregion

            #region Proceed here Rule by rule Evaluation for each accrual bank



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
}

