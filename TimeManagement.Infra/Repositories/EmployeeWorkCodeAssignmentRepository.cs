using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class EmployeeWorkCodeAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public EmployeeWorkCodeAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Employee Work Code Assignments with filters, server-side pagination, and sorting
    /// </summary>
    public async Task<string> GetEmployeeWorkCodeAssignments(int? workCodeId, int? userId, string? searchStr, int tenantId, int pageNumber, int pageSize, string? sortColumn, string? sortDirection)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "WorkCodeId", Value = workCodeId ?? 0},
                new SqlParameterModel(){ Name = "UserId", Value = userId ?? 0},
                new SqlParameterModel(){ Name = "SearchStr", Value = searchStr ?? ""},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "PageNumber", Value = pageNumber},
                new SqlParameterModel(){ Name = "PageSize", Value = pageSize},
                new SqlParameterModel(){ Name = "SortColumn", Value = sortColumn ?? "effectiveDate"},
                new SqlParameterModel(){ Name = "SortDirection", Value = sortDirection ?? "desc"}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get Employee Work Code Assignment by Id
    /// </summary>
    public async Task<string> GetEmployeeWorkCodeAssignmentById(int id, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Id", Value = id},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_GetById", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Employee Work Code Assignment (Create/Update)
    /// </summary>
    public async Task<string> SaveEmployeeWorkCodeAssignment(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete Employee Work Code Assignment
    /// </summary>
    public async Task<string> DeleteEmployeeWorkCodeAssignment(int employeeWorkCodeAssignmentId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Id", Value = employeeWorkCodeAssignmentId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get short list of work codes for an employee or common work codes for multiple employees
    /// </summary>
    public async Task<string> GetShortList(int? userId, bool common, string? userIds, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "Common", Value = common},
                new SqlParameterModel(){ Name = "UserIds", Value = userIds},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

