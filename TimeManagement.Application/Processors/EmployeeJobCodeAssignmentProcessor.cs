using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class EmployeeJobCodeAssignmentProcessor : BaseProcessor
{
    private readonly EmployeeJobCodeAssignmentRepository _employeeJobCodeAssignmentRepository;

    public EmployeeJobCodeAssignmentProcessor(EmployeeJobCodeAssignmentRepository employeeJobCodeAssignmentRepository)
    {
        _employeeJobCodeAssignmentRepository = employeeJobCodeAssignmentRepository;
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
                "get" => await GetEmployeeJobCodeAssignments(jsonData.FromJson<GetEmployeeJobCodeAssignmentRequest>()),
                "save" => await Save(jsonData.FromJson<SaveEmployeeJobCodeAssignmentRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteEmployeeJobCodeAssignmentRequest>()),
                "getshortlist" => await GetShortList(jsonData.FromJson<GetEmployeeJobCodeShortListRequest>()),
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
    /// Get Employee Job Code Assignments with filters, server-side pagination, and sorting
    /// </summary>
    public async Task<string> GetEmployeeJobCodeAssignments(GetEmployeeJobCodeAssignmentRequest request)
    {
        try
        {
            var result = await _employeeJobCodeAssignmentRepository.GetEmployeeJobCodeAssignments(
                request.JobCodeId,
                request.UserId,
                request.SearchStr,
                CurrentUser.TenantID,
                request.PageNumber,
                request.PageSize,
                request.SortColumn,
                request.SortDirection
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee job code assignments: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save an Employee Job Code Assignment (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveEmployeeJobCodeAssignmentRequest employeeJobCodeAssignmentDto)
    {
        try
        {
            var json = employeeJobCodeAssignmentDto.ToJson();
            var result = await _employeeJobCodeAssignmentRepository.SaveEmployeeJobCodeAssignment(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving employee job code assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete an Employee Job Code Assignment by ID
    /// </summary>
    public async Task<string> Delete(DeleteEmployeeJobCodeAssignmentRequest request)
    {
        try
        {
            var result = await _employeeJobCodeAssignmentRepository.DeleteEmployeeJobCodeAssignment(request.EmployeeJobCodeAssignmentId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting employee job code assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get short list of job codes for an employee (for dropdowns/tags)
    /// </summary>
    public async Task<string> GetShortList(GetEmployeeJobCodeShortListRequest request)
    {
        try
        {
            var result = await _employeeJobCodeAssignmentRepository.GetShortList(
                request.UserId,
                request.Common ?? false,
                request.UserIds,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee job codes short list: {ex.Message}" }.ToJson();
        }
    }
}
