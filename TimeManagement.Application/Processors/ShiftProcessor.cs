using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.DTOs.Columns;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.DTOs.Shifts;
using TimeManagement.Application.DTOs.TimeOffRequests;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Services;
using TimeManagement.Domain.Models;
using TimeManagement.Infra.Repositories;
using static Azure.Core.HttpHeader;

namespace TimeManagement.Application.Processors;

public class ShiftProcessor : BaseProcessor
{
    private readonly ShiftsRepository _shiftsRepository;
    private readonly ScheduleProcessor _scheduleProcessor;
    private readonly ScheduleEvaluator _scheduleEvaluator;
    private readonly IServiceProvider _serviceProvider;
    private readonly ShiftAssignmentRepository _shiftAssignmentRepository;
    private readonly TimeOffRequestsRepository _timeOffRequestsRepository;
    private readonly TimeOffRequestsProcessor _timeOffRequestsProcessor;
    private ColumnProcessor _columnProcessor;
    private ShiftAssignmentConflictService _shiftAssignmentConflictService;

    public ShiftProcessor(ShiftAssignmentConflictService shiftAssignmentConflictService, IServiceProvider serviceProvider, ShiftsRepository shiftsRepository, ScheduleProcessor scheduleProcessor, ScheduleEvaluator scheduleEvaluator, ShiftAssignmentRepository shiftAssignmentRepository, TimeOffRequestsRepository timeOffRequestsRepository, TimeOffRequestsProcessor timeOffRequestsProcessor)
    {
        _shiftsRepository = shiftsRepository;
        _scheduleProcessor = scheduleProcessor;
        _scheduleEvaluator = scheduleEvaluator;
        _serviceProvider = serviceProvider;
        _shiftAssignmentRepository = shiftAssignmentRepository;
        _timeOffRequestsRepository = timeOffRequestsRepository;
        _timeOffRequestsProcessor = timeOffRequestsProcessor;
        _shiftAssignmentConflictService = shiftAssignmentConflictService;
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
                "getschedulingshifts" => await GetSchedulingShifts(null),
                "getscheduledshifts" => await GetScheduledShifts(jsonData.FromJson<GetScheduledShiftsRequest>()),
                "getscheduledshifts-for-trade" => await GetScheduledShiftsForTrade(jsonData.FromJson<GetScheduledShiftsRequest>()),
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
    public async Task<string> GetSchedulingShifts(GetScheduledShiftsRequest request)
    {
        try
        {
            var result = await _shiftsRepository.GetSchedulingShifts(request.EmployeeIds, CurrentUser.TenantID);
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
    public async Task<List<SchedulingShift>> GetSchedulingShiftsList(GetScheduledShiftsRequest request)
    {
        try
        {
            _scheduleProcessor.SetCurrentUser(CurrentUser);
            var result = await GetSchedulingShifts(request);
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

    #region Shifts for Daily, weekly and monthly views including time off requests

    private async Task<List<TimeOffRequestsForUsers>> SetHereTheTimeOffs(DateTime startDate, DateTime endDate, List<int>? employeeIds = null)
    {
        // Calculate end date as end of day from StartDate
        //var startDate = request.StartDate.Date;
        //var endDate = startDate.AddDays(1).AddTicks(-1); // End of the day (23:59:59.9999999)

        // Use provided employeeIds list, or null if not provided (null means fetch for all users)
        List<int> userIds = employeeIds;

        // Fetch time off requests for users within the date range
        // StatusFilter = 2 means only fetch Approved requests (not Pending) for columns display
        var candidatesJson = await _timeOffRequestsRepository.GetTimeOffRequestsForUsers(
            userIds, // Filter by employeeId if provided, otherwise null means fetch for all users
            startDate,
            null, // excludeId is null
            2, // StatusFilter = 2 (Approved only) for columns display
            CurrentUser.TenantID
        );

        // Parse candidates
        var allTimeOffRequests = candidatesJson.FromJson<List<TimeOffRequestsForUsers>>() ?? new List<TimeOffRequestsForUsers>();

        // Filter time off requests to only include those that are valid for the date range
        // A time off request is valid if it overlaps with the StartDate to endDate range
        // Overlap condition: StartFrom <= endDate AND (ValidUntil is null OR ValidUntil >= startDate)
        var filteredTimeOffRequests = allTimeOffRequests.Where(tor =>
            tor.StartFrom.HasValue &&
            tor.StartFrom.Value <= endDate &&
            (tor.ValidUntil == null || tor.ValidUntil.Value >= startDate)
        ).ToList();
        return filteredTimeOffRequests;
    }
    public async Task<string> GetScheduledShiftsForTrade(GetScheduledShiftsRequest request)
    {
        try
        {
            // Set current user for schedule processor
            _scheduleProcessor.SetCurrentUser(this.CurrentUser);
            ColumnProcessor.SetCurrentUser(this.CurrentUser);

            var schedulingShifts = await GetSchedulingShiftsList(request);
            int numberOfDays = (request.EndDate - request.StartDate).Days + 1;

            List<CalendarDay> calendarDays = new List<CalendarDay>();

            var timeOffStartDate = request.StartDate.Date;
            var timeOffEndDate = request.EndDate.Date.AddDays(1).AddTicks(-1);
            var filteredTimeOffRequests = await SetHereTheTimeOffs(timeOffStartDate, timeOffEndDate, request.EmployeeIds);
            // Loop through each day in the month view
            for (int i = 0; i < numberOfDays; i++)
            {
                var date = request.StartDate.AddDays(i);
                var shifts = await GetValidShiftsList(date, schedulingShifts);
                //SetEmployeeAssignmentsForShifts(allAssignments, shifts,);
                calendarDays.Add(new CalendarDay
                {
                    DayNo = date.Day,
                    MonthNo = date.Month,
                    SchedulingShifts = shifts
                });
            }
            await SetEmployeeAssignmentsForShiftsAsync(filteredTimeOffRequests, calendarDays.SelectMany(c => c.SchedulingShifts).ToList(), request.EmployeeIds);//its passed by reference, so it will get setted the assignments

            if (request.EmployeeIds != null && request.EmployeeIds.Any())
            {
                foreach (var day in calendarDays)
                {
                    day.SchedulingShifts = day.SchedulingShifts
                        .Where(s => s.UserAssignments != null && s.UserAssignments.Any(c => c.IsTraded != true))
                        .ToList();
                }
                if (request.IsAssignmentScreen == true)
                {
                    calendarDays = calendarDays.Where(c => c.SchedulingShifts?.Count > 0).ToList();
                }
            }
            calendarDays = calendarDays.Where(c => c.SchedulingShifts != null && c.SchedulingShifts.Count > 0).ToList();
            var shiftsData = calendarDays.SelectMany(c => c.SchedulingShifts).DistinctBy(c => c.Id).ToList();
            var a = shiftsData.Select(x => new
            {
                Shift = new
                {
                    Id = x.Id,
                    nam = x.ShiftName,
                    s = x.ShiftCode
                },
                UserAssignments = calendarDays.SelectMany(c => c.SchedulingShifts.Where(f => f.Id == x.Id).SelectMany(c => c.UserAssignments.Where(c => c.IsTraded != true && c.TradeStatus != TradeStatus.Full)).Select(m => new
                {
                    Id = m.Id,
                    //ShiftId = m.ShiftId,
                    UserId = m.UserId,
                    Notes = m.Notes,
                    Schedule = new
                    {
                        Id = m.Schedules.Id,
                        StartFrom = m.Schedules.StartFrom,
                        StartTime = m.Schedules.StartTime,
                        EndDate = _shiftAssignmentConflictService.GetScheduleEndDate(m.Schedules),
                        EndTime = m.Schedules.EndTime
                    }
                })).DistinctBy(c => c.Id).ToList(),
                Occurances = calendarDays.SelectMany(c => c.SchedulingShifts.Where(f => f.Id == x.Id).SelectMany(c => c.UserAssignments.Where(c => c.IsTraded != true && c.TradeStatus != TradeStatus.Full)).Select(m => new
                {
                    Id = m.Id,
                    //ShiftId = m.ShiftId,
                    UserId = m.UserId,
                    //Notes = m.Notes,
                    DayNo = c.DayNo,
                    MonthNo = c.MonthNo,
                    YearNo = m.FromDate?.Year,
                    EndDate = _shiftAssignmentConflictService.GetScheduleEndDate(m.Schedules),
                })).ToList(),
            }).ToList();
            return a.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving scheduled shifts: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get scheduled shifts with filters (date range, view type, etc.)
    /// </summary>
    public async Task<string> GetScheduledShifts(GetScheduledShiftsRequest request)
    {
        try
        {
            // Validate request
            if (request.LayoutId <= 0 && request.ViewType == "day")
            {
                return new { success = false, message = "Invalid LayoutId" }.ToJson();
            }

            if (request.StartDate > request.EndDate)
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

            var timeOffStartDate = request.StartDate.Date;
            var timeOffEndDate = request.EndDate.Date.AddDays(1).AddTicks(-1);
            var filteredTimeOffRequests = await SetHereTheTimeOffs(timeOffStartDate, timeOffEndDate, request.EmployeeIds);

            List<Column> columns = new List<Column>();
            if (request.ViewType == "day")
            {
                columns = await ColumnProcessor.GetColumnRequestData(new GetColumnsRequest() { LayoutId = request.LayoutId });
                foreach (var item in columns)
                {
                    var shifts = await GetValidShiftsList(request.StartDate, item.SchedulingShifts);
                    item.SchedulingShifts = shifts;
                }
                await SetEmployeeAssignmentsForShiftsAsync(filteredTimeOffRequests, columns.SelectMany(c => c.SchedulingShifts).ToList(), request.EmployeeIds);//its passed by reference, so it will get setted the assignments

                #region Add here the holidays

                var column = columns.Where(c => c.IsSystem == true).FirstOrDefault();

                column.TimeOffRequests = filteredTimeOffRequests;

                #endregion

                //return columns.ToJson();
            }
            else if (request.ViewType == "week")
            {
                var schedulingShifts = await GetSchedulingShiftsList(request);
                for (int i = 0; i < 7; i++)
                {
                    var date = request.StartDate.AddDays(i);
                    var shifts = await GetValidShiftsList(date, schedulingShifts);
                    calendarDays.Add(new CalendarDay
                    {
                        DayNo = date.Day,
                        MonthNo = date.Month,
                        SchedulingShifts = shifts
                    });
                }
                await SetEmployeeAssignmentsForShiftsAsync(filteredTimeOffRequests, calendarDays.SelectMany(c => c.SchedulingShifts).ToList(), request.EmployeeIds);//its passed by reference, so it will get setted the assignments
                //return calendarDays.ToJson();
            }
            else if (request.ViewType == "month")
            {
                var schedulingShifts = await GetSchedulingShiftsList(request);
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
                        MonthNo = date.Month,
                        SchedulingShifts = shifts
                    });
                }
                await SetEmployeeAssignmentsForShiftsAsync(filteredTimeOffRequests, calendarDays.SelectMany(c => c.SchedulingShifts).ToList(), request.EmployeeIds);//its passed by reference, so it will get setted the assignments
                //return calendarDays.ToJson();
            }

            // Filter shifts to only include those with assignments for the selected employees (if EmployeeIds is provided)
            if (request.EmployeeIds != null && request.EmployeeIds.Any())
            {
                if (calendarDays != null && calendarDays.Count > 0)
                {
                    foreach (var day in calendarDays)
                    {
                        day.SchedulingShifts = day.SchedulingShifts
                            .Where(s => s.UserAssignments != null && s.UserAssignments.Any())
                            .ToList();
                    }
                    if (request.IsAssignmentScreen == true)
                    {
                        calendarDays = calendarDays.Where(c => c.SchedulingShifts?.Count > 0).ToList();
                    }
                }
                else if (columns != null && columns.Count > 0)
                {
                    foreach (var column in columns)
                    {
                        column.SchedulingShifts = column.SchedulingShifts
                            .Where(s => s.UserAssignments != null && s.UserAssignments.Any())
                            .ToList();
                    }
                }
            }

            var data = new GetScheduledShiftsResponse
            {
                Success = true,
                Message = "Scheduled shifts retrieved successfully",
                Data = calendarDays,
                Columns = columns,
                UserIds = calendarDays != null && calendarDays.Count > 0 ?
                                      (
                                           calendarDays.SelectMany(cd => cd.SchedulingShifts)
                                          .Where(ss => ss.UserAssignments != null && ss.UserAssignments.Any())
                                          .SelectMany(ss => ss.UserAssignments)
                                          .Select(ua => ua.UserId)
                                          .Distinct()
                                          .ToList()
                                      ) :
                                      (
                                           columns.SelectMany(cd => cd.SchedulingShifts)
                                          .Where(ss => ss.UserAssignments != null && ss.UserAssignments.Any())
                                          .SelectMany(ss => ss.UserAssignments)
                                          .Select(ua => ua.UserId)
                                          .Distinct().ToList()
                                      )
            };

            return data.ToJson();
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
                // Create a copy so the original reference isn't mutated when EvaluationDate is set
                var shiftCopy = JsonConvert.DeserializeObject<SchedulingShift>(JsonConvert.SerializeObject(shift));

                if (shiftCopy == null)
                {
                    continue;
                }

                // This shift occurs on this date
                // The schedule.StartTime and schedule.EndTime define the shift times
                shiftCopy.EvaluationDate = date;

                // Set StartDate and EndDate based on shift schedule times (including time components)
                if (shiftCopy.Schedules != null)
                {
                    // StartDate = date + start time
                    if (shiftCopy.Schedules.StartTime.HasValue)
                    {
                        shiftCopy.StartDate = date.Date.Add(shiftCopy.Schedules.StartTime.Value);
                    }
                    else
                    {
                        shiftCopy.StartDate = date.Date;
                    }

                    // EndDate = date + end time (or next day if spans midnight)
                    if (shiftCopy.Schedules.EndTime.HasValue)
                    {
                        if (shiftCopy.Schedules.StartTime.HasValue &&
                            shiftCopy.Schedules.EndTime.Value < shiftCopy.Schedules.StartTime.Value)
                        {
                            // Shift spans midnight, so EndDate is on the next day
                            shiftCopy.EndDate = date.Date.AddDays(1).Add(shiftCopy.Schedules.EndTime.Value);
                        }
                        else
                        {
                            // Same day
                            shiftCopy.EndDate = date.Date.Add(shiftCopy.Schedules.EndTime.Value);
                        }
                    }
                    else
                    {
                        shiftCopy.EndDate = date.Date;
                    }
                }
                else
                {
                    shiftCopy.StartDate = date.Date;
                    shiftCopy.EndDate = date.Date;
                }

                result.Add(shiftCopy);
            }
        }

        return Task.FromResult(result);
    }

    /// <summary>
    /// set the employees assigned onto the shifts
    /// </summary>
    /// <param name="timeOffRequests">List of time off requests</param>
    /// <param name="schedulingShiftsAll">List of scheduling shifts</param>
    /// <param name="employeeIds">Optional list of employee IDs to filter assignments</param>
    /// <returns></returns>
    private async Task SetEmployeeAssignmentsForShiftsAsync(List<TimeOffRequestsForUsers> timeOffRequests, List<SchedulingShift> schedulingShiftsAll, List<int>? employeeIds)
    {
        // Fetch employee assignments at once
        List<ShiftAssignmentDetailDto> allAssignments = null;
        List<DTOs.Schedules.ScheduleResponse> allSchedules = null;

        // Get comma-separated shift IDs using extension method
        string shiftIds = schedulingShiftsAll.Select(c => c.Id).Distinct().ToCommaSeparatedString();

        // Prepare userIds string for filtering - if employeeIds is provided, filter by those employees
        string userIds = null;
        if (employeeIds != null && employeeIds.Any())
        {
            userIds = string.Join(",", employeeIds);
        }


        var assignmentsJson = await _shiftAssignmentRepository.Get(userIds, shiftIds, CurrentUser.TenantID);
        var allAssignmentsIncludingChild = JsonConvert.DeserializeObject<List<ShiftAssignmentDetailDto>>(assignmentsJson);
        allAssignments = allAssignmentsIncludingChild.Where(c => c.IsChild != true).ToList();


        var assignmentsJsonChild = await _shiftAssignmentRepository.GetChildByIds(allAssignments.Select(c => c.Id).ToCommaSeparatedString(), CurrentUser.TenantID);
        var childAssignments = JsonConvert.DeserializeObject<List<ShiftAssignmentChildByIds>>(assignmentsJsonChild);


        if (allAssignments != null && allAssignments.Any())
        {
            var assignmentIds = string.Join(",", allAssignments.Select(a => a.Id));
            var sourceTypes = ((int)ScheduleSourceTypes.ShiftAssignment).ToString();

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
                    var assignmentCopy = JsonConvert.DeserializeObject<ShiftAssignmentDetailDto>(JsonConvert.SerializeObject(assignment));
                    // Find the schedule for this assignment
                    var assignmentSchedule = allSchedules?.FirstOrDefault(s => s.SourceId == assignmentCopy.Id && s.SourceType == (int)ScheduleSourceTypes.ShiftAssignment);

                    if (assignmentSchedule != null)
                    {
                        // Check if this assignment's schedule is valid for this date
                        bool isAssignmentValidForDate = _scheduleEvaluator.IsDateValid(assignmentSchedule, (DateTime)shift.EvaluationDate);

                        if (isAssignmentValidForDate)
                        {
                            // Validate if assignment times fall within shift times on the evaluation date
                            bool timesAreValid = IsAssignmentTimeWithinShiftTime(
                                assignmentSchedule,
                                shift.Schedules,
                                (DateTime)shift.EvaluationDate
                            );

                            if (timesAreValid)
                            {
                                // Check if the user is on time off for the evaluation date
                                var (timeOffStatus, timeOffEntries) = IsUserOnTimeOff(
                                    assignmentCopy.UserId,
                                    shift.EvaluationDate,
                                    assignmentSchedule,
                                    timeOffRequests
                                );

                                // Set FromDate and ToDate based on assignment schedule times (including time components)
                                var evaluationDate = (DateTime)shift.EvaluationDate;

                                // FromDate = evaluation date + start time
                                if (assignmentSchedule.StartTime.HasValue)
                                {
                                    assignmentCopy.FromDate = evaluationDate.Date.Add(assignmentSchedule.StartTime.Value);
                                }
                                else
                                {
                                    assignmentCopy.FromDate = evaluationDate.Date;
                                }

                                // ToDate = evaluation date + end time (or next day if spans midnight)
                                if (assignmentSchedule.EndTime.HasValue)
                                {
                                    if (assignmentSchedule.StartTime.HasValue &&
                                        assignmentSchedule.EndTime.Value < assignmentSchedule.StartTime.Value)
                                    {
                                        // Assignment spans midnight, so ToDate is on the next day
                                        assignmentCopy.ToDate = evaluationDate.Date.AddDays(1).Add(assignmentSchedule.EndTime.Value);
                                    }
                                    else
                                    {
                                        // Same day
                                        assignmentCopy.ToDate = evaluationDate.Date.Add(assignmentSchedule.EndTime.Value);
                                    }
                                }
                                else
                                {
                                    assignmentCopy.ToDate = evaluationDate.Date;
                                }

                                assignmentCopy.Schedules = assignmentSchedule;
                                assignmentCopy.TimeOffStatus = timeOffStatus;
                                assignmentCopy.TradeStatus = HasBeenTraded(assignmentCopy, childAssignments);
                                assignmentCopy.TimeOffRequests = timeOffEntries;
                                validAssignmentsForDate.Add(assignmentCopy);
                            }
                        }
                    }
                }
                shift.UserAssignments = validAssignmentsForDate;
            }
        }
    }

    private TradeStatus HasBeenTraded(ShiftAssignmentDetailDto assignment, List<ShiftAssignmentChildByIds> childAssignments)
    {
        if (childAssignments == null || !childAssignments.Any())
        {
            return TradeStatus.None;
        }
        var tradeFound = childAssignments.Any(ca => (ca.TradingUserAssignmentId == assignment.Id || ca.AcceptingUserAssignmentId == assignment.Id)
                                                 && assignment.FromDate.Value.Date == ca.StartFrom.Value.Date);
        if (tradeFound == true)
        {
            return TradeStatus.Full;
        }
        return TradeStatus.None;
    }

    /// <summary>
    /// Checks if a user is on time off for the given evaluation date and assignment schedule
    /// </summary>
    /// <param name="userId">The user ID to check</param>
    /// <param name="evaluationDate">The evaluation date (nullable)</param>
    /// <param name="assignmentSchedule">The assignment's schedule with StartTime and EndTime</param>
    /// <param name="timeOffRequests">List of time off requests to check against</param>
    /// <returns>Tuple containing TimeOffStatus and list of matching time off requests</returns>
    private (TimeOffStatus Status, List<TimeOffRequestsForUsers> TimeOffEntries) IsUserOnTimeOff(
        int userId,
        DateTime? evaluationDate,
        DTOs.Schedules.ScheduleResponse assignmentSchedule,
        List<TimeOffRequestsForUsers> timeOffRequests)
    {
        if (!evaluationDate.HasValue)
        {
            return (TimeOffStatus.None, new List<TimeOffRequestsForUsers>());
        }

        var evalDate = evaluationDate.Value;

        // Get assignment start and end DateTime for the evaluation date
        if (!assignmentSchedule.StartTime.HasValue || !assignmentSchedule.EndTime.HasValue)
        {
            return (TimeOffStatus.None, new List<TimeOffRequestsForUsers>());
        }

        var evalStartDateTime = evalDate.Date.Add(assignmentSchedule.StartTime.Value);
        var evalEndDateTime = evalDate.Date.Add(assignmentSchedule.EndTime.Value);

        // Check if assignment spans midnight (end time is before start time)
        bool assignmentSpansMidnight = assignmentSchedule.EndTime.Value < assignmentSchedule.StartTime.Value;
        if (assignmentSpansMidnight)
        {
            // If assignment spans midnight, adjust endDateTime to next day
            evalEndDateTime = evalDate.Date.AddDays(1).Add(assignmentSchedule.EndTime.Value);
        }

        TimeOffStatus resultStatus = TimeOffStatus.None;
        List<TimeOffRequestsForUsers> matchingTimeOffEntries = new List<TimeOffRequestsForUsers>();

        foreach (var tor in timeOffRequests)
        {
            // User ID matches
            if (tor.UserId != userId)
            {
                continue;
            }

            // Evaluation date falls within the time off request date range
            if (!tor.StartFrom.HasValue)
            {
                continue;
            }

            if (tor.StartFrom.Value > evalDate)
            {
                continue;
            }

            if (tor.ValidUntil.HasValue && tor.ValidUntil.Value < evalDate)
            {
                continue;
            }

            // Generate occurrences for this time off request
            if (!tor.StartTime.HasValue || !tor.EndTime.HasValue || !tor.ValidUntil.HasValue)
            {
                continue;
            }

            var occurrences = _timeOffRequestsProcessor.GenerateOccurrences(
                tor.StartFrom.Value.Date,
                tor.ValidUntil.Value.Date,
                tor.StartTime.Value,
                tor.EndTime.Value
            );

            bool hasOverlap = false;
            bool isCompletelyWithin = false;

            // Check each occurrence for overlap
            foreach (var occurrence in occurrences)
            {
                // Check if assignment completely falls within this occurrence (Full time off)
                // Assignment is completely within if: start >= occurrence start AND end <= occurrence end
                isCompletelyWithin = evalStartDateTime >= occurrence.StartDateTime &&
                                     evalEndDateTime <= occurrence.EndDateTime;

                if (isCompletelyWithin)
                {
                    resultStatus = TimeOffStatus.Full;
                    hasOverlap = true;
                    break; // Found a full match, no need to check other occurrences for this request
                }

                // Check if assignment has any overlap with this occurrence (Partial time off)
                // Overlap occurs when: assignment starts before occurrence ends AND assignment ends after occurrence starts
                // This catches ANY overlap, even if it's just 2 minutes
                bool occurrenceHasOverlap = evalStartDateTime < occurrence.EndDateTime &&
                                           evalEndDateTime > occurrence.StartDateTime;

                if (occurrenceHasOverlap)
                {
                    hasOverlap = true;
                    if (resultStatus != TimeOffStatus.Full)
                    {
                        resultStatus = TimeOffStatus.Partial;
                    }
                }
            }

            // If this time off request has any overlap, add it to the matching entries
            if (hasOverlap)
            {
                matchingTimeOffEntries.Add(tor);
            }
        }

        return (resultStatus, matchingTimeOffEntries);
    }

    /// <summary>
    /// Validates if assignment times fall within shift times on the evaluation date
    /// </summary>
    /// <param name="assignmentSchedule">The assignment's schedule</param>
    /// <param name="shiftSchedule">The shift's schedule</param>
    /// <param name="evaluationDate">The date to evaluate</param>
    /// <returns>True if assignment times are within shift times, otherwise false</returns>
    private bool IsAssignmentTimeWithinShiftTime(
        DTOs.Schedules.ScheduleResponse assignmentSchedule,
        DTOs.Schedules.ScheduleResponse shiftSchedule,
        DateTime evaluationDate)
    {
        // If either schedule doesn't have times, skip time validation
        if (!assignmentSchedule.StartTime.HasValue || !assignmentSchedule.EndTime.HasValue ||
            !shiftSchedule.StartTime.HasValue || !shiftSchedule.EndTime.HasValue)
        {
            return true; // No time restriction
        }

        // Combine evaluation date with times to create full DateTimes
        var assignmentStart = evaluationDate.Date.Add(assignmentSchedule.StartTime.Value);
        var assignmentEnd = evaluationDate.Date.Add(assignmentSchedule.EndTime.Value);

        var shiftStart = evaluationDate.Date.Add(shiftSchedule.StartTime.Value);
        var shiftEnd = evaluationDate.Date.Add(shiftSchedule.EndTime.Value);

        // Validate: Assignment times must fall within shift times
        return assignmentStart >= shiftStart && assignmentEnd <= shiftEnd;
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