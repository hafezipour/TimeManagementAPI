using System.Text.Json;
using TimeManagement.Application.DTOs.AccrualTypes;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualTypesProcessor : BaseProcessor
{
    private readonly AccrualTypesRepository _accrualTypesRepository;

    public AccrualTypesProcessor(AccrualTypesRepository accrualTypesRepository)
    {
        _accrualTypesRepository = accrualTypesRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveAccrualTypeRequest>() ?? new SaveAccrualTypeRequest()),
                "delete" => await Delete(jsonData.FromJson<DeleteAccrualTypeRequest>()),
                "get" => await GetAccrualTypes(jsonData.FromJson<GetAccrualTypeRequest>()),
                "updateactivestatus" => await UpdateActiveStatus(jsonData.FromJson<UpdateAccrualTypeStatusRequest>()),
                "getshortlist" => await GetShortList(jsonData.FromJson<GetAccrualTypesShortListRequest>()),
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

    private async Task<string> Save(SaveAccrualTypeRequest accrualTypeDto)
    {
        try
        {
            var json = accrualTypeDto.ToJson();
            var result = await _accrualTypesRepository.SaveAccrualType(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving accrual type: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> Delete(DeleteAccrualTypeRequest? request)
    {
        try
        {
            if (request == null || request.AccrualTypeId <= 0)
            {
                return new { success = false, message = "Accrual Type Id is required." }.ToJson();
            }

            var result = await _accrualTypesRepository.DeleteAccrualType(request.AccrualTypeId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting accrual type: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> GetAccrualTypes(GetAccrualTypeRequest? request)
    {
        try
        {
            var result = await _accrualTypesRepository.GetAccrualTypes(request?.AccrualTypeId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual types: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> UpdateActiveStatus(UpdateAccrualTypeStatusRequest? request)
    {
        try
        {
            if (request == null || request.AccrualTypeId <= 0)
            {
                return new { success = false, message = "Accrual Type Id is required." }.ToJson();
            }

            var result = await _accrualTypesRepository.UpdateActiveStatus(request.AccrualTypeId, request.IsActive, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error updating accrual type status: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> GetShortList(GetAccrualTypesShortListRequest? request)
    {
        try
        {
            var result = await _accrualTypesRepository.GetAccrualTypesShortList(CurrentUser.TenantID, request?.IncludeInactive ?? false);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual types short list: {ex.Message}" }.ToJson();
        }
    }
}


