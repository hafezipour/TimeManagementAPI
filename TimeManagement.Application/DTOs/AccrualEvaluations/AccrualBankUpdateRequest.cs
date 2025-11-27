using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TimeManagement.Application.DTOs.AccrualEvaluations
{
    public class AccrualBankUpdateRequest
    {
        public int BankId { get; set; }
        public int UserId { get; set; }
        public int AccrualProfileId { get; set; }
        public int AccrualRulesSlotId { get; set; }
        public decimal CurrentBalance { get; set; }
        public decimal NewBalance { get; set; }
        public DateTime? LastAccruedPeriodDate { get; set; }
    }
}
