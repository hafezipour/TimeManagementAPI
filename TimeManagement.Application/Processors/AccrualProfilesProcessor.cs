using System.Text.Json;
using TimeManagement.Application.DTOs.AccrualProfiles;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualProfilesProcessor : BaseProcessor
{
    private readonly AccrualProfilesRepository _accrualProfilesRepository;

    public AccrualProfilesProcessor(AccrualProfilesRepository accrualProfilesRepository)
    {
        _accrualProfilesRepository = accrualProfilesRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveAccrualProfileRequest>() ?? new SaveAccrualProfileRequest()),
                "delete" => await Delete(jsonData.FromJson<DeleteAccrualProfileRequest>()),
                "get" => await GetAccrualProfiles(jsonData.FromJson<GetAccrualProfileRequest>()),
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

    private async Task<string> Save(SaveAccrualProfileRequest accrualProfileDto)
    {
        try
        {
            var json = accrualProfileDto.ToJson();
            var result = await _accrualProfilesRepository.SaveAccrualProfile(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving accrual profile: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> Delete(DeleteAccrualProfileRequest? request)
    {
        try
        {
            if (request == null || request.AccrualProfileId <= 0)
            {
                return new { success = false, message = "Accrual Profile Id is required." }.ToJson();
            }

            var result = await _accrualProfilesRepository.DeleteAccrualProfile(request.AccrualProfileId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting accrual profile: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> GetAccrualProfiles(GetAccrualProfileRequest? request)
    {
        try
        {
            var result = await _accrualProfilesRepository.GetAccrualProfiles(request?.AccrualProfileId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual profiles: {ex.Message}" }.ToJson();
        }
    }
}

