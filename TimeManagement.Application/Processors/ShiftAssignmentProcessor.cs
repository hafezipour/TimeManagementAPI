using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.DTOs.Schedules;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;
using Newtonsoft.Json;

namespace TimeManagement.Application.Processors;

public class ShiftAssignmentProcessor : BaseProcessor
{
    private readonly ShiftAssignmentRepository _shiftAssignmentRepository;
    private readonly ScheduleProcessor _scheduleProcessor;

    public ShiftAssignmentProcessor(
        ShiftAssignmentRepository shiftAssignmentRepository,
        ScheduleProcessor scheduleProcessor)
    {
        _shiftAssignmentRepository = shiftAssignmentRepository;
        _scheduleProcessor = scheduleProcessor;
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
                var sourceTypes = string.Join(",", existingAssignments.Select(a => "3")); // All are ShiftAssignment type

                // Fetch schedules for these assignments
                var schedulesJson = await _scheduleProcessor.GetBySource(new GetScheduleRequest
                {
                    SourceIds = assignmentIds,
                    SourceTypes = sourceTypes
                });

                // Deserialize schedules into List<ScheduleResponse>
                var schedules = JsonConvert.DeserializeObject<List<ScheduleResponse>>(schedulesJson);

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
            if (assignmentResponse.Success && request.Schedules != null && request.Schedules.Any())
            {
                var schedule = request.Schedules[0];
                schedule.SourceType = 3; // ShiftAssignment
                schedule.SourceId = assignmentResponse.Id ?? 0; // Use the returned assignment ID
                
                var scheduleResult = await _scheduleProcessor.Save(schedule);
            }
            
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

