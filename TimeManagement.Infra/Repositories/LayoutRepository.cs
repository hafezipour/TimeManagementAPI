using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class LayoutRepository
{
    private readonly EfDbOperationsRepository _dbOperations;
    
    public LayoutRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Short List of Layouts
    /// </summary>
    public async Task<string> GetLayoutShortList(int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Layouts_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Layout Rows and Columns
    /// </summary>
    public async Task<string> SaveLayoutRowsColumns(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Layouts_SaveRowsColumns", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Grid Cells Data
    /// </summary>
    public async Task<string> SaveGridCells(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            var result =  await _dbOperations.ExecuteDataSetAsync("usp_Layouts_SaveGridCells", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
