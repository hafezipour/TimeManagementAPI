using TimeManagement.Application.DTOs.TimeOffRequests;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class TimeOffRequestsProcessor : BaseProcessor
{
    private readonly TimeOffRequestsRepository _timeOffRequestsRepository;

    public TimeOffRequestsProcessor(TimeOffRequestsRepository timeOffRequestsRepository)
    {
        _timeOffRequestsRepository = timeOffRequestsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get"     => await GetTimeOffRequestsList(jsonData.FromJson<GetTimeOffRequestRequest>()),
                "save"    => await SaveTimeOffRequest(jsonData.FromJson<SaveTimeOffRequestRequest>()),
                "approve" => await ApproveTimeOffRequest(jsonData.FromJson<ApproveTimeOffRequestRequest>()),
                "reject"  => await RejectTimeOffRequest(jsonData.FromJson<RejectTimeOffRequestRequest>()),
                "delete"  => await DeleteTimeOffRequest(jsonData.FromJson<DeleteTimeOffRequestRequest>()),
                _         => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (System.Text.Json.JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetTimeOffRequestsList(GetTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.GetTimeOffRequestsList(
                request.TimeOffRequestId,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "DateCreated",
                request.SortDirection ?? "DESC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving time off requests: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> SaveTimeOffRequest(SaveTimeOffRequestRequest request)
    {
        try
        {
            // Serialize request to JSON using camelCase to match usp_TimeOffRequests_Save OPENJSON contract
            var json = request.ToJson();

            var result = await _timeOffRequestsRepository.SaveTimeOffRequest(
                json,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving time off request: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> ApproveTimeOffRequest(ApproveTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.ApproveTimeOffRequest(
                request.Id,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error approving time off request: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> RejectTimeOffRequest(RejectTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.RejectTimeOffRequest(
                request.Id,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error rejecting time off request: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> DeleteTimeOffRequest(DeleteTimeOffRequestRequest request)
    {
        try
        {
            var result = await _timeOffRequestsRepository.DeleteTimeOffRequest(
                request.TimeOffRequestId,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting time off request: {ex.Message}" }.ToJson();
        }
    }
}

