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
                "getshortlist" => await GetShortList(),
                "save-rows-columns" => await SaveLayoutRowsColumns(jsonData.FromJson<LayoutRowsColumnsRequest>()),
                "save-grid-cells" => await SaveGridCells(jsonData.FromJson<SaveGridCellsRequest>()),
                "get-grid-cells" => await GetGridCells(jsonData.FromJson<GetGridCellsRequest>()),
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
    /// Get Short List of Layouts
    /// </summary>
    public async Task<string> GetShortList()
    {
        try
        {
            var result = await _layoutRepository.GetLayoutShortList(CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving layouts: {ex.Message}" }.ToJson();
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

    /// <summary>
    /// Save Grid Cells Data
    /// </summary>
    public async Task<string> SaveGridCells(SaveGridCellsRequest gridCellsDto)
    {
        try
        {
            var json = gridCellsDto.ToJson();
            var result = await _layoutRepository.SaveGridCells(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving grid cells: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Grid Cells Data
    /// </summary>
    public async Task<string> GetGridCells(GetGridCellsRequest request)
    {
        try
        {
            var result = await _layoutRepository.GetGridCells(request.LayoutId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving grid cells: {ex.Message}" }.ToJson();
        }
    }
}
