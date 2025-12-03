using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class TimeOffRequestsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public TimeOffRequestsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetTimeOffRequestsList(int? timeOffRequestId, int tenantId, int pageNumber = 1, int pageSize = 10, string sortColumn = "DateCreated", string sortDirection = "DESC", string searchTerm = null)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffRequestId", Value = timeOffRequestId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "PageNumber", Value = pageNumber},
                new SqlParameterModel(){ Name = "PageSize", Value = pageSize},
                new SqlParameterModel(){ Name = "SortColumn", Value = sortColumn},
                new SqlParameterModel(){ Name = "SortDirection", Value = sortDirection},
                new SqlParameterModel(){ Name = "SearchTerm", Value = searchTerm}
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_Get", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

