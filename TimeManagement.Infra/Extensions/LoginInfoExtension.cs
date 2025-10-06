using System;
using System.Security.Claims;
using System.Security.Principal;
using TimeManagement.Domain.Models;

namespace TimeManagement.Infra.Extensions
{
    public static class LoginInfoExtension
    {
        /// <summary>
        /// that will basically read claims and set their values to be used where required
        /// </summary>
        /// <returns>return Logged In User Info Object</returns>
        public static LoggedInUser LoginInfo(this IIdentity identity)
        {
            try
            {
                var tenant = ((ClaimsIdentity)identity).FindFirst("tenantid");
                var obj = new LoggedInUser()
                {
                    LoginId = Convert.ToInt32(((ClaimsIdentity)identity).FindFirst("userid").Value),
                    UserName = ((ClaimsIdentity)identity).FindFirst("username").Value,
                    TenantID = int.Parse(tenant.Value)
                };
                return obj;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }
    }
}
