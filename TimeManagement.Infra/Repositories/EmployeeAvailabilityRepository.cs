using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class EmployeeAvailabilityRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public EmployeeAvailabilityRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get Employee Availability with filters and shift assignments
    /// </summary>
    public async Task<string> GetAvailability(int userId, DateTime? startDate, DateTime? endDate, int tenantId)
    {
        try
        {
            if (startDate.HasValue && endDate.HasValue)
            {
                var diff = (endDate.Value - startDate.Value).TotalDays;

                // If difference is equal or greater than 27 days
                if (diff >= 27)
                {
                    // Move startDate back by 7 days
                    startDate = startDate.Value.AddDays(-7);

                    // Move endDate forward by 14 days
                    endDate = endDate.Value.AddDays(14);
                }
            }
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "StartDate", Value = startDate},
                new SqlParameterModel(){ Name = "EndDate", Value = endDate},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAvailability_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Save Employee Availability (Create/Update) with shift assignments
    /// </summary>
    public async Task<string> SaveAvailability(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Json", Value = json},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAvailability_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Delete Employee Availability and related assignments
    /// </summary>
    public async Task<string> DeleteAvailability(int id, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "Id", Value = id},
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeAvailability_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
