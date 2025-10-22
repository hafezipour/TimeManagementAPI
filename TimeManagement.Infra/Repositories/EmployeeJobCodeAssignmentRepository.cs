using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class EmployeeJobCodeAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public EmployeeJobCodeAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Employee Job Code Assignments with filters (client-side pagination)
    /// </summary>
    public async Task<string> GetEmployeeJobCodeAssignments(int? jobCodeId, int? userId, string? searchStr, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "JobCodeId", Value = jobCodeId ?? 0},
                new SqlParameterModel(){ Name = "UserId", Value = userId ?? 0},
                new SqlParameterModel(){ Name = "SearchStr", Value = searchStr ?? ""},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeJobCodeAssignment_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Employee Job Code Assignment (Create/Update)
    /// </summary>
    public async Task<string> SaveEmployeeJobCodeAssignment(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeJobCodeAssignment_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete Employee Job Code Assignment
    /// </summary>
    public async Task<string> DeleteEmployeeJobCodeAssignment(int employeeJobCodeAssignmentId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Id", Value = employeeJobCodeAssignmentId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeJobCodeAssignment_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
