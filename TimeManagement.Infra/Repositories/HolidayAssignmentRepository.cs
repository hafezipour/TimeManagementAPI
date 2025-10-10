using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class HolidayAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;
    
    public HolidayAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Holiday Assignments with filters and paging
    /// </summary>
    public async Task<string> GetHolidayAssignments(string? holidayIds, int? jobCodeId, int? userId, int offset, int limit, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "OffSet", Value = offset},
                new SqlParameterModel(){ Name = "Limit", Value = limit},
                new SqlParameterModel(){ Name = "HolidayIds", Value = holidayIds ?? ""},
                new SqlParameterModel(){ Name = "JobCodeId", Value = jobCodeId ?? 0},
                new SqlParameterModel(){ Name = "UserId", Value = userId ?? 0},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_HolidayAssignment_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Holiday Assignment (Create/Update)
    /// </summary>
    public async Task<string> SaveHolidayAssignment(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_HolidayAssignment_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete Holiday Assignment
    /// </summary>
    public async Task<string> DeleteHolidayAssignment(int holidayAssignmentId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Id", Value = holidayAssignmentId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_HolidayAssignment_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
