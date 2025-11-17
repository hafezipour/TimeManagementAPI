using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualProfilesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualProfilesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAccrualProfiles(int? accrualProfileId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveAccrualProfile(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteAccrualProfile(int accrualProfileId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetAccrualProfilesShortList(int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

