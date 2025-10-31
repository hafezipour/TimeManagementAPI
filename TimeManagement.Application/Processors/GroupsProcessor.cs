using TimeManagement.Application.DTOs.Groups;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class GroupsProcessor : BaseProcessor
{
    private readonly GroupsRepository _groupsRepository;

    public GroupsProcessor(GroupsRepository groupsRepository)
    {
        _groupsRepository = groupsRepository;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "save" => await Save(jsonData.FromJson<SaveGroupRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteGroupRequest>()),
                "get" => await GetGroups(jsonData.FromJson<GetGroupRequest>()),
                "getshortlist" => await GetGroupsShortList(),
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

    public async Task<string> Save(SaveGroupRequest groupDto)
    {
        try
        {
            var json = groupDto.ToJson();
            var result = await _groupsRepository.SaveGroup(json, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving group: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> Delete(DeleteGroupRequest request)
    {
        try
        {
            var result = await _groupsRepository.DeleteGroup(request.GroupId, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting group: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetGroups(GetGroupRequest request)
    {
        try
        {
            var result = await _groupsRepository.GetGroupsList(
                request.GroupId,
                CurrentUser.TenantID,
                request.PageNumber ?? 1,
                request.PageSize ?? 10,
                request.SortColumn ?? "GroupName",
                request.SortDirection ?? "ASC",
                request.SearchTerm
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving groups: {ex.Message}" }.ToJson();
        }
    }

    public async Task<string> GetGroupsShortList()
    {
        try
        {
            var result = await _groupsRepository.GetGroupsShortList(CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving groups short list: {ex.Message}" }.ToJson();
        }
    }
}


