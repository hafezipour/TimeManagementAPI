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
    /// Get Trade Board Settings (single record per tenant)
    /// </summary>
    public async Task<string> GetTradeBoardSettings(int tenantId, int userId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "UserId", Value = userId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_TradeBoardSettings", param);
        }
        catch
        {
            throw;
        }
    }

    /// <summary>
    /// Save Trade Board Settings (single record per tenant)
    /// </summary>
    public async Task<string> SaveTradeBoardSettings(string settingsJson, int tenantId, int userId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "SettingsJson", Value = settingsJson}
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_TradeBoardSettings_Save", param);
        }
        catch
        {
            throw;
        }
    }
}
