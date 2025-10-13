using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class JobCodesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public JobCodesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get JobCodes Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetJobCodesShortList(int tenantId)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "TenantId", Value = tenantId }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_GetShortList", param);
    }

    /// <summary>
    /// Get all JobCodes
    /// </summary>
    public async Task<string> GetJobCodes(int tenantId)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "TenantId", Value = tenantId }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_Get", param);
    }
}

