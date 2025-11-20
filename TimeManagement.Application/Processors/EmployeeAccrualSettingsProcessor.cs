using System.Text.Json;
using TimeManagement.Application.DTOs.EmployeeAccrualSettings;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class EmployeeAccrualSettingsProcessor : BaseProcessor
{
    private readonly EmployeeAccrualSettingsRepository _employeeAccrualSettingsRepository;

    public EmployeeAccrualSettingsProcessor(
        EmployeeAccrualSettingsRepository employeeAccrualSettingsRepository)
    {
        _employeeAccrualSettingsRepository = employeeAccrualSettingsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveEmployeeAccrualSettingsRequest>() ?? new SaveEmployeeAccrualSettingsRequest()),
                "get" => await Get(jsonData.FromJson<GetEmployeeAccrualSettingsRequest>()),
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

    private async Task<string> Save(SaveEmployeeAccrualSettingsRequest request)
    {
        try
        {
            var json = request.ToJson();
            var result = await _employeeAccrualSettingsRepository.SaveEmployeeAccrualSettings(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving employee accrual settings: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> Get(GetEmployeeAccrualSettingsRequest? request)
    {
        try
        {
            if (request == null || request.UserId <= 0)
            {
                return new { success = false, message = "User Id is required." }.ToJson();
            }

            var result = await _employeeAccrualSettingsRepository.GetEmployeeAccrualSettings(request.UserId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee accrual settings: {ex.Message}" }.ToJson();
        }
    }

}

