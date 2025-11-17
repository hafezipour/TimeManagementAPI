using TimeManagement.Application.Extensions;
using TimeManagement.Application.Processors;
using TimeManagement.Domain.Models;

namespace TimeManagement.Application.Services;

public class ProcessorRequestRouter
{
    private readonly IDictionary<string, BaseProcessor> _processorMap;

    public ProcessorRequestRouter(
        JobCodeProcessor jobCodeProcessor,
        WorkCodeProcessor workCodeProcessor,
        AccrualTypesProcessor accrualTypesProcessor,
        HolidayProcessor holidayProcessor,
        HolidayAssignmentProcessor holidayAssignmentProcessor,
        ShiftProcessor shiftProcessor,
        ScheduleProcessor scheduleProcessor,
        LayoutProcessor layoutProcessor,
        ColumnProcessor columnProcessor,
        EmployeeJobCodeAssignmentProcessor employeeJobCodeAssignmentProcessor,
        EmployeeWorkCodeAssignmentProcessor employeeWorkCodeAssignmentProcessor,
        EmployeeLabelAssignmentProcessor employeeLabelAssignmentProcessor,
        GroupsProcessor groupsProcessor,
        LabelsProcessor labelsProcessor,
        AssistantQualifiersProcessor assistantQualifiersProcessor,
        TradeBoardSettingsProcessor tradeBoardSettingsProcessor,
        ShiftAssignmentProcessor shiftAssignmentProcessor,
        CustomTableValuesProcessor customTableValuesProcessor)
    {
        _processorMap = new Dictionary<string, BaseProcessor>(StringComparer.OrdinalIgnoreCase)
        {
            ["jobcode"] = jobCodeProcessor,
            ["workcodes"] = workCodeProcessor,
            ["accrualtypes"] = accrualTypesProcessor,
            ["holidays"] = holidayProcessor,
            ["holidayassignment"] = holidayAssignmentProcessor,
            ["shifts"] = shiftProcessor,
            ["schedules"] = scheduleProcessor,
            ["layouts"] = layoutProcessor,
            ["columns"] = columnProcessor,
            ["employeejobcodeassignment"] = employeeJobCodeAssignmentProcessor,
            ["employeeworkcodeassignment"] = employeeWorkCodeAssignmentProcessor,
            ["employeelabelassignment"] = employeeLabelAssignmentProcessor,
            ["groups"] = groupsProcessor,
            ["labels"] = labelsProcessor,
            ["assistantqualifiers"] = assistantQualifiersProcessor,
            ["tradeboardsettings"] = tradeBoardSettingsProcessor,
            ["shiftassignment"] = shiftAssignmentProcessor,
            ["customtablevalues"] = customTableValuesProcessor
        };
    }

    public async Task<(int StatusCode, string Data)> RouteAsync(string? serviceName, string? methodName, string? jsonData, LoggedInUser? user)
    {
        if (string.IsNullOrWhiteSpace(serviceName))
        {
            var payload = new { success = false, message = "Service name is required." }.ToJson();
            return (400, payload);
        }

        if (user == null)
        {
            var payload = new { success = false, message = "Unauthorized" }.ToJson();
            return (401, payload);
        }

        if (!_processorMap.TryGetValue(serviceName, out var processor))
        {
            var payload = new { success = false, message = $"Unknown service: {serviceName}" }.ToJson();
            return (404, payload);
        }

        processor.SetCurrentUser(user);

        var safeJson = string.IsNullOrWhiteSpace(jsonData) ? "{}" : jsonData;
        var safeMethod = methodName ?? string.Empty;

        try
        {
            dynamic typedProcessor = processor;
            string result = await typedProcessor.ProcessRequest(serviceName, safeMethod, safeJson);
            return (200, result);
        }
        catch (Exception ex)
        {
            var payload = new { success = false, message = $"Error processing request: {ex.Message}" }.ToJson();
            return (500, payload);
        }
    }
}




