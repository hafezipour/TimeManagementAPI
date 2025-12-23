# How to Check Infrastructure and HTTP/2 for gRPC

## 1. Check Infrastructure (IIS, Reverse Proxy, Load Balancer)

### A. If Using IIS (Internet Information Services)

#### Check IIS Configuration:

1. **Open IIS Manager** on the server
2. **Select your application/site**
3. **Check HTTP/2 Settings:**
   - Go to **Configuration Editor**
   - Navigate to: `system.webServer/httpProtocol`
   - Look for `h2` in the `customHeaders` or check if HTTP/2 is enabled
   - Or check: `system.webServer/httpProtocol` → `customHeaders` → Look for `:method`, `:path` headers

4. **Check URL Rewrite Rules:**
   - Go to **URL Rewrite** module
   - Look for any rules that might be blocking or modifying gRPC requests
   - gRPC uses path pattern: `/ServiceName/MethodName` (e.g., `/httpservice.HttpService/Post`)

5. **Check Application Request Routing (ARR) if used:**
   - Go to **Server Farms** → Your farm
   - Check **Proxy** settings
   - Ensure **HTTP/2** is enabled
   - Check **Timeout** settings (gRPC might need longer timeouts)

6. **Check Web.config:**
   ```xml
   <system.webServer>
     <httpProtocol>
       <!-- Ensure HTTP/2 is enabled -->
     </httpProtocol>
     <rewrite>
       <!-- Check for rules blocking gRPC -->
     </rewrite>
   </system.webServer>
   ```

#### PowerShell Commands to Check IIS:

```powershell
# Check if HTTP/2 is enabled
Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/httpProtocol" -Name "customHeaders"

# Check URL Rewrite rules
Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/rewrite/rules" -Name "collection"
```

### B. If Using Azure App Service

1. **Check Application Settings:**
   - Go to Azure Portal → Your App Service
   - **Configuration** → **Application settings**
   - Look for any settings that might affect gRPC

2. **Check CORS Settings:**
   - **API** → **CORS**
   - Ensure gRPC endpoints are allowed

3. **Check Networking:**
   - **Networking** → Check if any restrictions are blocking gRPC

4. **Check Logs:**
   - **Log stream** → Look for incoming requests
   - **App Service Logs** → Check for 403 errors

### C. If Using Reverse Proxy (Nginx, Apache, etc.)

#### For Nginx:

Check `/etc/nginx/nginx.conf` or site configuration:

```nginx
# gRPC requires HTTP/2
server {
    listen 443 ssl http2;  # ← Must have http2
    
    # gRPC proxy settings
    location / {
        grpc_pass grpc://backend;
        grpc_set_header Host $host;
        grpc_set_header Authorization $http_authorization;
        grpc_set_header tenant_id $http_tenant_id;
        grpc_set_header login_id $http_login_id;
    }
}
```

#### For Apache:

Check if `mod_http2` is enabled and configured correctly.

### D. Check Load Balancer

1. **Check Load Balancer Rules:**
   - Ensure gRPC traffic (port 443) is forwarded
   - Check if HTTP/2 is enabled
   - Verify health checks aren't interfering

2. **Check SSL/TLS Termination:**
   - If SSL terminates at load balancer, ensure HTTP/2 is passed through
   - Check certificate configuration

## 2. Verify HTTP/2 Support

### Method 1: Using Browser Developer Tools

1. **Open browser** (Chrome/Edge recommended)
2. **Open Developer Tools** (F12)
3. **Go to Network tab**
4. **Make a request** to your gRPC endpoint
5. **Check Protocol column:**
   - Should show `h2` (HTTP/2) or `http/2`
   - If it shows `http/1.1`, HTTP/2 is not enabled

### Method 2: Using PowerShell/Command Line

```powershell
# Check HTTP/2 support
$response = Invoke-WebRequest -Uri "https://staff-scheduling-dev.vastpacific.com" -Method Head
$response.Headers

# Or use curl
curl -I --http2 https://staff-scheduling-dev.vastpacific.com
```

### Method 3: Using Online Tools

1. **SSL Labs SSL Test:**
   - Go to: https://www.ssllabs.com/ssltest/
   - Enter your domain: `staff-scheduling-dev.vastpacific.com`
   - Check if HTTP/2 is supported

2. **HTTP/2 Test:**
   - Go to: https://tools.keycdn.com/http2-test
   - Enter your domain
   - Check if HTTP/2 is enabled

### Method 4: Check Server Response Headers

```powershell
# PowerShell
$headers = Invoke-WebRequest -Uri "https://staff-scheduling-dev.vastpacific.com" -Method Head
$headers.Headers

# Look for:
# - "Upgrade: h2" or similar
# - Protocol version in response
```

### Method 5: Check Application Logs

Look for HTTP protocol version in application logs:
- Should show: `HTTP/2` or `HTTP/2.0`
- Not: `HTTP/1.1`

## 3. Quick Diagnostic Test

Create a simple test endpoint to check infrastructure:

```csharp
[HttpGet("check-infrastructure")]
public IActionResult CheckInfrastructure()
{
    return Ok(new
    {
        protocol = Request.Protocol,
        scheme = Request.Scheme,
        host = Request.Host.Value,
        path = Request.Path.Value,
        headers = Request.Headers.ToDictionary(h => h.Key, h => h.Value.ToString())
    });
}
```

Call: `GET /api/GrpcTest/check-infrastructure`

This will show:
- Protocol version (should be HTTP/2)
- All headers being received
- Request path and scheme

## 4. Common Issues and Fixes

### Issue: HTTP/2 Not Enabled

**Fix for IIS:**
1. Ensure Windows Server 2016+ or Windows 10+
2. Enable HTTP/2 in IIS:
   ```powershell
   # Enable HTTP/2
   Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" -Name "EnableHttp2Tls" -Value 1
   ```
3. Restart IIS: `iisreset`

**Fix for Azure App Service:**
- HTTP/2 is enabled by default on Azure App Service
- Check if you're using Basic tier (HTTP/2 requires Standard or higher)

### Issue: Reverse Proxy Blocking

**Fix:**
- Ensure reverse proxy forwards HTTP/2
- Check proxy configuration allows gRPC paths
- Verify headers are being forwarded correctly

### Issue: Load Balancer Blocking

**Fix:**
- Enable HTTP/2 on load balancer
- Ensure gRPC ports (typically 443) are open
- Check load balancer rules allow gRPC traffic

## 5. Test gRPC Directly

Use grpcurl to test if gRPC works at all:

```bash
# Test if gRPC endpoint is reachable
grpcurl -insecure \
  -H "authorization: Bearer YOUR_TOKEN" \
  -H "tenant_id: 4201" \
  -H "login_id: 2" \
  -d '{"serviceName":"timeoffrequests","methodName":"Get","jsonData":"{}"}' \
  -proto httpservice.proto \
  staff-scheduling-dev.vastpacific.com:443 \
  httpservice.HttpService/Post
```

If this works but your code doesn't, the issue is in the client code.
If this also fails, the issue is infrastructure/server configuration.

