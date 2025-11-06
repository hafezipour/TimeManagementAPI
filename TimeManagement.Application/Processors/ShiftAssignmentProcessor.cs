using TimeManagement.Application.DTOs.ShiftAssignments;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

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
}

