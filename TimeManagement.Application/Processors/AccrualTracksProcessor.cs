using System.Text.Json;
using TimeManagement.Application.DTOs.AccrualTracks;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualTracksProcessor : BaseProcessor
{
    private readonly AccrualTracksRepository _accrualTracksRepository;

    public AccrualTracksProcessor(AccrualTracksRepository accrualTracksRepository)
    {
        _accrualTracksRepository = accrualTracksRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveAccrualTrackRequest>() ?? new SaveAccrualTrackRequest()),
                "delete" => await Delete(jsonData.FromJson<DeleteAccrualTrackRequest>()),
                "get" => await GetAccrualTracks(jsonData.FromJson<GetAccrualTrackRequest>()),
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

    private async Task<string> Save(SaveAccrualTrackRequest accrualTrackDto)
    {
        try
        {
            var json = accrualTrackDto.ToJson();
            var result = await _accrualTracksRepository.SaveAccrualTrack(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving accrual track: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> Delete(DeleteAccrualTrackRequest? request)
    {
        try
        {
            if (request == null || request.AccrualTrackId <= 0)
            {
                return new { success = false, message = "Accrual Track Id is required." }.ToJson();
            }

            var result = await _accrualTracksRepository.DeleteAccrualTrack(request.AccrualTrackId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting accrual track: {ex.Message}" }.ToJson();
        }
    }

    private async Task<string> GetAccrualTracks(GetAccrualTrackRequest? request)
    {
        try
        {
            var result = await _accrualTracksRepository.GetAccrualTracks(request?.AccrualTrackId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual tracks: {ex.Message}" }.ToJson();
        }
    }
}

