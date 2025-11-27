using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualTransactionsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualTransactionsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> LogTransactions(string json, int createdBy, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "CreatedBy", Value = createdBy },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_LogTransactions", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetTransactionHistory(int accrualBankId, int tenantId, int pageNumber, int pageSize, string sortColumn, string sortDirection)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualBankId", Value = accrualBankId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId },
                new SqlParameterModel { Name = "PageNumber", Value = pageNumber },
                new SqlParameterModel { Name = "PageSize", Value = pageSize },
                new SqlParameterModel { Name = "SortColumn", Value = sortColumn },
                new SqlParameterModel { Name = "SortDirection", Value = sortDirection }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualTransactions_GetHistory", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetTransactionsByBankIds(string bankIdsJson, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "BankIdsJson", Value = bankIdsJson },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualTransactions_GetByBankIds", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> LogTransactionsWithPeriodDate(string json, int createdBy, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "CreatedBy", Value = createdBy },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_AccrualBanks_LogTransactionsWithPeriodDate", param);
            
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

