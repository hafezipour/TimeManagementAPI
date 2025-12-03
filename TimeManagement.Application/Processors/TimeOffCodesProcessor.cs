using TimeManagement.Application.DTOs.TimeOffCodes;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class TimeOffCodesProcessor : BaseProcessor
{
    private readonly TimeOffCodesRepository _timeOffCodesRepository;

    public TimeOffCodesProcessor(TimeOffCodesRepository timeOffCodesRepository)
    {
        _timeOffCodesRepository = timeOffCodesRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await SaveTimeOffCode(jsonData.FromJson<SaveTimeOffCodeRequest>()),
                "delete" => await DeleteTimeOffCode(jsonData.FromJson<DeleteTimeOffCodeRequest>()),
                "get" => await GetTimeOffCodesList(jsonData.FromJson<GetTimeOffCodeRequest>()),
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

    public async Task<string> SaveTimeOffCode(SaveTimeOffCodeRequest request)
    {
        try
        {
            var json = request.ToJson();
            var result = await _timeOffCodesRepository.SaveTimeOffCode(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving time off code: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> DeleteTimeOffCode(DeleteTimeOffCodeRequest request)
    {
        try
        {
            var result = await _timeOffCodesRepository.DeleteTimeOffCode(request.TimeOffCodeId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting time off code: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetTimeOffCodesList(GetTimeOffCodeRequest request)
    {
        try
        {
            var result = await _timeOffCodesRepository.GetTimeOffCodesList(
                request.TimeOffCodeId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving time off codes: {ex.Message}" }.ToJson();
        }
    }
}

