using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualTypesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualTypesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAccrualTypes(int? accrualTypeId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTypeId", Value = accrualTypeId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTypes_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveAccrualType(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTypes_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteAccrualType(int accrualTypeId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTypeId", Value = accrualTypeId },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTypes_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> UpdateActiveStatus(int accrualTypeId, bool isActive, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTypeId", Value = accrualTypeId },
                new SqlParameterModel { Name = "IsActive", Value = isActive },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTypes_UpdateActiveStatus", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}


