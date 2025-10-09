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

    

}

