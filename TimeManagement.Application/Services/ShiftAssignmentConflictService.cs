using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Enums;

namespace TimeManagement.Application.Services;

/// <summary>
/// Provides utilities for detecting schedule conflicts for shift assignments.
/// </summary>
public class ShiftAssignmentConflictService
{
    private readonly ScheduleEvaluator _scheduleEvaluator;
    private const int MaxOccurrenceHorizonYears = 5;
    private const int MaxOccurrenceIterationDays = 2000;
    private const int MaxAvailabilityConflictEntries = 10;

    public ShiftAssignmentConflictService(ScheduleEvaluator scheduleEvaluator)
    {
        _scheduleEvaluator = scheduleEvaluator;
    }

    /// <summary>
    /// Detect schedule conflicts using precalculated occurrences from assignments (FromDate/ToDate) 
    /// instead of generating from ScheduleResponse Schedules property.
    /// </summary>
    public List<ScheduleConflictDetail>? DetectConflicts2(
        ScheduleEmployeeRequest request,
        List<ShiftAssignmentDetailDto> assignments)
    {
        var newScheduleRequest = request.Schedules.First();
        var newSchedule = ConvertToScheduleResponse(newScheduleRequest);
        var rangeStart = newSchedule.StartFrom.Value.Date;
        var rangeEnd = DetermineRangeEnd(newSchedule, rangeStart);
        var scheduleOccurrences = GenerateOccurrences(newSchedule, rangeStart, rangeEnd);
        var conflicts = new List<ScheduleConflictDetail>();

        foreach (var assignment in assignments)
        {
            foreach (var occurrence in scheduleOccurrences)
            {
                if (assignment.FromDate.HasValue && assignment.ToDate.HasValue &&
                    occurrence.Window.Start.HasValue && occurrence.Window.End.HasValue)
                {
                    // Check if date ranges overlap: [assignment.FromDate, assignment.ToDate] and [occurrence.Window.Start, occurrence.Window.End]
                    // Two ranges overlap if: range1.Start <= range2.End && range2.Start <= range1.End
                    var assignmentFrom = assignment.FromDate.Value;
                    var assignmentTo = assignment.ToDate.Value;
                    var occurrenceStart = occurrence.Window.Start.Value;
                    var occurrenceEnd = occurrence.Window.End.Value;

                    if (assignmentFrom < occurrenceEnd && occurrenceStart < assignmentTo)
                    {
                        conflicts.Add(new ScheduleConflictDetail
                        {
                            UserId = request.UserId,
                            ExistingAssignmentId = assignment.Id,
                            ExistingScheduleId = newSchedule.Id,
                            RequestedScheduleId = newSchedule.Id,
                            Date = occurrence.Date,
                            ExistingShiftName = assignment.ShiftName,
                            ExistingWindow = occurrence.Window,
                            RequestedWindow = occurrence.Window,
                            Reason = "Schedule overlap detected."
                        });
                    }
                }
            }
        }

        return conflicts.Count > 0 ? conflicts : null;
    }

    public List<ScheduleConflictDetail>? DetectAvailabilityConflicts(int userId,ScheduleRequest newScheduleRequest, List<AvailabilityDto>? availabilityWindows)
    {
        //var newScheduleRequest = request.Schedules.First();
        var newSchedule = ConvertToScheduleResponse(newScheduleRequest);

        var rangeStart = newSchedule.StartFrom.Value.Date;
        var rangeEnd = DetermineRangeEnd(newSchedule, rangeStart);
        var newOccurrences = GenerateOccurrences(newSchedule, rangeStart, rangeEnd);

        if (!newOccurrences.Any())
        {
            return null;
        }

        if (availabilityWindows == null || availabilityWindows.Count == 0)
        {
            return newOccurrences
                .Take(MaxAvailabilityConflictEntries)
                .Select(occurrence => BuildAvailabilityConflictDetail(
                    userId,
                    newSchedule,
                    occurrence,
                    null,
                    "No staff availability defined for this user."))
                .ToList();
        }

        var conflicts = new List<ScheduleConflictDetail>();

        foreach (var occurrence in newOccurrences)
        {
            var coveringAvailability = availabilityWindows
                .FirstOrDefault(a => AvailabilityCoversOccurrence(a, occurrence));

            if (coveringAvailability == null)
            {
                conflicts.Add(BuildAvailabilityConflictDetail(
                    userId,
                    newSchedule,
                    occurrence,
                    null,
                    "Scheduled time falls outside staff availability."));
            }

            if (conflicts.Count >= MaxAvailabilityConflictEntries)
            {
                break;
            }
        }

        return conflicts.Count > 0 ? conflicts : null;
    }

