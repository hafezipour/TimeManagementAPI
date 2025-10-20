using System.Text.Json;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ScheduleProcessor : BaseProcessor
{
    private readonly SchedulesRepository _schedulesRepository;

    public ScheduleProcessor(SchedulesRepository schedulesRepository)
    {
        _schedulesRepository = schedulesRepository;
    }
    
    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Save, etc.)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<Schedule>()),
                "getbysource" => await GetBySource(jsonData.FromJson<GetScheduleRequest>()),
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

    /// <summary>
    /// Save a Schedule (Create/Update)
    /// </summary>
    public async Task<string> Save(Schedule scheduleDto)
    {
        try
        {
            var json = scheduleDto.ToJson();
            var result = await _schedulesRepository.SaveSchedule(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving schedule: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Schedule by Source ID and Source Type
    /// </summary>
    public async Task<string> GetBySource(GetScheduleRequest request)
    {
        try
        {
            var result = await _schedulesRepository.GetScheduleBySource(request.SourceId, request.SourceType, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving schedule: {ex.Message}" }.ToJson();
        }
    }
}

public class GetScheduleRequest
{
    public int SourceId { get; set; }
    public int SourceType { get; set; }
}

