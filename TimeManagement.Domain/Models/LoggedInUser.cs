namespace TimeManagement.Domain.Models
{
    public class LoggedInUser
    {
        public int LoginId { get; set; }
        public int TenantID { get; set; }
        public string UserName { get; set; }
    }
}
