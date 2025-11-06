using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.DTOs.Columns;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.DTOs.Shifts;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Services;
using TimeManagement.Domain.Models;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ShiftProcessor : BaseProcessor
{
    private readonly ShiftsRepository _shiftsRepository;
    private readonly ScheduleProcessor _scheduleProcessor;
    private readonly ScheduleEvaluator _scheduleEvaluator;
    private readonly IServiceProvider _serviceProvider;
    private readonly ShiftAssignmentRepository _shiftAssignmentRepository;
    private ColumnProcessor _columnProcessor;

    public ShiftProcessor(IServiceProvider serviceProvider, ShiftsRepository shiftsRepository, ScheduleProcessor scheduleProcessor, ScheduleEvaluator scheduleEvaluator, ShiftAssignmentRepository shiftAssignmentRepository)
    {
        _shiftsRepository = shiftsRepository;
        _scheduleProcessor = scheduleProcessor;
        _scheduleEvaluator = scheduleEvaluator;
        _serviceProvider = serviceProvider;
        _shiftAssignmentRepository = shiftAssignmentRepository;
    }

    private ColumnProcessor ColumnProcessor => _columnProcessor ??= _serviceProvider.GetRequiredService<ColumnProcessor>();

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
                "close" => await Close(jsonData.FromJson<DeleteShiftRequest>()),
                "get" => await GetShifts(jsonData.FromJson<GetShiftRequest>()),
                "getbyid" => await GetShift(jsonData.FromJson<GetShiftRequest>()),
                "getshortlist" => await GetShiftsShortList(),
                "getunassigned" => await GetUnassignedShifts(jsonData.FromJson<GetUnassignedShiftsRequest>()),
                "getschedulingshifts" => await GetSchedulingShifts(),
                "getscheduledshifts" => await GetScheduledShifts(jsonData.FromJson<GetScheduledShiftsRequest>()),
                "updateslotpositions" => await UpdateSlotPositions(jsonData.FromJson<UpdateSlotPositionsRequest>()),
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
            _scheduleProcessor.SetCurrentUser(this.CurrentUser);
            var json = shiftDto.ToJson();
            var result = await _shiftsRepository.SaveShift(json, CurrentUser.LoginId, CurrentUser.TenantID);
            var resultData = Newtonsoft.Json.JsonConvert.DeserializeObject<SaveShiftResponse>(result);
            var sch = shiftDto.Schedules[0];
            sch.SourceId = resultData.Id;
            await _scheduleProcessor.Save(shiftDto.Schedules[0]);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving shift: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Close a Shift by ID
    /// </summary>
    public async Task<string> Close(DeleteShiftRequest request)
    {
        try
        {
            var result = await _shiftsRepository.CloseShift(request.ShiftId, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error closing shift: {ex.Message}" }.ToJson();
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
                request.SearchTerm,
                request.StatusCustomTableValueId
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

    /// <summary>
    /// Get unassigned shifts (not in ColumnShifts table)
    /// </summary>
    public async Task<string> GetUnassignedShifts(GetUnassignedShiftsRequest request)
    {
        try
        {
            var result = await _shiftsRepository.GetUnassignedShifts(CurrentUser.TenantID, request.LayoutId);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving unassigned shifts: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get scheduling shifts for a tenant
    /// </summary>
    public async Task<string> GetSchedulingShifts()
    {
        try
        {
            var result = await _shiftsRepository.GetSchedulingShifts(CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving scheduling shifts: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get scheduling shifts for a tenant
    /// </summary>
    public async Task<List<SchedulingShift>> GetSchedulingShiftsList()
    {
        try
        {
            _scheduleProcessor.SetCurrentUser(CurrentUser);
            var result = await GetSchedulingShifts();
            var shifts = JsonConvert.DeserializeObject<List<SchedulingShift>>(result);

            List<DTOs.Schedules.ScheduleResponse> schList = new List<DTOs.Schedules.ScheduleResponse>();
            var schedules = await _scheduleProcessor.GetBySource(new DTOs.Schedules.GetScheduleRequest()
            {
                SourceTypes = ((int)ScheduleSourceTypes.Shift).ToString(),
                SourceIds = string.Join(",", shifts.Select(c => c.Id).Distinct().ToList())
            });
            schList = JsonConvert.DeserializeObject<List<DTOs.Schedules.ScheduleResponse>>(schedules);
            foreach (var shift in shifts)
            {
                shift.Schedules = schList.Where(s => s.SourceId == shift.Id && s.SourceType == (int)ScheduleSourceTypes.Shift).FirstOrDefault();
            }
            return shifts;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    #region Shifts

    /// <summary>
    /// Get scheduled shifts with filters (date range, view type, etc.)
    /// </summary>
    public async Task<string> GetScheduledShifts(GetScheduledShiftsRequest request)
    {
        try
        {
            // Validate request
            if (request.LayoutId <= 0)
            {
                return new { success = false, message = "Invalid LayoutId" }.ToJson();
            }

            if (request.StartDate >= request.EndDate && request.ViewType != "day")
            {
                return new { success = false, message = "StartDate must be before EndDate" }.ToJson();
            }

            var validViewTypes = new[] { "day", "week", "month" };
            if (string.IsNullOrEmpty(request.ViewType) || !validViewTypes.Contains(request.ViewType.ToLower()))
            {
                return new { success = false, message = "Invalid ViewType. Must be 'day', 'week', or 'month'" }.ToJson();
            }

            // Set current user for schedule processor
            _scheduleProcessor.SetCurrentUser(this.CurrentUser);
            ColumnProcessor.SetCurrentUser(this.CurrentUser);

            List<CalendarDay> calendarDays = new List<CalendarDay>();

            if (request.ViewType == "day")
            {
                var columns = await ColumnProcessor.GetColumnRequestData(new GetColumnsRequest() { LayoutId = request.LayoutId });
                foreach (var item in columns)
                {
                    var shifts = await GetValidShiftsList(request.StartDate, item.SchedulingShifts);
                    item.SchedulingShifts = shifts;
                }
                await SetEmployeeAssignmentsForShiftsAsync(columns.SelectMany(c => c.SchedulingShifts).ToList());//its passed by reference, so it will get setted the assignments
                return columns.ToJson();
            }
            else if (request.ViewType == "week")
            {
                var schedulingShifts = await GetSchedulingShiftsList();
                for (int i = 0; i < 7; i++)
                {
                    var date = request.StartDate.AddDays(i);
                    var shifts = await GetValidShiftsList(date, schedulingShifts);
                    calendarDays.Add(new CalendarDay
                    {
                        DayNo = date.Day,
                        SchedulingShifts = shifts
                    });
                }
                await SetEmployeeAssignmentsForShiftsAsync(calendarDays.SelectMany(c => c.SchedulingShifts).ToList());//its passed by reference, so it will get setted the assignments
                return calendarDays.ToJson();
            }
            else if (request.ViewType == "month")
            {
                var schedulingShifts = await GetSchedulingShiftsList();
                int numberOfDays = (request.EndDate - request.StartDate).Days + 1;

                // Loop through each day in the month view
                for (int i = 0; i < numberOfDays; i++)
                {
                    var date = request.StartDate.AddDays(i);
                    var shifts = await GetValidShiftsList(date, schedulingShifts);
                    //SetEmployeeAssignmentsForShifts(allAssignments, shifts,);
                    calendarDays.Add(new CalendarDay
                    {
                        DayNo = date.Day,
                        SchedulingShifts = shifts
                    });

                }
                await SetEmployeeAssignmentsForShiftsAsync(calendarDays.SelectMany(c => c.SchedulingShifts).ToList());//its passed by reference, so it will get setted the assignments
                return calendarDays.ToJson();
            }

            return "";
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving scheduled shifts: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get valid shifts for a specific date based on their schedule patterns
    /// </summary>
    /// <param name="date">The date to check</param>
    /// <param name="schedulingShifts">List of shifts with their schedules</param>
    /// <returns>List of shifts that are valid for the given date</returns>
    public Task<List<SchedulingShift>> GetValidShiftsList(DateTime date, List<SchedulingShift> schedulingShifts)
    {
        var result = new List<SchedulingShift>();

        foreach (var shift in schedulingShifts)
        {
            // Check if shift has a schedule
            if (shift.Schedules == null)
            {
                // No schedule defined - skip this shift
                continue;
            }

            // Use ScheduleEvaluator to check if this date is valid for the shift's schedule
            bool isValidForDate = _scheduleEvaluator.IsDateValid(shift.Schedules, date);

            if (isValidForDate)
            {
                // This shift occurs on this date
                // The schedule.StartTime and schedule.EndTime define the shift times
                result.Add(shift);
            }
        }

        return Task.FromResult(result);
    }

    /// <summary>
    /// set the employees assigned onto the shifts
    /// </summary>
    /// <param name="schedulingShiftsAll"></param>
    /// <returns></returns>
    private async Task SetEmployeeAssignmentsForShiftsAsync(List<SchedulingShift> schedulingShiftsAll)
    {
        // Fetch ALL employee assignments at once
        List<ShiftAssignmentDetailDto> allAssignments = null;
        List<DTOs.Schedules.ScheduleResponse> allSchedules = null;

        // Get comma-separated shift IDs using extension method
        string shiftIds = schedulingShiftsAll.Select(c => c.Id).ToCommaSeparatedString();

        var assignmentsJson = await _shiftAssignmentRepository.Get(null, shiftIds, CurrentUser.TenantID);
        allAssignments = JsonConvert.DeserializeObject<List<ShiftAssignmentDetailDto>>(assignmentsJson);

        if (allAssignments != null && allAssignments.Any())
        {
            var assignmentIds = string.Join(",", allAssignments.Select(a => a.Id));
            var sourceTypes = ((int)ScheduleSourceTypes.StaffAvailability).ToString();

            var schedulesJson = await _scheduleProcessor.GetBySource(new DTOs.Schedules.GetScheduleRequest
            {
                SourceIds = assignmentIds,
                SourceTypes = sourceTypes
            });

            allSchedules = JsonConvert.DeserializeObject<List<DTOs.Schedules.ScheduleResponse>>(schedulesJson);
        }



        foreach (var shift in schedulingShiftsAll)
        {
            // Check for assigned users to this shift for this date
            if (allAssignments != null && allSchedules != null && allAssignments.Any())
            {
                // Get assignments for this specific shift
                var shiftAssignments = allAssignments.Where(a => a.ShiftId == shift.Id).ToList();

                // Filter assignments that are valid for this date
                var validAssignmentsForDate = new List<ShiftAssignmentDetailDto>();

                foreach (var assignment in shiftAssignments)
                {
                    // Find the schedule for this assignment
                    var assignmentSchedule = allSchedules?.FirstOrDefault(s => s.SourceId == assignment.Id && s.SourceType == (int)ScheduleSourceTypes.StaffAvailability);

                    if (assignmentSchedule != null)
                    {
                        // Check if this assignment's schedule is valid for this date
                        bool isAssignmentValidForDate = _scheduleEvaluator.IsDateValid(assignmentSchedule, (DateTime)shift.EvaluationDate);

                        if (isAssignmentValidForDate)
                        {
                            validAssignmentsForDate.Add(assignment);
                        }
                    }
                }
                shift.UserAssignments = validAssignmentsForDate;
            }
        }
    }

    #endregion

    /// <summary>
    /// Update shift slot positions (increase/decrease minimumPositions)
    /// </summary>
    public async Task<string> UpdateSlotPositions(UpdateSlotPositionsRequest request)
    {
        try
        {
            // Validate request
            if (request.ShiftId <= 0)
            {
                return new { success = false, message = "Invalid ShiftId" }.ToJson();
            }

            if (string.IsNullOrEmpty(request.Action) ||
                (request.Action.ToLower() != "increase" && request.Action.ToLower() != "decrease"))
            {
                return new { success = false, message = "Action must be 'increase' or 'decrease'" }.ToJson();
            }

            var result = await _shiftsRepository.UpdateSlotPositions(
                request.ShiftId,
                request.Action.ToLower(),
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error updating slot positions: {ex.Message}" }.ToJson();
        }
    }

}