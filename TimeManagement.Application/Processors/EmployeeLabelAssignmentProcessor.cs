using TimeManagement.Application.DTOs.EmployeeLabelAssignment;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class EmployeeLabelAssignmentProcessor : BaseProcessor
{
    private readonly EmployeeLabelAssignmentRepository _repository;

    public EmployeeLabelAssignmentProcessor(EmployeeLabelAssignmentRepository repository)
    {
        _repository = repository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveEmployeeLabelAssignmentRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteEmployeeLabelAssignmentRequest>()),
                "get" => await Get(jsonData.FromJson<GetEmployeeLabelAssignmentRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (System.Text.Json.JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> Save(SaveEmployeeLabelAssignmentRequest request)
    {
        try
        {
            var json = request.ToJson();
            var result = await _repository.Save(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving employee label assignment: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> Delete(DeleteEmployeeLabelAssignmentRequest request)
    {
        try
        {
            var result = await _repository.Delete(request.Id, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting employee label assignment: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> Get(GetEmployeeLabelAssignmentRequest request)
    {
        try
        {
            var result = await _repository.Get(
                request.Id,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "DateCreated",
                request.SortDirection ?? "DESC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving employee label assignments: {ex.Message}" }.ToJson();
        }
    }
}

