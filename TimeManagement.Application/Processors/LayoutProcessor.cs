using System.Text.Json;
using TimeManagement.Application.DTOs.Layouts;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class LayoutProcessor : BaseProcessor
{
    private readonly LayoutRepository _layoutRepository;

    public LayoutProcessor(LayoutRepository layoutRepository)
    {
        _layoutRepository = layoutRepository;
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
                "save-rows-columns" => await SaveLayoutRowsColumns(jsonData.FromJson<LayoutRowsColumnsRequest>()),
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
    /// Save Layout Rows and Columns
    /// </summary>
    public async Task<string> SaveLayoutRowsColumns(LayoutRowsColumnsRequest layoutDto)
    {
        try
        {
            var json = layoutDto.ToJson();
            var result = await _layoutRepository.SaveLayoutRowsColumns(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving layout rows and columns: {ex.Message}" }.ToJson();
        }
    }
}
