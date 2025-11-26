using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class CustomTableValuesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public CustomTableValuesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetCustomTableValuesShortList(int? customTableId, int tenantId, bool includeInactive)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "CustomTableId", Value = customTableId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId },
                new SqlParameterModel { Name = "IncludeInactive", Value = includeInactive }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_CustomTableValues_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}


