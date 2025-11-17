using System.Text.Json;
using TimeManagement.Application.DTOs.EmployeeAvailability;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class EmployeeAvailabilityProcessor : BaseProcessor
{
    private readonly EmployeeAvailabilityRepository _employeeAvailabilityRepository;

    public EmployeeAvailabilityProcessor(EmployeeAvailabilityRepository employeeAvailabilityRepository)
    {
        _employeeAvailabilityRepository = employeeAvailabilityRepository;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Get, Save, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get" => await GetAvailability(jsonData.FromJson<GetAvailabilityRequest>()),
                "save" => await Save(jsonData.FromJson<AvailabilityRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteAvailabilityRequest>()),
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
    /// Get Employee Availability with filters
    /// </summary>
    public async Task<string> GetAvailability(GetAvailabilityRequest request)
    {
        try
        {
            var result = await _employeeAvailabilityRepository.GetAvailability(
                request.UserId,
                request.StartDate,
                request.EndDate,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee availability: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save an Employee Availability (Create/Update)
    /// </summary>
    public async Task<string> Save(AvailabilityRequest availabilityDto)
    {
        try
        {
            var json = availabilityDto.ToJson();
            var result = await _employeeAvailabilityRepository.SaveAvailability(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving employee availability: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete an Employee Availability by ID
    /// </summary>
    public async Task<string> Delete(DeleteAvailabilityRequest request)
    {
        try
        {
            var result = await _employeeAvailabilityRepository.DeleteAvailability(request.Id, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting employee availability: {ex.Message}" }.ToJson();
        }
    }
}
