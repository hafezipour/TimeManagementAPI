using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class LabelsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public LabelsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetLabelsList(int? labelId, int tenantId, int pageNumber = 1, int pageSize = 10, string sortColumn = "LabelName", string sortDirection = "ASC", string searchTerm = null)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "LabelId", Value = labelId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "PageNumber", Value = pageNumber},
                new SqlParameterModel(){ Name = "PageSize", Value = pageSize},
                new SqlParameterModel(){ Name = "SortColumn", Value = sortColumn},
                new SqlParameterModel(){ Name = "SortDirection", Value = sortDirection},
                new SqlParameterModel(){ Name = "SearchTerm", Value = searchTerm}
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_Labels_Get", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveLabel(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Labels_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteLabel(int labelId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "LabelId", Value = labelId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Labels_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetLabelsShortList(int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Labels_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

