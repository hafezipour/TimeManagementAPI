using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class EmployeeAccrualSettingsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public EmployeeAccrualSettingsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetEmployeeAccrualSettings(int userId, string tenantIds)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantIds", Value = tenantIds }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAccrualSettings_Get", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    //public async Task<string> GetEmployeeAccrualSettingsForEvaluation()
    //{
    //    try
    //    {
    //        List<SqlParameterModel> param = new()
    //        {
    //            new SqlParameterModel { Name = "TenantId", Value = profileIdsJson }
    //        };

    //        return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAccrualSettings_GetForEvaluation_EVAL", param);
    //    }
    //    catch (Exception ex)
    //    {
    //        throw ex;
    //    }
    //}

    public async Task<string> SaveEmployeeAccrualSettings(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAccrualSettings_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

