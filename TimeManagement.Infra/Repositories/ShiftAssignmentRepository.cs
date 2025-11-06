using DbOperations;
using System.Data;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class ShiftAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public ShiftAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Schedule an employee to a shift
    /// </summary>
    public async Task<string> ScheduleEmployee(string jsonData, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "JsonData", Value = jsonData },
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_ScheduleEmployee", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get all shift assignments for a specific user
    /// </summary>
    public async Task<string> GetByUserId(int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_GetByUserId", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

