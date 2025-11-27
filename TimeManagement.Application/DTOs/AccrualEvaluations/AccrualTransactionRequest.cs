using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.AccrualEvaluations
{
    public class AccrualTransactionRequest
    {
        public int AccrualBankId { get; set; }
        public int UserId { get; set; }
        public int AccrualProfileId { get; set; }
        public int AccrualRulesSlotId { get; set; }
        public DateTime AccrualPeriodDate { get; set; }
        public decimal Amount { get; set; }
        public decimal OldBalance { get; set; }
        public decimal NewBalance { get; set; }
        public string Description { get; set; } = string.Empty;
    }
}
