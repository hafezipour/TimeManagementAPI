using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualBanksRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualBanksRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> CheckAndCreateBanks(string json, int createdBy, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "CreatedBy", Value = createdBy },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_CheckAndCreate", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> UpdateBalances(string json, int updatedBy, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UpdatedBy", Value = updatedBy },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_UpdateBalances", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> LogTransactions(string json, int createdBy, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "CreatedBy", Value = createdBy },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_LogTransactions", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetAccrualBanks(int userId, int accrualProfileId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_Get", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

