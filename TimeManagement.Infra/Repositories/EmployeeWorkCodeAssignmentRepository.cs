using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class EmployeeWorkCodeAssignmentRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public EmployeeWorkCodeAssignmentRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    /// <summary>
    /// Get short list of work codes for an employee or common work codes for multiple employees
    /// </summary>
    public async Task<string> GetShortList(int? userId, bool common, string? userIds, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
            {
                new SqlParameterModel(){ Name = "UserId", Value = userId},
                new SqlParameterModel(){ Name = "Common", Value = common},
                new SqlParameterModel(){ Name = "UserIds", Value = userIds},
                new SqlParameterModel(){ Name = "TenantId", Value = tenantId}
            };
            return await _dbOperations.ExecuteDataSetAsync("usp_EmployeeWorkCodeAssignment_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

