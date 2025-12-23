# How to Check HTTP/2 in IIS Manager (Step-by-Step)

## Method 1: Check Site Bindings (Easiest)

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Look at the **Actions** pane on the right
   - Click **Edit Site** → **Bindings...**

2. **In the Site Bindings window:**
   - Look for your HTTPS binding (port 443)
   - Check if it shows **Protocol: https** with **Host name: staff-scheduling-dev.vastpacific.com**
   - **HTTP/2 is automatically enabled** on Windows Server 2016+ and Windows 10+ if:
     - The binding uses HTTPS (port 443)
     - TLS 1.2 or higher is enabled
     - The client supports HTTP/2

3. **To verify HTTP/2 is working:**
   - The binding itself won't explicitly say "HTTP/2"
   - HTTP/2 is negotiated automatically between client and server
   - You need to check if it's actually being used (see Method 2)

## Method 2: Check Configuration Editor (Detailed)

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - In the center pane, find **"Configuration Editor"** (under Management section)
   - Double-click it

2. **In Configuration Editor:**
   - At the top, you'll see a dropdown: **Section:**
   - Click the dropdown and navigate to:
     ```
     system.webServer → httpProtocol
     ```
   - Or manually type: `system.webServer/httpProtocol`

3. **Check the settings:**
   - Look for `customHeaders` or protocol-related settings
   - HTTP/2 support is usually handled at the server level, not site level
   - If you see any protocol restrictions, note them

4. **Check server-level HTTP/2:**
   - In the **Connections** pane (left), click on the **server name** (Web-Dev)
   - Double-click **Configuration Editor**
   - Navigate to: `system.webServer/httpProtocol`
   - Check for HTTP/2 settings

## Method 3: Check via Registry (PowerShell)

Run this PowerShell command **on the server**:

```powershell
# Check if HTTP/2 is enabled at the system level
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" -Name "EnableHttp2Tls" -ErrorAction SilentlyContinue
```

**Expected Result:**
- If `EnableHttp2Tls` exists and equals `1` → HTTP/2 is enabled
- If it doesn't exist or equals `0` → HTTP/2 might not be enabled

**To enable HTTP/2 (if not enabled):**
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" -Name "EnableHttp2Tls" -Value 1
# Restart IIS after making this change
iisreset
```

## Method 4: Check via Application Code (Most Reliable)

Since you have the `InfrastructureCheckController`, deploy it and call:

```
GET https://staff-scheduling-dev.vastpacific.com/api/InfrastructureCheck/check
```

This will show you:
- `"protocol": "HTTP/2"` or `"HTTP/1.1"`
- `"http2Supported": true` or `false`

## Method 5: Check Browser Developer Tools

1. **Open Chrome/Edge**
2. **Navigate to:** `https://staff-scheduling-dev.vastpacific.com`
3. **Press F12** to open Developer Tools
4. **Go to Network tab**
5. **Make a request** (refresh the page or call an API endpoint)
6. **Look at the Protocol column:**
   - If you see `h2` → HTTP/2 is working ✅
   - If you see `http/1.1` → HTTP/2 is NOT working ❌

## Method 6: Check IIS Logs

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **Logging** (in the IIS section)
   - Note the log file path (usually: `C:\inetpub\logs\LogFiles\W3SVC...`)

2. **Open the log file** (latest one)
3. **Look for the protocol version** in log entries:
   - HTTP/2 requests might show differently than HTTP/1.1
   - Check the `cs-version` field if available

## Quick Visual Check in IIS Manager

Based on your screenshot, here's what to do:

1. **Right-click** `StaffSchedulingService_DEV` in the Connections pane
2. **Select** **Edit Bindings...**
3. **Look at the HTTPS binding** (port 443)
4. **Check:**
   - ✅ SSL certificate is assigned
   - ✅ Port is 443
   - ✅ Host name is `staff-scheduling-dev.vastpacific.com`

If all these are correct, HTTP/2 **should** be working (assuming Windows Server 2016+).

## Troubleshooting: If HTTP/2 is Not Working

### Check Windows Version:
```powershell
# Run on server
[System.Environment]::OSVersion
```
- **Windows Server 2016+** or **Windows 10+** supports HTTP/2
- Older versions don't support HTTP/2

### Check TLS Version:
1. In IIS Manager → **Server level** (Web-Dev)
2. **Configuration Editor** → `system.webServer/security/access`
3. Ensure TLS 1.2 or higher is enabled

### Verify HTTP/2 is Actually Being Used:
The best way is to use the `InfrastructureCheckController` endpoint or browser DevTools, as HTTP/2 negotiation happens automatically and IIS Manager won't explicitly show it.

## Summary

**Easiest Check:**
1. Deploy `InfrastructureCheckController.cs`
2. Call: `GET /api/InfrastructureCheck/check`
3. Check the `protocol` and `http2Supported` fields in the response

**IIS Manager Check:**
1. Edit Bindings → Verify HTTPS (443) binding exists
2. Configuration Editor → Check `system.webServer/httpProtocol`
3. Server level → Verify HTTP/2 registry setting

**Browser Check:**
1. F12 → Network tab → Check Protocol column for `h2`

