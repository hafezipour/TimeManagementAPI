using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System.Text;
using WebPortalSecurityManager.Models;

namespace WebPortal_TM.API.ExternalAuth
{
    public class CallApiService : IDisposable
    {
        private readonly HttpClient _httpClient;
        private readonly ApiConfiguration _configuration;
        private bool _disposed = false;
        public CallApiService()
        {
            _httpClient = new HttpClient();
        }
        public CallApiService(int tenantId)
        {
            var config = WPConfigurations.CacheCustomersConfigs.Where(c => c.TenantId == tenantId).Select(c => new
            {
                c.ExternalAuthenticationAPIKey,
                c.ExternalAuthenticationSecret,
                c.Domain
            }).FirstOrDefault();

            _configuration = new ApiConfiguration
            {
                ApiKey = config.ExternalAuthenticationAPIKey,
                Password = config.ExternalAuthenticationSecret,
                BaseUrl = config.Domain + "/api"
            };
        }

        private void SetupDynamicHeaders()
        {
            // Clear existing headers first
            _httpClient.DefaultRequestHeaders.Clear();

            // Generate dynamic values
            string nonce = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 16);
            DateTimeOffset timestamp = DateTimeOffset.UtcNow;
            string passwordDigest = PasswordDigestGenerator.GeneratePasswordDigest(nonce, timestamp, _configuration.Password);

            // Add all headers
            _httpClient.DefaultRequestHeaders.Add("X-API-Key", _configuration.ApiKey);
            _httpClient.DefaultRequestHeaders.Add("X-Nonce", nonce);
            _httpClient.DefaultRequestHeaders.Add("X-Timestamp", timestamp.ToString("yyyy-MM-ddTHH:mm:ss.fZ"));
            _httpClient.DefaultRequestHeaders.Add("X-Password-Digest", passwordDigest);
        }

        public async Task<T> SendRequest<T>(object request)
        {
            try
            {
                // Setup fresh headers for each request
                SetupDynamicHeaders();

                string json = JsonConvert.SerializeObject(request);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync($"{_configuration.BaseUrl}/Auth/GetHireDateByUserIds_Internal", content);

                string responseContent = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    // Deserialize JSON response to type T
                    T result = JsonConvert.DeserializeObject<T>(responseContent);
                    return result;
                }
                else
                {
                    throw new HttpRequestException($"Error {(int)response.StatusCode}: {responseContent}");
                }
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException($"Failed to deserialize response: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Exception occurred: {ex.Message}", ex);
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    _httpClient?.Dispose();
                }
                _disposed = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        ~CallApiService()
        {
            Dispose(false);
        }
    }
}
