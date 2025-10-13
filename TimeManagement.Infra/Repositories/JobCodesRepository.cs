using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class JobCodesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public JobCodesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get JobCodes Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetJobCodesShortList(int tenantId)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "TenantId", Value = tenantId }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_GetShortList", param);
    }

    /// <summary>
    /// Get all JobCodes
    /// </summary>
    public async Task<string> GetJobCodes(int tenantId)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "TenantId", Value = tenantId }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_Get", param);
    }

    /// <summary>
    /// Get a Job Code by ID
    /// </summary>
    public async Task<string> GetJobCodeById(int id, int tenantId)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "Id", Value = id },
            new SqlParameterModel { Name = "TenantId", Value = tenantId }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_GetById", param);
    }

    /// <summary>
    /// Add a new Job Code
    /// </summary>
    public async Task<string> AddJobCode(string jobTitle, string code, string description, string category,
        bool isExempt, decimal payRate, decimal defaultHoursPerWeek, bool isActive, int tenantId, int createdBy)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "JobTitle", Value = jobTitle },
            new SqlParameterModel { Name = "Code", Value = code },
            new SqlParameterModel { Name = "Description", Value = description },
            new SqlParameterModel { Name = "Category", Value = category },
            new SqlParameterModel { Name = "IsExempt", Value = isExempt },
            new SqlParameterModel { Name = "PayRate", Value = payRate },
            new SqlParameterModel { Name = "DefaultHoursPerWeek", Value = defaultHoursPerWeek },
            new SqlParameterModel { Name = "IsActive", Value = isActive },
            new SqlParameterModel { Name = "TenantId", Value = tenantId },
            new SqlParameterModel { Name = "CreatedBy", Value = createdBy }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_Add", param);
    }

    /// <summary>
    /// Update an existing Job Code
    /// </summary>
    public async Task<string> UpdateJobCode(int id, string jobTitle, string code, string description, string category,
        bool isExempt, decimal payRate, decimal defaultHoursPerWeek, bool isActive, int tenantId, int updatedBy)
    {
        var param = new List<SqlParameterModel>
        {
            new SqlParameterModel { Name = "Id", Value = id },
            new SqlParameterModel { Name = "JobTitle", Value = jobTitle },
            new SqlParameterModel { Name = "Code", Value = code },
            new SqlParameterModel { Name = "Description", Value = description },
            new SqlParameterModel { Name = "Category", Value = category },
            new SqlParameterModel { Name = "IsExempt", Value = isExempt },
            new SqlParameterModel { Name = "PayRate", Value = payRate },
            new SqlParameterModel { Name = "DefaultHoursPerWeek", Value = defaultHoursPerWeek },
            new SqlParameterModel { Name = "IsActive", Value = isActive },
            new SqlParameterModel { Name = "TenantId", Value = tenantId },
            new SqlParameterModel { Name = "UpdatedBy", Value = updatedBy }
        };
        return await _dbOperations.ExecuteDataSetAsync("usp_JobCodes_Update", param);
    }
}

