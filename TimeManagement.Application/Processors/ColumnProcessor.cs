using System.Text.Json;
using TimeManagement.Application.DTOs.Columns;
using TimeManagement.Application.Extensions;
using TimeManagement.Domain.Models;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ColumnProcessor : BaseProcessor
{
    private readonly ColumnRepository _columnRepository;

    public ColumnProcessor(ColumnRepository columnRepository)
    {
        _columnRepository = columnRepository;
    }
    
    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Get, GetById, Save, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get" => await Get(jsonData.FromJson<GetColumnsRequest>()),
                "getbyid" => await GetById(jsonData.FromJson<GetColumnByIdRequest>()),
                "save" => await Save(jsonData.FromJson<Column>()),
                "delete" => await Delete(jsonData.FromJson<DeleteColumnRequest>()),
                "saveshift" => await SaveShift(jsonData.FromJson<SaveColumnShiftRequest>()),
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
    /// Get all columns
    /// </summary>
    public async Task<string> Get(GetColumnsRequest request)
    {
        try
        {
            var result = await _columnRepository.GetColumns(CurrentUser.TenantID, request.LayoutId);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving columns: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get column by ID
    /// </summary>
    public async Task<string> GetById(GetColumnByIdRequest request)
    {
        try
        {
            var result = await _columnRepository.GetColumnById(request.Id, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving column: {ex.Message}" }.ToJson();
        }
    }
    
    /// <summary>
    /// Save a Column (Create/Update)
    /// </summary>
    public async Task<string> Save(Column columnDto)
    {
        try
        {
            var json = columnDto.ToJson();
            var result = await _columnRepository.SaveColumn(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Column
    /// </summary>
    public async Task<string> Delete(DeleteColumnRequest request)
    {
        try
        {
            var result = await _columnRepository.DeleteColumn(request.Id, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save a shift to a column
    /// </summary>
    public async Task<string> SaveShift(SaveColumnShiftRequest request)
    {
        try
        {
            var result = await _columnRepository.SaveColumnShift(request.ToJson(), CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving shift to column: {ex.Message}" }.ToJson();
        }
    }
}

