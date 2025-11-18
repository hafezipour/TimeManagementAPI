using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualRulesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualRulesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAccrualRules(int? accrualProfileId, int? accrualTypeId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "AccrualTypeId", Value = accrualTypeId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualRules_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveAccrualRule(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualRules_Save", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

