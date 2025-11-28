using System.Security.Cryptography;
using System.Text;

namespace WebPortal_TM.API.ExternalAuth
{
    public class PasswordDigestGenerator
    {
        /// <summary>
        /// Generates a password digest using SHA-1 hash of nonce + timestamp + password
        /// </summary>
        /// <param name="nonce">The nonce value</param>
        /// <param name="ts">The timestamp</param>
        /// <param name="password">The password</param>
        /// <returns>Base64 encoded SHA-1 hash</returns>
        public static string GeneratePasswordDigest(string nonce, DateTimeOffset ts, string password)
        {
            // Format timestamp (tz) as "YYYY-MM-DDTHH:mm:ss.fZ"
            string formattedTimestamp = ts.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fZ");

            // Concatenate nonce, formatted timestamp, and password
            string concatenatedString = nonce + formattedTimestamp + password;

            // Calculate SHA-1 hash
            byte[] sha1Bytes;
            using (var sha1 = SHA1.Create())
            {
                sha1Bytes = sha1.ComputeHash(Encoding.UTF8.GetBytes(concatenatedString));
            }

            // Base64 encode the hash
            string passwordDigest = Convert.ToBase64String(sha1Bytes);

            return passwordDigest;
        }
    }

}
