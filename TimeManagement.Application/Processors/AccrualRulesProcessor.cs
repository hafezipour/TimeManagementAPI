using System.Text.Json;
using TimeManagement.Application.DTOs.AccrualRules;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualRulesProcessor : BaseProcessor
{
    private readonly AccrualRulesRepository _accrualRulesRepository;

    public AccrualRulesProcessor(AccrualRulesRepository accrualRulesRepository)
    {
        _accrualRulesRepository = accrualRulesRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveAccrualRuleRequest>() ?? new SaveAccrualRuleRequest()),
                "get" => await GetAccrualRules(jsonData.FromJson<GetAccrualRuleRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private async Task<string> Save(SaveAccrualRuleRequest accrualRuleDto)
    {
        try
        {
            var json = accrualRuleDto.ToJson();
            var result = await _accrualRulesRepository.SaveAccrualRule(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving accrual rule: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> GetAccrualRules(GetAccrualRuleRequest? request)
    {
        try
        {
            var result = await _accrualRulesRepository.GetAccrualRules(
                request?.AccrualProfileId,
                request?.AccrualTypeId,
                CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual rules: {ex.Message}" }.ToJson();
        }
    }
}

