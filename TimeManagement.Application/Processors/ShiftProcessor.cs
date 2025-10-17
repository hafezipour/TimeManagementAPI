using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.DTOs.Shifts;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ShiftProcessor : BaseProcessor
{
    private readonly ShiftsRepository _shiftsRepository;
    private readonly ScheduleProcessor _scheduleProcessor;

    public ShiftProcessor(ShiftsRepository shiftsRepository, ScheduleProcessor scheduleProcessor)
    {
        _shiftsRepository = shiftsRepository;

        scheduleProcessor.SetCurrentUser(this.CurrentUser);
        _scheduleProcessor = scheduleProcessor;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Add, Update, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveShiftRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteShiftRequest>()),
                "get" => await GetShifts(jsonData.FromJson<GetShiftRequest>()),
                "getbyid" => await GetShift(jsonData.FromJson<GetShiftRequest>()),
                "getshortlist" => await GetShiftsShortList(),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
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

    /// <summary>
    /// Save a Shift (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveShiftRequest shiftDto)
    {
        try
        {
            var json = shiftDto.ToJson();
            var result = await _shiftsRepository.SaveShift(json, CurrentUser.LoginId, CurrentUser.TenantID);
            var resultData = Newtonsoft.Json.JsonConvert.DeserializeObject<SaveShiftResponse>(result);
            await _scheduleProcessor.Save(shiftDto.Schedules[0]);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving shift: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Shift by ID
    /// </summary>
    public async Task<string> Delete(DeleteShiftRequest request)
    {
        try
        {
            var result = await _shiftsRepository.DeleteShift(request.ShiftId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting shift: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Shifts with server-side paging
    /// </summary>
    public async Task<string> GetShifts(GetShiftRequest request)
    {
        try
        {
            var result = await _shiftsRepository.GetShifts(
                request.ShiftId,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "DisplayOrder",
                request.SortDirection ?? "ASC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving shifts: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get a single Shift by ID
    /// </summary>
    public async Task<string> GetShift(GetShiftRequest request)
    {
        try
        {
            if (request.ShiftId == null || request.ShiftId <= 0)
            {
                return new { success = false, message = "Shift ID is required" }.ToJson();
            }

            var result = await _shiftsRepository.GetShift(request.ShiftId.Value, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving shift: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get Shifts Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetShiftsShortList()
    {
        try
        {
            var result = await _shiftsRepository.GetShiftsShortList(CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving shifts short list: {ex.Message}" }.ToJson();
        }
    }
}