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
            var dto = jsonData.FromJson<HolidayDto>();

            if (dto == null)
            {
                return new { success = false, message = "Invalid JSON data" }.ToJson();
            }

            return methodName.ToLower() switch
            {
                "add" => await Add(dto),
                "update" => await Update(dto),
                "delete" => await Delete(dto.Id),
                "getbyid" => await GetById(dto.Id),
                "getall" => await GetAll(),
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
    /// Add a new Holiday
    /// </summary>
    public async Task<string> Add(HolidayDto holidayDto)
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
    /// Update an existing Holiday
    /// </summary>
    public async Task<string> Update(HolidayDto holidayDto)
    {
        try
        {
            var json = holidayDto.ToJson();
            var result = await _holidaysRepository.SaveHoliday(json, CurrentUser.LoginId, CurrentUser.TenantID);
            
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error updating holiday: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Holiday by ID
    /// </summary>
    public async Task<string> Delete(int id)
    {
        try
        {
            var result = await _holidaysRepository.DeleteHoliday(id, CurrentUser.LoginId, CurrentUser.TenantID);
            
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting holiday: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Holiday by ID
    /// </summary>
    public async Task<string> GetById(int id)
    {
        try
        {
            var result = await _holidaysRepository.GetHolidays(id, CurrentUser.TenantID);
            
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving holiday: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get all Holidays
    /// </summary>
    public async Task<string> GetAll()
    {
        try
        {
            var result = await _holidaysRepository.GetHolidays(null, CurrentUser.TenantID);
            
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving holidays: {ex.Message}" }.ToJson();
        }
    }
}

