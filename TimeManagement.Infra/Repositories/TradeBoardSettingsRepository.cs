using System.Text.Json;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class TradeBoardSettingsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public TradeBoardSettingsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get list of all Trade Board Settings with pagination and sorting
    /// </summary>
    public async Task<string> GetTradeBoardSettingsList(int tenantId, int userId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "UserId", Value = userId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_TradeBoardSettings_GetList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Batch save multiple Trade Board Settings in a single call
    /// </summary>
    public async Task<string> SaveTradeBoardSettingsBatch(string settingsJson, int tenantId, int userId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "SettingsJson", Value = settingsJson}
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_TradeBoardSettings_SaveBatch", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

}
