using System.Text.Json;
using TimeManagement.Application.DTOs.CustomTableValues;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class CustomTableValuesProcessor : BaseProcessor
{
    private readonly CustomTableValuesRepository _customTableValuesRepository;

    public CustomTableValuesProcessor(CustomTableValuesRepository customTableValuesRepository)
    {
        _customTableValuesRepository = customTableValuesRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "getshortlist" => await GetShortList(jsonData.FromJson<GetCustomTableValuesShortListRequest>()),
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

    private async Task<string> GetShortList(GetCustomTableValuesShortListRequest? request)
    {
        try
        {
            var result = await _customTableValuesRepository.GetCustomTableValuesShortList(
                request?.CustomTableId,
                CurrentUser.TenantID,
                request?.IncludeInactive ?? false);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving custom table values: {ex.Message}" }.ToJson();
        }
    }
}


