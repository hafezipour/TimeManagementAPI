using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Grpc.Core;
using Microsoft.IdentityModel.Tokens;
using TimeManagement.Domain.Models;
using WebPortalSecurityManager;

namespace TimeManagement.Application.Security;

public class ValidateToken
{
    public ClaimsPrincipal? IsValidToken(string jwtSigningKey, string token)
    {
        try
        {
            var key = Encoding.UTF8.GetBytes(jwtSigningKey);
            var issuerSigningKey = new SymmetricSecurityKey(key);
            var signingCredentials = new SigningCredentials(issuerSigningKey, SecurityAlgorithms.HmacSha256Signature);
            var handler = new JwtSecurityTokenHandler();
            var tokenSecure = handler.ReadToken(token);
            
            if (DateTime.UtcNow > tokenSecure.ValidTo) // Token is expired
            {
                return null;
            }
            
            var validations = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = issuerSigningKey,
                ValidateIssuer = false,
                ValidateAudience = false
            };
            
            var claims = handler.ValidateToken(token, validations, out tokenSecure);
            return claims;
        }
        catch (Exception ex)
        {
            Console.WriteLine("THIS TOKEN IS INVALID: " + ex.Message);
            return null;
        }
    }

    /// <summary>
    /// Authenticates the gRPC request and extracts user information
    /// </summary>
    /// <param name="context">gRPC ServerCallContext containing metadata/headers</param>
    /// <returns>Tuple with authentication status and LoggedInUser</returns>
    public async Task<(bool IsAuthenticated, LoggedInUser? User)> AuthenticateRequest(ServerCallContext context)
    {
        try
        {
            var metadata = context.RequestHeaders;
            
            // Get authorization token from metadata
            var authHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "authorization");
            if (authHeader == null)
            {
                return (false, null);
            }

            string token = authHeader.Value;
            if (!string.IsNullOrEmpty(token) && token.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                token = token.Replace("Bearer ", "").Replace("bearer ", "");
            }

            if (string.IsNullOrEmpty(token))
            {
                return (false, null);
            }

            // Read token to get tenant ID
            var handler = new JwtSecurityTokenHandler();
            var jsonToken = handler.ReadToken(token);
            var tokenS = jsonToken as JwtSecurityToken;
            
            int tenantId = int.Parse(tokenS?.Claims.FirstOrDefault(c => c.Type == "tenantid")?.Value ?? "0");
            
            // Get configurations for the tenant
            var configurations = await new WebPortalCredentialsHandler().GetConfigurationsModel(tenantId);
            
            // Validate the token
            ClaimsPrincipal? claimsPrincipal = IsValidToken(configurations.JwtSigningKey, token);
            
            if (claimsPrincipal == null)
            {
                return (false, null);
            }

            // Check for tenant_id and login_id override in headers
            var tenantIdHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "tenant_id");
            var loginIdHeader = metadata.FirstOrDefault(m => m.Key.ToLower() == "login_id");

            ClaimsPrincipal finalPrincipal;
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

                finalPrincipal = new ClaimsPrincipal(updatedIdentity);
            }
            else
            {
                var claimsIdentity = (ClaimsIdentity)claimsPrincipal.Identity!;
                finalPrincipal = new ClaimsPrincipal(claimsIdentity);
            }

            // Extract LoggedInUser information
            var loggedInUser = ExtractLoggedInUser(finalPrincipal.Identity);
            
            return (loggedInUser != null, loggedInUser);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Authentication error: " + ex.Message);
            return (false, null);
        }
    }

    /// <summary>
    /// Extracts LoggedInUser information from claims identity
    /// </summary>
    public LoggedInUser? ExtractLoggedInUser(System.Security.Principal.IIdentity? identity)
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
}

