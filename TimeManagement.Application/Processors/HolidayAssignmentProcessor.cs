using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class HolidayAssignmentProcessor : BaseProcessor
{
    private readonly HolidayAssignmentRepository _holidayAssignmentRepository;

    public HolidayAssignmentProcessor(HolidayAssignmentRepository holidayAssignmentRepository)
    {
        _holidayAssignmentRepository = holidayAssignmentRepository;
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
                "get" => await GetHolidayAssignments(jsonData.FromJson<GetHolidayAssignmentRequest>()),
                "save" => await Save(jsonData.FromJson<SaveHolidayAssignmentRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteHolidayAssignmentRequest>()),
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
    /// Get Holiday Assignments with filters and paging
    /// </summary>
    public async Task<string> GetHolidayAssignments(GetHolidayAssignmentRequest request)
    {
        try
        {
            var result = await _holidayAssignmentRepository.GetHolidayAssignments(
                request.HolidayIds,
                request.JobCodeId,
                request.UserId,
                request.OffSet,
                request.Limit,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving holiday assignments: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save a Holiday Assignment (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveHolidayAssignmentRequest holidayAssignmentDto)
    {
        try
        {
            var json = holidayAssignmentDto.ToJson();
            var result = await _holidayAssignmentRepository.SaveHolidayAssignment(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving holiday assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Holiday Assignment by ID
    /// </summary>
    public async Task<string> Delete(DeleteHolidayAssignmentRequest request)
    {
        try
        {
            var result = await _holidayAssignmentRepository.DeleteHolidayAssignment(request.HolidayAssignmentId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting holiday assignment: {ex.Message}" }.ToJson();
        }
    }
}
