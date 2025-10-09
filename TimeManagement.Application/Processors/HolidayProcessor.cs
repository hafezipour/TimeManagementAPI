using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class HolidayProcessor : BaseProcessor
{
    private readonly HolidaysRepository _holidaysRepository;

    public HolidayProcessor(HolidaysRepository holidaysRepository)
    {
        _holidaysRepository = holidaysRepository;
    }
    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Add, Update, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveHolidayRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteHolidayRequest>()),
                "get" => await GetHolidays(jsonData.FromJson<GetHolidayRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (JsonException ex)
        {
            return new { success = false, message = $"JSON parsing error: {ex.Message}" }.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error processing request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save a Holiday (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveHolidayRequest holidayDto)
    {
        try
        {
            var json = holidayDto.ToJson();
            var result = await _holidaysRepository.SaveHoliday(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error adding holiday: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Holiday by ID
    /// </summary>
    public async Task<string> Delete(DeleteHolidayRequest request)
    {
        try
        {
            var result = await _holidaysRepository.DeleteHoliday(request.HolidayId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting holiday: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Holidays (all or by specific ID)
    /// </summary>
    public async Task<string> GetHolidays(GetHolidayRequest request)
    {
        try
        {
            var result = await _holidaysRepository.GetHolidays(request.HolidayId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving holiday: {ex.Message}" }.ToJson();
        }
    }

}

