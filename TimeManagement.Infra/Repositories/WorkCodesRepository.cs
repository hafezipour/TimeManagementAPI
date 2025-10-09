using DbOperations;
using System.Data;
using TimeManagement.Domain.Models;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class WorkCodesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;
    public WorkCodesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAllAddresses(int organizationId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new List<SqlParameterModel>()
                {

                      new SqlParameterModel(){ Name = "TenantId", Value = tenantId},
                      new SqlParameterModel(){ Name = "OrganizationId", Value = organizationId}
                };
            return await _dbOperations.ExecuteDataSetAsync("usp_OrganizationAddresses_GetAll", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

}

