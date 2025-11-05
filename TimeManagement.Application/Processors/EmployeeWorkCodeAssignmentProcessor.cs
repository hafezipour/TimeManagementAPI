using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class EmployeeWorkCodeAssignmentProcessor : BaseProcessor
{
    private readonly EmployeeWorkCodeAssignmentRepository _repository;

    public EmployeeWorkCodeAssignmentProcessor(EmployeeWorkCodeAssignmentRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "getshortlist" => await GetShortList(jsonData.FromJson<GetEmployeeWorkCodeShortListRequest>()),
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
    /// Get short list of work codes for an employee or common work codes for multiple employees
    /// </summary>
    private async Task<string> GetShortList(GetEmployeeWorkCodeShortListRequest request)
    {
        return await _repository.GetShortList(request.UserId, request.Common ?? false, request.UserIds, CurrentUser.TenantId);
    }
}

