using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class SchedulesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;
    
    public SchedulesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Schedule by Source ID and Source Type
    /// </summary>
    public async Task<string> GetScheduleBySource(string sourceIds, int sourceType, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "SourceIds", Value = sourceIds},
                new SqlParameterModel(){ Name = "SourceType", Value = sourceType},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Schedules_GetBySource", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save (Insert/Update) Schedule
    /// </summary>
    public async Task<string> SaveSchedule(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Schedules_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

