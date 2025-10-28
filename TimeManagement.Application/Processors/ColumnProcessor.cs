using Newtonsoft.Json;
using System.Collections.Generic;
using System.Text.Json;
using TimeManagement.Application.DTOs.Columns;
using TimeManagement.Application.Enums;
using TimeManagement.Application.Extensions;
using TimeManagement.Domain.Models;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ColumnProcessor : BaseProcessor
{
    private readonly ColumnRepository _columnRepository;
    private readonly ShiftProcessor _shiftProcessor;
    private readonly ScheduleProcessor _scheduleProcessor;

    public ColumnProcessor(ScheduleProcessor scheduleProcessor, ColumnRepository columnRepository, ShiftProcessor shiftProcessor)
    {
        _columnRepository = columnRepository;
        _scheduleProcessor = scheduleProcessor;
        _shiftProcessor = shiftProcessor;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Get, GetById, Save, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "get" => await Get(jsonData.FromJson<GetColumnsRequest>()),
                "getbyid" => await GetById(jsonData.FromJson<GetColumnByIdRequest>()),
                "save" => await Save(jsonData.FromJson<SaveColumnRequest>()),
                "delete" => await Delete(jsonData.FromJson<DeleteColumnRequest>()),
                "saveshift" => await SaveShift(jsonData.FromJson<SaveColumnShiftRequest>()),
                "deleteshift" => await DeleteShift(jsonData.FromJson<DeleteColumnShiftRequest>()),
                "batchupdateshiftorder" => await BatchUpdateShiftOrder(jsonData.FromJson<BatchUpdateShiftOrderRequest>()),
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
    /// Get all columns
    /// </summary>
    public async Task<string> Get(GetColumnsRequest request)
    {
        try
        {
            _shiftProcessor.SetCurrentUser(this.CurrentUser);
            var result = await _columnRepository.GetColumns(CurrentUser.TenantID, request.LayoutId);
            var columns = JsonConvert.DeserializeObject<List<Column>>(result);

            var schiftIds = columns.Where(c => c.ColumnShifts?.Count > 0).SelectMany(c => c.ColumnShifts).Select(cs => cs.ShiftId).ToList();
            var schedulingShifts = await _shiftProcessor.GetSchedulingShifts(request, schiftIds);

            foreach (var column in columns)
            {
                var ids = column.ColumnShifts?.Select(c => c.ShiftId).ToList() ?? new List<int>();
                var shiftsInColumn = schedulingShifts.Where(c => ids.Contains(c.Id)).ToList();
                
                // Sort shifts by DisplayOrder from ColumnShifts
                if (column.ColumnShifts != null && column.ColumnShifts.Count > 0)
                {
                    // Create a dictionary for quick lookup of display order by shift ID
                    var displayOrderMap = column.ColumnShifts.ToDictionary(cs => cs.ShiftId, cs => cs.DisplayOrder);
                    
                    // Sort shifts by display order
                    shiftsInColumn = shiftsInColumn
                        .OrderBy(shift => displayOrderMap.ContainsKey(shift.Id) ? displayOrderMap[shift.Id] : int.MaxValue)
                        .ToList();
                }
                
                column.SchedulingShifts = shiftsInColumn;
            }

            return columns.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving columns: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Get column by ID
    /// </summary>
    public async Task<string> GetById(GetColumnByIdRequest request)
    {
        try
        {
            var result = await _columnRepository.GetColumnById(request.Id, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save a Column (Create/Update)
    /// </summary>
    public async Task<string> Save(SaveColumnRequest columnDto)
    {
        try
        {
            var json = columnDto.ToJson();
            var result = await _columnRepository.SaveColumn(json, CurrentUser.LoginId, CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a Column
    /// </summary>
    public async Task<string> Delete(DeleteColumnRequest request)
    {
        try
        {
            var result = await _columnRepository.DeleteColumn(request.Id, CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Save a shift to a column
    /// </summary>
    public async Task<string> SaveShift(SaveColumnShiftRequest request)
    {
        try
        {
            var result = await _columnRepository.SaveColumnShift(request.ToJson(), CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error saving shift to column: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Batch update shift display orders for a column
    /// </summary>
    public async Task<string> BatchUpdateShiftOrder(BatchUpdateShiftOrderRequest request)
    {
        try
        {
            var result = await _columnRepository.BatchUpdateShiftOrder(request.ToJson(), CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error batch updating shift orders: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Delete a shift from a column
    /// </summary>
    public async Task<string> DeleteShift(DeleteColumnShiftRequest request)
    {
        try
        {
            var result = await _columnRepository.DeleteColumnShift(request.ToJson(), CurrentUser.LoginId, CurrentUser.TenantID);
            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error deleting shift from column: {ex.Message}" }.ToJson();
        }
    }
}

