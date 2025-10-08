using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

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
}