    #region Occurrence Generation / Comparison

    private List<ScheduleOccurrence> GenerateOccurrences(
        ScheduleResponse schedule,
        DateTime rangeStart,
        DateTime rangeEnd)
    {
        var occurrences = new List<ScheduleOccurrence>();

        // Bail out if the schedule does not define a start date.
        if (!schedule.StartFrom.HasValue)
        {
            return occurrences;
        }

        // Clamp the effective window to dates where the schedule is both active and within our evaluation range.
        var effectiveStart = MaxDate(schedule.StartFrom.Value.Date, rangeStart);
        var scheduleEnd = GetScheduleEndDate(schedule);
        var effectiveEndCandidate = MinDate(scheduleEnd, rangeEnd);
        var effectiveEnd = effectiveEndCandidate ?? rangeEnd;

        if (effectiveEnd < effectiveStart)
        {
            return occurrences;
        }

        // Iterate day by day through the evaluation window.
        var totalDays = (int)(effectiveEnd - effectiveStart).TotalDays + 1;
        if (totalDays <= 0)
        {
            return occurrences;
        }

        for (int i = 0; i < totalDays; i++)
        {
            var date = effectiveStart.AddDays(i);

            // Use ScheduleEvaluator to determine if the schedule fires on this date.
            if (!_scheduleEvaluator.IsDateValid(schedule, date))
            {
                continue;
            }

            // Build the time window for this occurrence.  All-day schedules are recorded once,
            // timed schedules might generate one or two occurrences depending on whether they cross midnight.
            var window = GetTimeWindow(schedule, date);

            if (window.IsAllDay || !window.Start.HasValue || !window.End.HasValue)
            {
                occurrences.Add(new ScheduleOccurrence
                {
                    Date = date,
                    Window = new TimeWindow
                    {
                        Start = window.Start ?? date,
                        End = window.End ?? date.AddDays(1),
                        IsAllDay = true
                    }
                });

                continue;
            }

            var start = window.Start.Value;
            var end = window.End.Value;
            var crossesMidnight = end.Date > date.Date;

            if (!crossesMidnight)
            {
                // Simple case: one occurrence inside the same calendar day.
                occurrences.Add(new ScheduleOccurrence
                {
                    Date = date,
                    Window = new TimeWindow
                    {
                        Start = start,
                        End = end,
                        IsAllDay = false
                    }
                });
            }
            else
            {
                var midnight = date.Date.AddDays(1);

                occurrences.Add(new ScheduleOccurrence
                {
                    Date = date,
                    // First segment runs from the start time up to midnight.
                    Window = new TimeWindow
                    {
                        Start = start,
                        End = midnight,
                        IsAllDay = false
                    }
                });

                var tailDate = date.AddDays(1);
                if (tailDate <= rangeEnd)
                {
                    // Second segment handles the carryover on the following day.
                    occurrences.Add(new ScheduleOccurrence
                    {
                        Date = tailDate,
                        Window = new TimeWindow
                        {
                            Start = midnight,
                            End = end,
                            IsAllDay = false
                        }
                    });
                }
            }
        }

        return occurrences;
    }

