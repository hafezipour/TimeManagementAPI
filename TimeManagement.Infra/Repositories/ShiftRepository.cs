using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebPortal.EF.Repository.DataBaseRepo;

namespace TimeManagement.Infra.Repositories
{
    public class ShiftRepository
    {
        private readonly EfDbOperationsRepository _dbOperations;

        public ShiftRepository(EfDbOperationsRepository dbOperations)
        {
            _dbOperations = dbOperations;
        }


    }
}
