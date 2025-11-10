using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
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
    private readonly ScheduleEvaluator _scheduleEvaluator;
    private const int MaxOccurrenceHorizonYears = 5;

    public ShiftAssignmentProcessor(
        ShiftAssignmentRepository shiftAssignmentRepository,
        ScheduleProcessor scheduleProcessor,
        ScheduleEvaluator scheduleEvaluator)
    {
        _shiftAssignmentRepository = shiftAssignmentRepository;
        _scheduleProcessor = scheduleProcessor;
        _scheduleEvaluator = scheduleEvaluator;
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
            if (existingAssignments != null && existingAssignments.Any())
            {
                // Build comma-separated lists of assignment IDs
                var assignmentIds = string.Join(",", existingAssignments.Select(a => a.Id));
                var sourceTypes = Convert.ToString(((int)ScheduleSourceTypes.ShiftAssignment)); // All are ShiftAssignment type

                // Fetch schedules for these assignments
                var schedulesJson = await _scheduleProcessor.GetBySource(new GetScheduleRequest
                {
                    SourceIds = assignmentIds,
                    SourceTypes = sourceTypes
                });

                // Deserialize schedules into List<ScheduleResponse>
                var schedules = JsonConvert.DeserializeObject<List<ScheduleResponse>>(schedulesJson);

                // Validate that the new schedule does not conflict with existing assignments
                var conflicts = DetectScheduleConflicts(request, existingAssignments, schedules);
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

                // Log for debugging (for now)
                Console.WriteLine($"Found {existingAssignments.Count} existing assignments with {schedules?.Count ?? 0} schedules");
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

    private List<ScheduleConflictDetail>? DetectScheduleConflicts(
        ScheduleEmployeeRequest request,
        List<ShiftAssignmentDetailDto>? existingAssignments,
        List<ScheduleResponse>? existingSchedules)
    {
        if (request.Schedules == null || request.Schedules.Count == 0)
        {
            return null;
        }

        if (existingAssignments == null || existingAssignments.Count == 0 || existingSchedules == null || existingSchedules.Count == 0)
        {
            return null;
        }

        var newScheduleRequest = request.Schedules.First();

        var newSchedule = newScheduleRequest.ConvertToScheduleResponse(request.Schedules[0]);
        if (newSchedule == null || !newSchedule.StartFrom.HasValue)
        {
            return new List<ScheduleConflictDetail>
            {
                new ScheduleConflictDetail
                {
                    UserId = request.UserId,
                    RequestedScheduleId = newSchedule?.Id,
                    Reason = "Requested schedule is missing a valid start date."
                }
            };
        }

        var rangeStart = newSchedule.StartFrom.Value.Date;
        var rangeEnd = DetermineRangeEnd(newSchedule, rangeStart);

        if (rangeEnd < rangeStart)
        {
            return null;
        }

        var newOccurrences = GenerateOccurrences(newSchedule, rangeStart, rangeEnd);
        if (newOccurrences.Count == 0)
        {
            return null;
        }

        var schedulesByAssignmentId = existingSchedules
            .Where(s => s != null && s.SourceType == (int)ScheduleSourceTypes.ShiftAssignment && s.IsActive.GetValueOrDefault(true))
            .GroupBy(s => s.SourceId)
            .ToDictionary(g => g.Key, g => g.ToList());

        var conflicts = new List<ScheduleConflictDetail>();

        foreach (var assignment in existingAssignments)
        {
            if (assignment == null)
            {
                continue;
            }

            if (request.Id.HasValue && assignment.Id == request.Id.Value)
            {
                continue;
            }

            if (!schedulesByAssignmentId.TryGetValue(assignment.Id, out var assignmentSchedules) || assignmentSchedules == null)
            {
                continue;
            }

            foreach (var existingSchedule in assignmentSchedules)
            {
                if (!existingSchedule.StartFrom.HasValue)
                {
                    continue;
                }

                var existingOccurrences = GenerateOccurrences(existingSchedule, rangeStart, rangeEnd);

                if (existingOccurrences.Count == 0)
                {
                    continue;
                }

                var overlappingOccurrences = FindConflicts(newOccurrences, existingOccurrences);

                foreach (var overlap in overlappingOccurrences)
                {
                    conflicts.Add(new ScheduleConflictDetail
                    {
                        UserId = request.UserId,
                        ExistingAssignmentId = assignment.Id,
                        ExistingScheduleId = existingSchedule.Id,
                        RequestedScheduleId = newSchedule.Id,
                        Date = overlap.NewOccurrence.Date,
                        ExistingShiftName = assignment.ShiftName,
                        ExistingWindow = new TimeWindow
                        {
                            Start = overlap.ExistingOccurrence.Start,
                            End = overlap.ExistingOccurrence.End,
                            IsAllDay = overlap.ExistingOccurrence.IsAllDay
                        },
                        RequestedWindow = new TimeWindow
                        {
                            Start = overlap.NewOccurrence.Start,
                            End = overlap.NewOccurrence.End,
                            IsAllDay = overlap.NewOccurrence.IsAllDay
                        },
                        Reason = "Schedule overlap detected."
                    });
                }
            }
        }

        return conflicts.Count > 0 ? conflicts : null;
    }

    private List<OccurrencePair> FindConflicts(
        List<Occurrence> newOccurrences,
        List<Occurrence> existingOccurrences)
    {
        var overlaps = new List<OccurrencePair>();
        var existingIndex = 0;

        for (var i = 0; i < newOccurrences.Count; i++)
        {
            var newOccurrence = newOccurrences[i];

            while (existingIndex < existingOccurrences.Count && existingOccurrences[existingIndex].End <= newOccurrence.Start)
            {
                existingIndex++;
            }

            var checkIndex = existingIndex;

            while (checkIndex < existingOccurrences.Count && existingOccurrences[checkIndex].Start < newOccurrence.End)
            {
                var existingOccurrence = existingOccurrences[checkIndex];

                if (OccurrencesOverlap(newOccurrence, existingOccurrence))
                {
                    overlaps.Add(new OccurrencePair
                    {
                        NewOccurrence = newOccurrence,
                        ExistingOccurrence = existingOccurrence
                    });
                }

                checkIndex++;
            }
        }

        return overlaps;
    }

    private List<Occurrence> GenerateOccurrences(
        ScheduleResponse schedule,
        DateTime rangeStart,
        DateTime rangeEnd)
    {
        var occurrences = new List<Occurrence>();

        if (!schedule.StartFrom.HasValue)
        {
            return occurrences;
        }

        var effectiveStart = MaxDate(schedule.StartFrom.Value.Date, rangeStart);
        var scheduleEnd = GetScheduleEndDate(schedule);
        var effectiveEndCandidate = MinDate(scheduleEnd, rangeEnd);
        var effectiveEnd = effectiveEndCandidate ?? rangeEnd;

        if (effectiveEnd < effectiveStart)
        {
            return occurrences;
        }

        var totalDays = (int)(effectiveEnd - effectiveStart).TotalDays + 1;
        if (totalDays <= 0)
        {
            return occurrences;
        }

        for (int i = 0; i < totalDays; i++)
        {
            var date = effectiveStart.AddDays(i);

            if (!_scheduleEvaluator.IsDateValid(schedule, date))
            {
                continue;
            }

            var window = GetTimeWindow(schedule, date);

            if (window.IsAllDay || !window.Start.HasValue || !window.End.HasValue)
            {
                occurrences.Add(new Occurrence
                {
                    Date = date,
                    Start = window.Start ?? date,
                    End = window.End ?? date.AddDays(1),
                    IsAllDay = true
                });
                continue;
            }

            var start = window.Start.Value;
            var end = window.End.Value;
            var crossesMidnight = end.Date > date.Date;

            if (!crossesMidnight)
            {
                occurrences.Add(new Occurrence
                {
                    Date = date,
                    Start = start,
                    End = end,
                    IsAllDay = false
                });
            }
            else
            {
                var midnight = date.Date.AddDays(1);

                occurrences.Add(new Occurrence
                {
                    Date = date,
                    Start = start,
                    End = midnight,
                    IsAllDay = false
                });

                var tailDate = date.AddDays(1);
                if (tailDate <= rangeEnd)
                {
                    occurrences.Add(new Occurrence
                    {
                        Date = tailDate,
                        Start = midnight,
                        End = end,
                        IsAllDay = false
                    });
                }
            }
        }

        return occurrences;
    }

    private DateTime DetermineRangeEnd(ScheduleResponse schedule, DateTime rangeStart)
    {
        var scheduleEnd = GetScheduleEndDate(schedule);
        var horizonEnd = rangeStart.AddYears(MaxOccurrenceHorizonYears);
        var end = MinDate(scheduleEnd, horizonEnd);

        return (end ?? horizonEnd).Date;
    }

    private TimeWindow GetTimeWindow(ScheduleResponse schedule, DateTime date)
    {
        if (schedule.ScheduleWithoutTimes.GetValueOrDefault(false) ||
            !schedule.StartTime.HasValue || !schedule.EndTime.HasValue)
        {
            return new TimeWindow
            {
                Start = date.Date,
                End = date.Date.AddDays(1),
                IsAllDay = true
            };
        }

        var start = date.Date.Add(schedule.StartTime.Value);
        var end = date.Date.Add(schedule.EndTime.Value);

        if (end <= start)
        {
            end = end.AddDays(1);
        }

        return new TimeWindow
        {
            Start = start,
            End = end,
            IsAllDay = false
        };
    }

    private bool OccurrencesOverlap(Occurrence first, Occurrence second)
    {
        return first.Start < second.End && second.Start < first.End;
    }

    private DateTime? GetScheduleEndDate(ScheduleResponse schedule)
    {
        if (schedule == null)
        {
            return null;
        }

        var endTypeValue = schedule.EndType?.Trim()?.ToLowerInvariant();

        if (string.IsNullOrEmpty(endTypeValue))
        {
            return null;
        }

        if (endTypeValue == "ondate" || endTypeValue == "2")
        {
            return schedule.ValidUntil?.Date;
        }

        if ((endTypeValue == "afteroccurrences" || endTypeValue == "3") && schedule.MaxOccurrences.HasValue)
        {
            return GetEndDateByOccurrences(schedule);
        }

        return null;
    }

    private DateTime? GetEndDateByOccurrences(ScheduleResponse schedule)
    {
        if (!schedule.StartFrom.HasValue || !schedule.MaxOccurrences.HasValue)
        {
            return null;
        }

        var occurrencesRequired = schedule.MaxOccurrences.Value;
        var date = schedule.StartFrom.Value.Date;
        var remaining = occurrencesRequired;
        var guardCounter = 0;
        var maxIterations = 2000;
        DateTime? lastOccurrence = null;

        while (remaining > 0 && guardCounter < maxIterations)
        {
            if (_scheduleEvaluator.IsDateValid(schedule, date))
            {
                remaining--;
                lastOccurrence = date;
            }

            date = date.AddDays(1);
            guardCounter++;
        }

        return lastOccurrence;
    }

    private DateTime MaxDate(DateTime first, DateTime second) => first > second ? first : second;

    private DateTime? MinDate(DateTime? first, DateTime? second)
    {
        if (!first.HasValue)
        {
            return second;
        }

        if (!second.HasValue)
        {
            return first;
        }

        return first.Value < second.Value ? first.Value : second.Value;
    }


    


}