    private List<OccurrencePair> FindConflicts(
        List<ScheduleOccurrence> newOccurrences,
        List<ScheduleOccurrence> existingOccurrences)
    {
        var overlaps = new List<OccurrencePair>();
        // Keep track of where we are in the existing list so we do not restart comparisons from zero each time.
        var existingIndex = 0;

        for (var i = 0; i < newOccurrences.Count; i++)
        {
            var newOccurrence = newOccurrences[i];

            // Advance through existing occurrences until we reach a window that could overlap.
            while (existingIndex < existingOccurrences.Count && existingOccurrences[existingIndex].Window.End <= newOccurrence.Window.Start)
            {
                existingIndex++;
            }

            // Compare the current new occurrence with all potentially overlapping existing occurrences.
            var checkIndex = existingIndex;

            while (checkIndex < existingOccurrences.Count && existingOccurrences[checkIndex].Window.Start < newOccurrence.Window.End)
            {
                var existingOccurrence = existingOccurrences[checkIndex];

                // Record conflicts where the time windows intersect.
                if (OccurrencesOverlap(newOccurrence.Window, existingOccurrence.Window))
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

    private bool OccurrencesOverlap(TimeWindow first, TimeWindow second)
    {
        return first.Start < second.End && second.Start < first.End;
    }

    #endregion

    #region Range Helpers

    private DateTime DetermineRangeEnd(ScheduleResponse schedule, DateTime rangeStart)
    {
        // The natural end of a schedule can be an explicit date, an occurrence count, or open-ended.
        var scheduleEnd = GetScheduleEndDate(schedule);
        // Hard-limit the evaluation window to five years to avoid runaway calculations.
        var horizonEnd = rangeStart.AddYears(MaxOccurrenceHorizonYears);
        var end = MinDate(scheduleEnd, horizonEnd);

        return (end ?? horizonEnd).Date;
    }

    public DateTime? GetScheduleEndDate(ScheduleResponse schedule)
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
        // Walk the calendar one day at a time until the required number of occurrences is observed.
        var date = schedule.StartFrom.Value.Date;
        var remaining = occurrencesRequired;
        var guardCounter = 0;
        DateTime? lastOccurrence = null;

        while (remaining > 0 && guardCounter < MaxOccurrenceIterationDays)
        {
            if (_scheduleEvaluator.IsDateValid(schedule, date))
            {
                // Count down remaining occurrences and track the last valid date.
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

    #endregion

    #region Conversion Helpers

    private ScheduleResponse? ConvertToScheduleResponse(ScheduleRequest request)
    {
        if (request == null)
        {
            return null;
        }

        var schedule = new ScheduleResponse
        {
            // Carry over identifying metadata for conflict reporting.
            Id = request.Id ?? 0,
            SourceType = request.SourceType ?? (int)ScheduleSourceTypes.ShiftAssignment,
            SourceId = request.SourceId ?? 0,
            StartFrom = request.StartFrom,
            ScheduleWithoutTimes = request.ScheduleWithoutTimes,
            ScheduleType = request.ScheduleType,
            RepeatEvery = request.RepeatEvery,
            EndType = Enum.IsDefined(typeof(EndType), request.EndType)
                ? Enum.GetName(typeof(EndType), request.EndType)
                : request.EndType.ToString(CultureInfo.InvariantCulture),
            ValidUntil = request.ValidUntil.HasValue ? new DateTimeOffset(request.ValidUntil.Value) : null,
            MaxOccurrences = request.MaxOccurrences,
            IsActive = request.IsActive,
            Frequency = request.Frequency?.Select(f => new ScheduleFrequencyResponse
            {
                Day = f.Day,
                DayType = f.DayType
            }).ToList()
        };

        // Parse requested times using tolerant parsing (supporting HH:mm or culture-friendly strings).
        var startTime = ParseTime(request.StartTime);
        var endTime = ParseTime(request.EndTime);

        schedule.StartTime = startTime;
        schedule.EndTime = endTime;

        // Flag schedules without explicit times so consumers know these are all-day occurrences.
        if (startTime == null || endTime == null)
        {
            schedule.ScheduleWithoutTimes = true;
        }

        return schedule;
    }

    private TimeSpan? ParseTime(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        if (TimeSpan.TryParse(value, CultureInfo.InvariantCulture, out var timeSpan))
        {
            return timeSpan;
        }

        if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateTime))
        {
            return dateTime.TimeOfDay;
        }

        return null;
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

    private ScheduleConflictDetail BuildAvailabilityConflictDetail(
        int userId,
        ScheduleResponse newSchedule,
        ScheduleOccurrence occurrence,
        AvailabilityDto? availability,
        string reason)
    {
        var requestedWindow = new TimeWindow
        {
            Start = occurrence.Window.Start,
            End = occurrence.Window.End,
            IsAllDay = occurrence.Window.IsAllDay
        };

        TimeWindow availabilityWindow;

        if (availability == null || !availability.StartTime.HasValue || !availability.EndTime.HasValue)
        {
            availabilityWindow = new TimeWindow();
        }
        else
        {
            var start = occurrence.Date.Date.Add(availability.StartTime.Value);
            var end = occurrence.Date.Date.Add(availability.EndTime.Value);
            if (end <= start)
            {
                end = end.AddDays(1);
            }

            availabilityWindow = new TimeWindow
            {
                Start = start,
                End = end,
                IsAllDay = false
            };
        }

        return new ScheduleConflictDetail
        {
            UserId = userId,
            RequestedScheduleId = newSchedule.Id,
            ExistingScheduleId = availability?.Id,
            ExistingShiftName = availability != null ? "Staff Availability" : "No Availability",
            Date = occurrence.Date,
            RequestedWindow = requestedWindow,
            ExistingWindow = availabilityWindow,
            Reason = reason
        };
    }

    private bool AvailabilityCoversOccurrence(AvailabilityDto availability, ScheduleOccurrence occurrence)
    {
        if (availability.StartFrom.HasValue && occurrence.Date < availability.StartFrom.Value.Date)
        {
            return false;
        }

        if (availability.ValidUntil.HasValue && occurrence.Date > availability.ValidUntil.Value.Date)
        {
            return false;
        }

        if (!availability.StartTime.HasValue)
        {
            // No time bounds; availability is all day for the valid range
            return true;
        }

        var availabilityStart = occurrence.Date.Date.Add(availability.StartTime.Value);
        DateTime availabilityEnd;

        if (availability.EndTime.HasValue)
        {
            availabilityEnd = occurrence.Date.Date.Add(availability.EndTime.Value);
            if (availabilityEnd <= availabilityStart)
            {
                availabilityEnd = availabilityEnd.AddDays(1);
            }
        }
        else
        {
            // No end time; treat as open-ended from the start time forward
            availabilityEnd = DateTime.MaxValue;
        }

        if (!occurrence.Window.Start.HasValue || !occurrence.Window.End.HasValue)
        {
            return false;
        }

        return occurrence.Window.Start.Value >= availabilityStart &&
               occurrence.Window.End.Value <= availabilityEnd;
    }

    #endregion
}

public class ScheduleConflictDetail
{
    public int UserId { get; set; }
    public int? ExistingAssignmentId { get; set; }
    public int? ExistingScheduleId { get; set; }
    public int? RequestedScheduleId { get; set; }
    public DateTime Date { get; set; }
    public string? ExistingShiftName { get; set; }
    public TimeWindow ExistingWindow { get; set; } = new();
    public TimeWindow RequestedWindow { get; set; } = new();
    public string? Reason { get; set; }
}

public class ScheduleOccurrence
{
    public DateTime Date { get; set; }
    public TimeWindow Window { get; set; } = new();
}

public class OccurrencePair
{
    public ScheduleOccurrence NewOccurrence { get; set; } = new();
    public ScheduleOccurrence ExistingOccurrence { get; set; } = new();
}

public class TimeWindow
{
    public DateTime? Start { get; set; }
    public DateTime? End { get; set; }
    public bool IsAllDay { get; set; }
}

