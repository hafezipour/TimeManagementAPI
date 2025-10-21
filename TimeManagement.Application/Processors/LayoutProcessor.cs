using System.Text.Json;
using TimeManagement.Application.DTOs.Layouts;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class LayoutProcessor : BaseProcessor
{
    private readonly LayoutRepository _layoutRepository;

    public LayoutProcessor(LayoutRepository layoutRepository)
    {
        _layoutRepository = layoutRepository;
    }
    
    /// <summary>
    /// Save Layout Rows and Columns
    /// </summary>
    public async Task<string> SaveLayoutRowsColumns(LayoutRowsColumnsRequest layoutDto)
    {
        try
        {
            var json = layoutDto.ToJson();
            var result = await _layoutRepository.SaveLayoutRowsColumns(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving layout rows and columns: {ex.Message}" }.ToJson();
        }
    }
}
