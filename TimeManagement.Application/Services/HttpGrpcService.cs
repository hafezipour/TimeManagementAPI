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
    private readonly EmployeeWorkCodeAssignmentProcessor _employeeWorkCodeAssignmentProcessor;
    private readonly EmployeeLabelAssignmentProcessor _employeeLabelAssignmentProcessor;
    private readonly GroupsProcessor _groupsProcessor;
    private readonly LabelsProcessor _labelsProcessor;
    private readonly AssistantQualifiersProcessor _assistantQualifiersProcessor;
    private readonly TradeBoardSettingsProcessor _tradeBoardSettingsProcessor;
    private readonly ShiftAssignmentProcessor _shiftAssignmentProcessor;
    private readonly EmployeeAvailabilityProcessor _employeeAvailabilityProcessor;
    private readonly CustomTableValuesProcessor _customTableValuesProcessor;
    private readonly AccrualTypesProcessor _accrualTypesProcessor;
    private readonly AccrualProfilesProcessor _accrualProfilesProcessor;
    private readonly AccrualTracksProcessor _accrualTracksProcessor;
    private readonly AccrualRulesProcessor _accrualRulesProcessor;
    private readonly EmployeeAccrualSettingsProcessor _employeeAccrualSettingsProcessor;
    private readonly AccrualBanksProcessor _accrualBanksProcessor;
    private readonly AccrualTransactionsProcessor _accrualTransactionsProcessor;
    private readonly TimeOffCodesProcessor _timeOffCodesProcessor;
    private readonly TimeOffRequestsProcessor _timeOffRequestsProcessor;

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
        EmployeeWorkCodeAssignmentProcessor employeeWorkCodeAssignmentProcessor,
        EmployeeLabelAssignmentProcessor employeeLabelAssignmentProcessor,
        GroupsProcessor groupsProcessor,
        LabelsProcessor labelsProcessor,
        AssistantQualifiersProcessor assistantQualifiersProcessor,
        TradeBoardSettingsProcessor tradeBoardSettingsProcessor,
        ShiftAssignmentProcessor shiftAssignmentProcessor,
        EmployeeAvailabilityProcessor employeeAvailabilityProcessor,
        CustomTableValuesProcessor customTableValuesProcessor,
        AccrualTypesProcessor accrualTypesProcessor,
        AccrualProfilesProcessor accrualProfilesProcessor,
        AccrualTracksProcessor accrualTracksProcessor,
        AccrualRulesProcessor accrualRulesProcessor,
        EmployeeAccrualSettingsProcessor employeeAccrualSettingsProcessor,
        AccrualBanksProcessor accrualBanksProcessor,
        AccrualTransactionsProcessor accrualTransactionsProcessor,
        TimeOffCodesProcessor timeOffCodesProcessor,
        TimeOffRequestsProcessor timeOffRequestsProcessor)
    {
        _accrualTypesProcessor = accrualTypesProcessor;
        _accrualProfilesProcessor = accrualProfilesProcessor;
        _accrualTracksProcessor = accrualTracksProcessor;
        _accrualRulesProcessor = accrualRulesProcessor;
        _employeeAccrualSettingsProcessor = employeeAccrualSettingsProcessor;
        _accrualBanksProcessor = accrualBanksProcessor;
        _accrualTransactionsProcessor = accrualTransactionsProcessor;
        _timeOffCodesProcessor = timeOffCodesProcessor;
        _timeOffRequestsProcessor = timeOffRequestsProcessor;
        _customTableValuesProcessor = customTableValuesProcessor;
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
        _employeeWorkCodeAssignmentProcessor = employeeWorkCodeAssignmentProcessor;
        _employeeLabelAssignmentProcessor = employeeLabelAssignmentProcessor;
        _groupsProcessor = groupsProcessor;
        _labelsProcessor = labelsProcessor;
        _assistantQualifiersProcessor = assistantQualifiersProcessor;
        _tradeBoardSettingsProcessor = tradeBoardSettingsProcessor;
        _shiftAssignmentProcessor = shiftAssignmentProcessor;
        _employeeAvailabilityProcessor = employeeAvailabilityProcessor;
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

                case "employeeworkcodeassignment":
                    _employeeWorkCodeAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _employeeWorkCodeAssignmentProcessor.ProcessRequest(
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

                case "assistantqualifiers":
                    _assistantQualifiersProcessor.SetCurrentUser(authResult.User);
                    result = await _assistantQualifiersProcessor.ProcessRequest(
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

                case "shiftassignment":
                    _shiftAssignmentProcessor.SetCurrentUser(authResult.User);
                    result = await _shiftAssignmentProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "employeeavailability":
                    _employeeAvailabilityProcessor.SetCurrentUser(authResult.User);
                    result = await _employeeAvailabilityProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "customtablevalues":
                    _customTableValuesProcessor.SetCurrentUser(authResult.User);
                    result = await _customTableValuesProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualtypes":
                    _accrualTypesProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualTypesProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualprofiles":
                    _accrualProfilesProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualProfilesProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualtracks":
                    _accrualTracksProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualTracksProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualrules":
                    _accrualRulesProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualRulesProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "employeeaccrualsettings":
                    _employeeAccrualSettingsProcessor.SetCurrentUser(authResult.User);
                    result = await _employeeAccrualSettingsProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualbanks":
                    _accrualBanksProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualBanksProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "accrualtransactions":
                    _accrualTransactionsProcessor.SetCurrentUser(authResult.User);
                    result = await _accrualTransactionsProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "timeoffcodes":
                    _timeOffCodesProcessor.SetCurrentUser(authResult.User);
                    result = await _timeOffCodesProcessor.ProcessRequest(
                        request.ServiceName,
                        request.MethodName,
                        request.JsonData);
                    break;

                case "timeoffrequests":
                    _timeOffRequestsProcessor.SetCurrentUser(authResult.User);
                    result = await _timeOffRequestsProcessor.ProcessRequest(
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
