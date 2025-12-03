using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class TimeOffCodesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public TimeOffCodesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetTimeOffCodesList(int? timeOffCodeId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffCodeId", Value = timeOffCodeId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffCodes_Get", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveTimeOffCode(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_TimeOffCodes_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteTimeOffCode(int timeOffCodeId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffCodeId", Value = timeOffCodeId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_TimeOffCodes_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

