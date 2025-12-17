using DbOperations;
using System.Data;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class ShiftTradesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public ShiftTradesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Send a trade request
    /// </summary>
    public async Task<string> SendTradeRequest(string jsonData, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "JsonData", Value = jsonData },
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_SendTradeRequest", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

