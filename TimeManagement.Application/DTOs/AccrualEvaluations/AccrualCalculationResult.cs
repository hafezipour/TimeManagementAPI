using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.AccrualEvaluations
{
    public class AccrualCalculationResult
    {
        public List<AccrualTransactionRequest> MissingTransactions { get; set; } = new();
        public AccrualBankUpdateRequest? BankUpdate { get; set; }
    }
}
