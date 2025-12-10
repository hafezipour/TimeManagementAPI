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

    public async Task<string> GetTimeOffRequestsList(int? timeOffRequestId, int? userId, int tenantId, int pageNumber = 1, int pageSize = 10, string sortColumn = "DateCreated", string sortDirection = "DESC", string searchTerm = null)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffRequestId", Value = timeOffRequestId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
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

    public async Task<string> SaveTimeOffRequest(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_Save", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> ApproveTimeOffRequest(int timeOffRequestId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffRequestId", Value = timeOffRequestId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_Approve", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> RejectTimeOffRequest(int timeOffRequestId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffRequestId", Value = timeOffRequestId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_Reject", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteTimeOffRequest(int timeOffRequestId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TimeOffRequestId", Value = timeOffRequestId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_Delete", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetTimeOffRequestsForUsers(List<int> userIds, DateTime fromDate, int? excludeId, int? statusFilter, int tenantId)
    {
        try
        {
            // Convert list of user IDs to JSON string for the stored procedure
            // If the list is null or empty, pass NULL to the SP (which will not filter by user IDs)
            object userIdsJsonValue = null;
            if (userIds != null && userIds.Any())
            {
                userIdsJsonValue = System.Text.Json.JsonSerializer.Serialize(userIds);
            }
            
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "UserIdsJson", Value = userIdsJsonValue},
                new SqlParameterModel(){ Name = "FromDate", Value = fromDate.Date},
                new SqlParameterModel(){ Name = "ExcludeId", Value = excludeId},
                new SqlParameterModel(){ Name = "StatusFilter", Value = statusFilter},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_GetTimeOffRequestsForUsers", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetTimeOffRequestsForScheduler(List<int>? userIds, DateTime fromDate, DateTime toDate, int? statusFilter, int tenantId)
    {
        try
        {
            // Convert list of user IDs to JSON string for the stored procedure
            // If the list is null or empty, pass NULL to the SP (which will not filter by user IDs)
            object userIdsJsonValue = null;
            if (userIds != null && userIds.Any())
            {
                userIdsJsonValue = System.Text.Json.JsonSerializer.Serialize(userIds);
            }
            
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "UserIdsJson", Value = userIdsJsonValue},
                new SqlParameterModel(){ Name = "FromDate", Value = fromDate.Date},
                new SqlParameterModel(){ Name = "ToDate", Value = toDate.Date},
                new SqlParameterModel(){ Name = "StatusFilter", Value = statusFilter},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };

            var result = await _dbOperations.ExecuteDataSetAsync("usp_TimeOffRequests_GetForScheduler", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

