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
    /// <param name="methodName">Method to execute (Get, Save, Delete, GetShortList)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get" => await GetEmployeeWorkCodeAssignments(jsonData.FromJson<GetEmployeeWorkCodeAssignmentRequest>()),
                "getbyid" => await GetEmployeeWorkCodeAssignmentById(jsonData.FromJson<GetEmployeeWorkCodeAssignmentByIdRequest>()),
                "save" => await Save(jsonData.FromJson<SaveEmployeeWorkCodeAssignmentRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteEmployeeWorkCodeAssignmentRequest>()),
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
    /// Get Employee Work Code Assignments with filters, server-side pagination, and sorting
    /// </summary>
    public async Task<string> GetEmployeeWorkCodeAssignments(GetEmployeeWorkCodeAssignmentRequest request)
    {
        try
        {
            var result = await _repository.GetEmployeeWorkCodeAssignments(
                request.WorkCodeId,
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
            return new { success = false, message = $"Error retrieving employee work code assignments: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Employee Work Code Assignment by Id
    /// </summary>
    public async Task<string> GetEmployeeWorkCodeAssignmentById(GetEmployeeWorkCodeAssignmentByIdRequest request)
    {
        try
        {
            var result = await _repository.GetEmployeeWorkCodeAssignmentById(request.Id, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee work code assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save an Employee Work Code Assignment (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveEmployeeWorkCodeAssignmentRequest employeeWorkCodeAssignmentDto)
    {
        try
        {
            var json = employeeWorkCodeAssignmentDto.ToJson();
            var result = await _repository.SaveEmployeeWorkCodeAssignment(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving employee work code assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete an Employee Work Code Assignment by ID
    /// </summary>
    public async Task<string> Delete(DeleteEmployeeWorkCodeAssignmentRequest request)
    {
        try
        {
            var result = await _repository.DeleteEmployeeWorkCodeAssignment(request.EmployeeWorkCodeAssignmentId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting employee work code assignment: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get short list of work codes for an employee or common work codes for multiple employees
    /// </summary>
    public async Task<string> GetShortList(GetEmployeeWorkCodeShortListRequest request)
    {
        try
        {
            var result = await _repository.GetShortList(
                request.UserId,
                request.Common ?? false,
                request.UserIds,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee work codes short list: {ex.Message}" }.ToJson();
        }
    }
}

