using Grpc.Core;
using GrpcProtoLibrary.Protos;
using TimeManagement.Application.Processors;
using TimeManagement.Application.Extensions;
using TimeManagement.Application.Security;

namespace TimeManagement.Application.Services;

public class HttpGrpcService : HttpService.HttpServiceBase
{

    private readonly JobCodeProcessor _jobCodeProcessor;
    private readonly WorkCodeProcessor _workCodeProcessor;
    private readonly HolidayProcessor _holidayProcessor;
    private readonly HolidayAssignmentProcessor _holidayAssignmentProcessor;
    private readonly ShiftProcessor _shiftProcessor;
    private readonly ScheduleProcessor _scheduleProcessor;
    private readonly LayoutProcessor _layoutProcessor;
    private readonly ColumnProcessor _columnProcessor;
    private readonly ValidateToken _validateToken;
    private readonly EmployeeJobCodeAssignmentProcessor _employeeJobCodeAssignmentProcessor;
    private readonly EmployeeLabelAssignmentProcessor _employeeLabelAssignmentProcessor;
    private readonly GroupsProcessor _groupsProcessor;
    private readonly LabelsProcessor _labelsProcessor;
    private readonly TradeBoardSettingsProcessor _tradeBoardSettingsProcessor;

    public HttpGrpcService(
        JobCodeProcessor jobCodeProcessor,
        WorkCodeProcessor workCodeProcessor,
        HolidayProcessor holidayProcessor,
        HolidayAssignmentProcessor holidayAssignmentProcessor,
        ShiftProcessor shiftProcessor,
        ScheduleProcessor scheduleProcessor,
        LayoutProcessor layoutProcessor,
        ColumnProcessor columnProcessor,
        EmployeeJobCodeAssignmentProcessor employeeJobCodeAssignmentProcessor,
        EmployeeLabelAssignmentProcessor employeeLabelAssignmentProcessor,
        GroupsProcessor groupsProcessor,
        LabelsProcessor labelsProcessor,
        TradeBoardSettingsProcessor tradeBoardSettingsProcessor)
    {
        _jobCodeProcessor = jobCodeProcessor;
        _workCodeProcessor = workCodeProcessor;
        _holidayProcessor = holidayProcessor;
        _holidayAssignmentProcessor = holidayAssignmentProcessor;
        _shiftProcessor = shiftProcessor;
        _scheduleProcessor = scheduleProcessor;
        _layoutProcessor = layoutProcessor;
        _columnProcessor = columnProcessor;
        _validateToken = new ValidateToken();
        _employeeJobCodeAssignmentProcessor = employeeJobCodeAssignmentProcessor;
        _employeeLabelAssignmentProcessor = employeeLabelAssignmentProcessor;
        _groupsProcessor = groupsProcessor;
        _labelsProcessor = labelsProcessor;
        _tradeBoardSettingsProcessor = tradeBoardSettingsProcessor;
    }

    public override async Task<HttpResponse> Get(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Post(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Put(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    public override async Task<HttpResponse> Delete(HttpRequest request, ServerCallContext context)
    {
        var result = await RouteRequest(request, context);

        var response = new HttpResponse
        {
            StatusCode = result.StatusCode,
            Data = result.Data
        };

        return response;
    }

    /// <summary>
    /// Routes the request to the appropriate processor based on ServiceName
    /// </summary>
    private async Task<(int StatusCode, string Data)> RouteRequest(HttpRequest request, ServerCallContext context)
    {
        try
        {
            // Generic authentication check using ValidateToken
            var authResult = await _validateToken.AuthenticateRequest(context);
            if (!authResult.IsAuthenticated)
            {
                var unauthorizedResult = new
                {
                    success = false,
                    message = "Unauthorized"
                }.ToJson();
                return (401, unauthorizedResult);
            }

            string result;

            switch (request.ServiceName.ToLower())
            {
                case "jobcode":
                    _jobCodeProcessor.SetCurrentUser(authResult.User);
                    result = await _jobCodeProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "holidays":
                    _holidayProcessor.SetCurrentUser(authResult.User);
                    result = await _holidayProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "holidayassignment":
                    _holidayAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _holidayAssignmentProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "workcodes":
                    _workCodeProcessor.SetCurrentUser(authResult.User);
                    result = await _workCodeProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "shifts":
                    _shiftProcessor.SetCurrentUser(authResult.User);
                    result = await _shiftProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "schedules":
                    _scheduleProcessor.SetCurrentUser(authResult.User);
                    result = await _scheduleProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "layouts":
                    _layoutProcessor.SetCurrentUser(authResult.User);
                    result = await _layoutProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "columns":
                    _columnProcessor.SetCurrentUser(authResult.User);
                    result = await _columnProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;
                case "employeejobcodeassignment":
                    _employeeJobCodeAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _employeeJobCodeAssignmentProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "employeelabelassignment":
                    _employeeLabelAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _employeeLabelAssignmentProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "groups":
                    _groupsProcessor.SetCurrentUser(authResult.User);
                    result = await _groupsProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "labels":
                    _labelsProcessor.SetCurrentUser(authResult.User);
                    result = await _labelsProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "tradeboardsettings":
                    _tradeBoardSettingsProcessor.SetCurrentUser(authResult.User);
                    result = await _tradeBoardSettingsProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                default:
                    result = new
                    {
                        success = false,
                        message = $"Unknown service: {request.ServiceName}"
                    }.ToJson();
                    return (404, result);
            }

            return (200, result);
        }
        catch (Exception ex)
        {
            var errorResult = new
            {
                success = false,
                message = $"Error processing request: {ex.Message}"
            }.ToJson();
            return (500, errorResult);
        }
    }
}
