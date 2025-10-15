using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class WorkCodeProcessor : BaseProcessor
{
    private readonly WorkCodesRepository _workCodesRepository;

    public WorkCodeProcessor(WorkCodesRepository workCodesRepository)
    {
        _workCodesRepository = workCodesRepository;
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
                "save" => await Save(jsonData.FromJson<SaveWorkCodeRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteWorkCodeRequest>()),
                "get" => await GetWorkCodes(jsonData.FromJson<GetWorkCodeRequest>()),
                "getshortlist" => await GetWorkCodesShortList(),
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
    /// Save a WorkCode (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveWorkCodeRequest workCodeDto)
    {
        try
        {
            var json = workCodeDto.ToJson();
            var result = await _workCodesRepository.SaveWorkCode(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving work code: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a WorkCode by ID
    /// </summary>
    public async Task<string> Delete(DeleteWorkCodeRequest request)
    {
        try
        {
            var result = await _workCodesRepository.DeleteWorkCode(request.WorkCodeId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting work code: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get WorkCodes (all or by specific ID)
    /// </summary>
    public async Task<string> GetWorkCodes(GetWorkCodeRequest request)
    {
        try
        {
            var result = await _workCodesRepository.GetWorkCodes(request.WorkCodeId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving work code: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get WorkCodes Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetWorkCodesShortList()
    {
        try
        {
            var result = await _workCodesRepository.GetWorkCodesShortList(CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving work codes short list: {ex.Message}" }.ToJson();
        }
    }

}

