using TimeManagement.Application.DTOs.Labels;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class LabelsProcessor : BaseProcessor
{
    private readonly LabelsRepository _labelsRepository;

    public LabelsProcessor(LabelsRepository labelsRepository)
    {
        _labelsRepository = labelsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await SaveLabel(jsonData.FromJson<SaveLabelRequest>()),
                "delete" => await DeleteLabel(jsonData.FromJson<DeleteLabelRequest>()),
                "get" => await GetLabelsList(jsonData.FromJson<GetLabelRequest>()),
                "getshortlist" => await GetLabelsShortList(),
                "assignlabel" => await AssignShiftLabel(jsonData.FromJson<AssignShiftLabelRequest>()),
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

    public async Task<string> SaveLabel(SaveLabelRequest labelDto)
    {
        try
        {
            var json = labelDto.ToJson();
            var result = await _labelsRepository.SaveLabel(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving label: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> DeleteLabel(DeleteLabelRequest request)
    {
        try
        {
            var result = await _labelsRepository.DeleteLabel(request.LabelId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting label: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetLabelsList(GetLabelRequest request)
    {
        try
        {
            var result = await _labelsRepository.GetLabelsList(
                request.LabelId,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "LabelName",
                request.SortDirection ?? "ASC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving labels: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetLabelsShortList()
    {
        try
        {
            var result = await _labelsRepository.GetLabelsShortList(CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving labels short list: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> AssignShiftLabel(AssignShiftLabelRequest request)
    {
        try
        {
            var result = await _labelsRepository.AssignShiftLabel(request.ShiftId, request.LabelId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error assigning label to shift: {ex.Message}" }.ToJson();
        }
    }
}

