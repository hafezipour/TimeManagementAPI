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

    /// <summary>
    /// Get trade requests with server-side paging
    /// </summary>
    public async Task<string> GetTradeRequests(int? userId, int? statusCustomTableValueId, int pageNumber, int pageSize, string sortColumn, string sortDirection, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "UserId", Value = userId ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "StatusCustomTableValueId", Value = statusCustomTableValueId ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "PageNumber", Value = pageNumber },
                new SqlParameterModel() { Name = "PageSize", Value = pageSize },
                new SqlParameterModel() { Name = "SortColumn", Value = sortColumn },
                new SqlParameterModel() { Name = "SortDirection", Value = sortDirection },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_GetTradeRequests", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// This is used to get the shift trades data for approval
    /// </summary>
    public async Task<string> GetTradesDataForApproval(string ids, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "Ids", Value = ids },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_GetDataForApproval", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete a trade request and associated shift assignments
    /// </summary>
    public async Task<string> DeleteTradeRequest(int tradeRequestId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "TradeRequestId", Value = tradeRequestId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_DeleteTradeRequest", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    
    /// <summary>
    /// Deny a trade request (set StatusCustomTableValueId to 3)
    /// </summary>
    public async Task<string> DenyTradeRequest(int tradeRequestId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "TradeRequestId", Value = tradeRequestId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_DenyTradeRequest", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Check if an approved trade conflict exists in ShiftAssignment table
    /// </summary>
    public async Task<string> CheckApprovedTradeConflict(
        int shiftId,
        DateTime date,
        string shiftType,
        int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "ShiftId", Value = shiftId },
                new SqlParameterModel() { Name = "Date", Value = date },
                new SqlParameterModel() { Name = "ShiftType", Value = shiftType },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_CheckApprovedTradeConflict", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Approve a trade request (set StatusCustomTableValueId to 2)
    /// </summary>
    public async Task<string> ApproveTradeRequest(int tradeRequestId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "TradeRequestId", Value = tradeRequestId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_ApproveTradeRequest", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get Shift Trades statistics (Open, Approved, Denied)
    /// </summary>
    public async Task<string> GetShiftTradesStats(DateTime? date, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "Date", Value = date.HasValue ? (object)date.Value.Date : DBNull.Value },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftTrades_GetStats", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

