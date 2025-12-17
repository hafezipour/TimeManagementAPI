using DbOperations;
using System.Data;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class ShiftAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public ShiftAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Schedule an employee to a shift
    /// </summary>
    public async Task<string> ScheduleEmployee(string jsonData, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "JsonData", Value = jsonData },
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_ScheduleEmployee", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Updates the ScheduleId associated with a shift assignment.
    /// </summary>
    public async Task<string> UpdateScheduleId(int assignmentId, int scheduleId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "AssignmentId", Value = assignmentId },
                new SqlParameterModel() { Name = "ScheduleId", Value = scheduleId },
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_UpdateScheduleId", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get shift assignments by userIds or shiftIds
    /// </summary>
    public async Task<string> Get(string userIds, string shiftIds, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "UserIds", Value = userIds },
                new SqlParameterModel() { Name = "ShiftIds", Value = shiftIds },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_Get", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get shift assignments short list by assignment IDs (for trade validation)
    /// Returns only: id, userId, jobCodes, workCodes
    /// </summary>
    public async Task<string> GetShortListByAssignmentIds(string assignmentIds, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "AssignmentIds", Value = assignmentIds },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_GetShortListByAssignmentIds", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Update trade-related fields on shift assignment
    /// </summary>
    public async Task<string> UpdateTradeFields(
        int assignmentId,
        bool? isTraded,
        int? tradingUserAssignmentId,
        bool? isSwap,
        int? acceptingUserAssignmentId,
        int? tradeRequestId,
        int userId,
        int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel() { Name = "AssignmentId", Value = assignmentId },
                new SqlParameterModel() { Name = "IsTraded", Value = isTraded ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "TradingUserAssignmentId", Value = tradingUserAssignmentId ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "IsSwap", Value = isSwap ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "AcceptingUserAssignmentId", Value = acceptingUserAssignmentId ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "TradeRequestId", Value = tradeRequestId ?? (object)DBNull.Value },
                new SqlParameterModel() { Name = "UserId", Value = userId },
                new SqlParameterModel() { Name = "TenantId", Value = tenantId }
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_ShiftAssignment_UpdateTradeFields", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

