using TimeManagement.Application.DTOs.AssistantQualifiers;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AssistantQualifiersProcessor : BaseProcessor
{
    private readonly AssistantQualifiersRepository _repository;

    public AssistantQualifiersProcessor(AssistantQualifiersRepository repository)
    {
        _repository = repository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveAssistantQualifierRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteAssistantQualifierRequest>()),
                "get" => await Get(jsonData.FromJson<GetAssistantQualifierRequest>()),
                "getshortlist" => await GetShortList(),
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

    public async Task<string> Save(SaveAssistantQualifierRequest request)
    {
        try
        {
            var json = request.ToJson();
            var result = await _repository.Save(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving assistant qualifier: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> Delete(DeleteAssistantQualifierRequest request)
    {
        try
        {
            var result = await _repository.Delete(request.Id, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting assistant qualifier: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> Get(GetAssistantQualifierRequest request)
    {
        try
        {
            var result = await _repository.Get(
                request.Id,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "Name",
                request.SortDirection ?? "ASC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving assistant qualifiers: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetShortList()
    {
        try
        {
            var result = await _repository.GetShortList(CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving assistant qualifiers short list: {ex.Message}" }.ToJson();
        }
    }
}


