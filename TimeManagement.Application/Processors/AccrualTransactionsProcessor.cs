using System.Text.Json;
using System.Text.Json.Serialization;
using TimeManagement.Application.DTOs.EmployeeAccrualSettings;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualTransactionsProcessor : BaseProcessor
{
    private readonly AccrualTransactionsRepository _accrualTransactionsRepository;

    private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    public AccrualTransactionsProcessor(AccrualTransactionsRepository accrualTransactionsRepository)
    {
        _accrualTransactionsRepository = accrualTransactionsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "gettransactionhistory" => await GetTransactionHistory(jsonData.FromJson<GetTransactionHistoryRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    #region Log Transactions

    public async Task<string> LogTransactions(List<LogTransactionsRequest> requests, int? sourceTypeId, int? sourceId)
    {
        var json = requests.ToJson();
        return await _accrualTransactionsRepository.LogTransactions(
            json,
            CurrentUser.LoginId,
            CurrentUser.TenantID,
            sourceTypeId,
            sourceId);
    }

    #endregion

    #region Get Transaction History

    private async Task<string> GetTransactionHistory(GetTransactionHistoryRequest? request)
    {
        try
        {
            if (request == null || request.AccrualBankId <= 0)
            {
                return new { success = false, message = "Accrual Bank Id is required." }.ToJson();
            }

            var result = await _accrualTransactionsRepository.GetTransactionHistory(
                request.AccrualBankId,
                CurrentUser.TenantID,
                request.PageNumber,
                request.PageSize,
                request.SortColumn,
                request.SortDirection);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving transaction history: {ex.Message}" }.ToJson();
        }
    }

    #endregion
}

