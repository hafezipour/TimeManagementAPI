using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class ShiftsRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public ShiftsRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Shifts with server-side paging
    /// </summary>
    public async Task<string> GetShifts(int? shiftId, int tenantId, int pageNumber = 1, int pageSize = 10, string sortColumn = "DisplayOrder", string sortDirection = "ASC", string searchTerm = null, int? statusCustomTableValueId = null)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "ShiftId", Value = shiftId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "PageNumber", Value = pageNumber},
                new SqlParameterModel(){ Name = "PageSize", Value = pageSize},
                new SqlParameterModel(){ Name = "SortColumn", Value = sortColumn},
                new SqlParameterModel(){ Name = "SortDirection", Value = sortDirection},
                new SqlParameterModel(){ Name = "SearchTerm", Value = searchTerm},
                new SqlParameterModel(){ Name = "StatusCustomTableValueId", Value = statusCustomTableValueId}
            };
            var result = await _dbOperations.ExecuteDataSetAsync("usp_Shifts_Get", param);
            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get a single Shift by ID
    /// </summary>
    public async Task<string> GetShift(int shiftId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "ShiftId", Value = shiftId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_GetById", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save (Insert/Update) Shift
    /// </summary>
    public async Task<string> SaveShift(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Close Shift by Id
    /// </summary>
    public async Task<string> CloseShift(int shiftId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "ShiftId", Value = shiftId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_Close", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete Shift by Id
    /// </summary>
    public async Task<string> DeleteShift(int shiftId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "ShiftId", Value = shiftId},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get Shifts Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetShiftsShortList(int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Get unassigned shifts (not in ColumnShifts table)
    /// </summary>
    public async Task<string> GetUnassignedShifts(int tenantId, int layoutId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                new SqlParameterModel(){ Name = "LayoutId", Value = layoutId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_Shifts_GetUnassigned", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

