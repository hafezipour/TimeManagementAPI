using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Grpc.Core;
using TimeManagement.Application.Security;
using TimeManagement.Domain.Models;
using WebPortalSecurityManager;

namespace TimeManagement.Application.Processors;

public abstract class BaseProcessor
{
    protected LoggedInUser? CurrentUser { get; private set; }
    protected ClaimsPrincipal? CurrentPrincipal { get; private set; }
    protected bool IsAuthenticated { get; private set; }

    /// <summary>
    /// Validates the JWT token from gRPC metadata and extracts user information
    /// </summary>
    /// <param name="context">gRPC ServerCallContext containing metadata/headers</param>
    /// <returns>True if authentication successful, false otherwise</returns>
    protected async Task<bool> AuthenticateRequest(ServerCallContext context)
    {
        try
        {
            var metadata = context.RequestHeaders;
            
            // Get authorization token from metadata
            var authHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "authorization");
            if (authHeader == null)
            {
                IsAuthenticated = false;
                return false;
            }

            string token = authHeader.Value;
            if (!string.IsNullOrEmpty(token) && token.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                token = token.Replace("Bearer ", "").Replace("bearer ", "");
            }

            if (string.IsNullOrEmpty(token))
            {
                IsAuthenticated = false;
                return false;
            }

            // Read token to get tenant ID
            var handler = new JwtSecurityTokenHandler();
            var jsonToken = handler.ReadToken(token);
            var tokenS = jsonToken as JwtSecurityToken;
            
            int tenantId = int.Parse(tokenS?.Claims.FirstOrDefault(c => c.Type == "tenantid")?.Value ?? "0");
            
            // Get configurations for the tenant
            var configurations = await new WebPortalCredentialsHandler().GetConfigurationsModel(tenantId);
            
            // Validate the token
            ClaimsPrincipal? claimsPrincipal = new ValidateToken().IsValidToken(configurations.JwtSigningKey, token);
            
            if (claimsPrincipal == null)
            {
                IsAuthenticated = false;
                return false;
            }

            // Check for tenant_id and login_id override in headers
            var tenantIdHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "tenant_id");
            var loginIdHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "login_id");

            if (tenantIdHeader != null && !string.IsNullOrEmpty(tenantIdHeader.Value))
            {
                var updatedIdentity = new ClaimsIdentity(claimsPrincipal.Identity);
                
                // Update tenant_id
                var existingClaimTenantId = updatedIdentity.FindFirst("tenantid");
                if (existingClaimTenantId != null)
                {
                    updatedIdentity.RemoveClaim(existingClaimTenantId);
                }
                updatedIdentity.AddClaim(new Claim("tenantid", tenantIdHeader.Value));

                // Update login_id if present
                if (loginIdHeader != null && !string.IsNullOrEmpty(loginIdHeader.Value))
                {
                    var existingClaimUserId = updatedIdentity.FindFirst("userid");
                    if (existingClaimUserId != null)
                    {
                        updatedIdentity.RemoveClaim(existingClaimUserId);
                    }
                    updatedIdentity.AddClaim(new Claim("userid", loginIdHeader.Value));
                }

                CurrentPrincipal = new ClaimsPrincipal(updatedIdentity);
            }
            else
            {
                var claimsIdentity = (ClaimsIdentity)claimsPrincipal.Identity!;
                CurrentPrincipal = new ClaimsPrincipal(claimsIdentity);
            }

            // Extract LoggedInUser information
            CurrentUser = ExtractLoggedInUser(CurrentPrincipal.Identity);
            IsAuthenticated = CurrentUser != null;
            
            return IsAuthenticated;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Authentication error: " + ex.Message);
            IsAuthenticated = false;
            return false;
        }
    }

    /// <summary>
    /// Extracts LoggedInUser information from claims identity
    /// </summary>
    private LoggedInUser? ExtractLoggedInUser(System.Security.Principal.IIdentity? identity)
    {
        try
        {
            if (identity == null || !identity.IsAuthenticated)
            {
                return null;
            }

            var claimsIdentity = (ClaimsIdentity)identity;
            var tenant = claimsIdentity.FindFirst("tenantid");
            var userId = claimsIdentity.FindFirst("userid");
            var userName = claimsIdentity.FindFirst("username");

            if (tenant == null || userId == null)
            {
                return null;
            }

            var obj = new LoggedInUser
            {
                LoginId = Convert.ToInt32(userId.Value),
                UserName = userName?.Value ?? string.Empty,
                TenantID = int.Parse(tenant.Value)
            };
            
            return obj;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error extracting logged in user: " + ex.Message);
            return null;
        }
    }

    /// <summary>
    /// Gets a specific claim value
    /// </summary>
    protected string? GetClaimValue(string claimType)
    {
        return CurrentPrincipal?.FindFirst(claimType)?.Value;
    }
}

