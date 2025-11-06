using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class TradeBoardSettingsProcessor : BaseProcessor
{
    private readonly TradeBoardSettingsRepository _tradeBoardSettingsRepository;

    public TradeBoardSettingsProcessor(TradeBoardSettingsRepository tradeBoardSettingsRepository)
    {
        _tradeBoardSettingsRepository = tradeBoardSettingsRepository;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Get, Save)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "getlist" => await GetTradeBoardSettingsList(),
                "save" => await SaveTradeBoardSettings(jsonData),
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
    /// Get list of all Trade Board Settings with pagination and sorting
    /// </summary>
    public async Task<string> GetTradeBoardSettingsList()
    {
        try
        {
            var result = await _tradeBoardSettingsRepository.GetTradeBoardSettingsList(
                CurrentUser.TenantID,
                CurrentUser.LoginId
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving trade board settings list: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save Trade Board Settings
    /// </summary>
    public async Task<string> SaveTradeBoardSettings(string jsonData)
    {
        try
        {
            // jsonData is already a single settings object
            var result = await _tradeBoardSettingsRepository.SaveTradeBoardSettings(
                jsonData,
                CurrentUser.TenantID,
                CurrentUser.LoginId
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving trade board settings: {ex.Message}" }.ToJson();
        }
    }

}
