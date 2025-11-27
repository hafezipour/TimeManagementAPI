using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.AccrualEvaluations
{
    public class AccrualTransactionResponse
    {
        public int AccrualBankId { get; set; }
        public DateTime? AccrualPeriodDate { get; set; }
    }
}
