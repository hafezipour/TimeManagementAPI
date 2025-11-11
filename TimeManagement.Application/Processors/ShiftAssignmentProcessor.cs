using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Services;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ShiftAssignmentProcessor : BaseProcessor
{
    private readonly ShiftAssignmentRepository _shiftAssignmentRepository;
    private readonly ScheduleProcessor _scheduleProcessor;
    private readonly ShiftAssignmentConflictService _conflictService;

    public ShiftAssignmentProcessor(
        ShiftAssignmentRepository shiftAssignmentRepository,
        ScheduleProcessor scheduleProcessor,
        ShiftAssignmentConflictService conflictService)
    {
        _shiftAssignmentRepository = shiftAssignmentRepository;
        _scheduleProcessor = scheduleProcessor;
        _conflictService = conflictService;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "scheduleemployee" => await ScheduleEmployee(jsonData.FromJson<ScheduleEmployeeRequest>()),
                "get" => await Get(jsonData.FromJson<GetShiftAssignmentRequest>()),
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
    /// Schedule an employee to a shift
    /// </summary>
    public async Task<string> ScheduleEmployee(ScheduleEmployeeRequest request)
    {
        try
        {
            _scheduleProcessor.SetCurrentUser(this.CurrentUser);

            #region Existing Assignments and validation of duplicating scheduling

            // BEFORE SAVING: Fetch existing assignments for the user
            var existingAssignmentsJson = await _shiftAssignmentRepository.Get(request.UserId.ToString(), null, CurrentUser.TenantID);
            var existingAssignments = JsonConvert.DeserializeObject<List<ShiftAssignmentDetailDto>>(existingAssignmentsJson);

            // Fetch schedules for all existing assignments
            var assignmentIdList = existingAssignments
                .Select(a => a.Id)
                .Distinct()
                .ToList();

            var sourceIds = new List<int>();
            sourceIds.AddRange(assignmentIdList);

            // Include staff availability source ids (using the user id as the availability source for now)
            if (request.UserId > 0)
            {
                sourceIds.Add(request.UserId);
            }

            var sourceTypes = new List<int>();
            if (assignmentIdList.Any())
            {
                sourceTypes.Add((int)ScheduleSourceTypes.ShiftAssignment);
            }
            if (request.UserId > 0)
            {
                sourceTypes.Add((int)ScheduleSourceTypes.StaffAvailability);
            }

            List<ScheduleResponse>? schedules = null;

            if (sourceIds.Any() && sourceTypes.Any())
            {
                var schedulesJson = await _scheduleProcessor.GetBySource(new GetScheduleRequest
                {
                    SourceIds = string.Join(",", sourceIds.Distinct()),
                    SourceTypes = string.Join(",", sourceTypes.Distinct())
                });

                schedules = JsonConvert.DeserializeObject<List<ScheduleResponse>>(schedulesJson);
            }

            // Filter schedules down to shift assignments for conflict detection (availability schedules fetched but unused for now)
            var shiftAssignmentSchedules = schedules?
                .Where(s => s.SourceType == (int)ScheduleSourceTypes.ShiftAssignment)
                .ToList();

            // Validate that the new schedule does not conflict with existing assignments
            var conflicts = _conflictService.DetectConflicts(request, existingAssignments, shiftAssignmentSchedules);
            if (conflicts != null && conflicts.Any())
            {
                return new
                {
                    success = false,
                    message = "Conflicting schedules detected.",
                    userId = request.UserId,
                    shiftId = request.ShiftId,
                    conflicts
                }.ToJson();
            }

            var availabilitySchedules = schedules?
                .Where(s => s.SourceType == (int)ScheduleSourceTypes.StaffAvailability)
                .ToList();

            var availabilityDtos = availabilitySchedules?.Select(s => new AvailabilityDto
            {
                Id = s.Id,
                UserId = s.SourceId,
                StartFrom = s.StartFrom,
                StartTime = s.StartTime,
                EndTime = s.EndTime,
                ValidUntil = s.ValidUntil
            }).ToList();

            var availabilityConflicts = _conflictService.DetectAvailabilityConflicts(request, availabilityDtos);
            if (availabilityConflicts != null && availabilityConflicts.Any())
            {
                return new
                {
                    success = false,
                    message = "Conflicting staff availability detected.",
                    userId = request.UserId,
                    shiftId = request.ShiftId,
                    conflicts = availabilityConflicts
                }.ToJson();
            }


            #endregion

            // Now proceed with saving the new/updated assignment
            var json = request.ToJson();
            var result = await _shiftAssignmentRepository.ScheduleEmployee(json, CurrentUser.LoginId, CurrentUser.TenantID);

            // Deserialize the result to get the assignment ID
            var assignmentResponse = result.FromJson<ScheduleEmployeeResponse>();

            // Process schedules if provided and assignment was successful
            if (assignmentResponse?.Success == true && request.Schedules != null && request.Schedules.Any())
            {
                var schedule = request.Schedules[0];
                schedule.SourceId = assignmentResponse.Id ?? 0; // Use the returned assignment ID

                var scheduleResult = await _scheduleProcessor.Save(schedule);
                var scheduleSaveResult = scheduleResult.FromJson<ScheduleSaveResult>();

                var updateResultJson = await _shiftAssignmentRepository.UpdateScheduleId(
                    assignmentResponse.Id.Value,
                    scheduleSaveResult.Id.Value,
                    CurrentUser.LoginId,
                    CurrentUser.TenantID);
            }

            return assignmentResponse?.ToJson() ?? result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get shift assignments by userIds or shiftIds
    /// </summary>
    public async Task<string> Get(GetShiftAssignmentRequest request)
    {
        try
        {
            var result = await _shiftAssignmentRepository.Get(request.UserIds, request.ShiftIds, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
