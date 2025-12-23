# Check IIS Settings That Might Block gRPC (403 Error)

Since HTTP/2 is confirmed enabled, the 403 error is likely due to IIS or application configuration blocking gRPC requests.

## Critical Checks in IIS Manager

### 1. Check Request Filtering (Common Cause of 403)

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - In the center pane, find **"Request Filtering"** (under IIS section)
   - Double-click it

2. **Check these settings:**
   - **File Name Extensions** tab → Ensure `.proto` or gRPC-related extensions aren't blocked
   - **Hidden Segments** tab → Check if any gRPC paths are hidden
   - **Rules** tab → Look for any rules blocking gRPC paths

3. **Common Issue:**
   - If you see rules blocking paths like `/httpservice.HttpService/Post`, remove or modify them
   - gRPC uses paths like: `/ServiceName.MethodName` (e.g., `/httpservice.HttpService/Post`)

### 2. Check Handler Mappings

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **"Handler Mappings"** (under IIS section)

2. **Look for:**
   - ASP.NET handlers that might be intercepting gRPC requests
   - Any handlers blocking the gRPC path pattern

3. **gRPC should use:**
   - The ASP.NET Core Module handler
   - Not be blocked by other handlers

### 3. Check URL Rewrite Rules

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **"URL Rewrite"** (under IIS section)

2. **Check for rules that might:**
   - Redirect gRPC requests
   - Block gRPC paths
   - Modify gRPC headers

3. **Common Problem:**
   - Rules that redirect all requests
   - Rules that block certain paths
   - Rules that strip headers (like `authorization`)

### 4. Check Authentication Settings

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **"Authentication"** (under IIS section)

2. **Check:**
   - **Anonymous Authentication** → Should be **Enabled**
   - **Windows Authentication** → Can be enabled, but shouldn't block gRPC
   - **ASP.NET Impersonation** → Check if it's interfering

3. **Important:**
   - gRPC handles authentication internally via JWT tokens
   - IIS authentication shouldn't block it
   - If Anonymous Authentication is disabled, enable it

### 5. Check Authorization Rules

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **"Authorization Rules"** (under IIS section)

2. **Check:**
   - If there are rules blocking all users
   - If there are rules blocking specific paths
   - Ensure gRPC paths aren't explicitly denied

### 6. Check SSL Settings

1. **In IIS Manager**, with `StaffSchedulingService_DEV` selected:
   - Click **"SSL Settings"** (under IIS section)

2. **Verify:**
   - **Require SSL** → Should be checked (since you're using HTTPS)
   - **Client Certificates** → Should be set to **Ignore** (unless you need client certs)
   - **SSL 128-bit** → Can be checked

### 7. Check Web.config (Most Important)

1. **Find the Web.config** for `StaffSchedulingService_DEV`
   - Usually in: `C:\inetpub\wwwroot\StaffSchedulingService_DEV\` or your app's physical path

2. **Check for:**
   ```xml
   <system.webServer>
     <!-- Check for rules blocking gRPC -->
     <rewrite>
       <rules>
         <!-- Any rules here? -->
       </rules>
     </rewrite>
     
     <!-- Check request filtering -->
     <security>
       <requestFiltering>
         <!-- Any blocking rules? -->
       </requestFiltering>
     </security>
     
     <!-- Check handlers -->
     <handlers>
       <!-- Ensure ASP.NET Core handler is present -->
       <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
     </handlers>
   </system.webServer>
   ```

3. **Common Issues:**
   - Missing ASP.NET Core handler
   - Rewrite rules blocking gRPC paths
   - Request filtering blocking gRPC

## Most Likely Cause: Application-Level Middleware

Since HTTP/2 is working, the 403 is most likely from your **ASP.NET Core application** (`Program.cs`), not IIS.

### Verify Program.cs Changes Are Deployed

The fix we made in `Program.cs` must be deployed to the server:

```csharp
// CORRECT ORDER:
app.UseRouting();

// Map gRPC BEFORE UseAuthorization
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>()
   .AllowAnonymous();

app.UseAuthorization();  // This was blocking gRPC

app.MapControllers();
```

**Check if this is deployed:**
1. Look at the server's `Program.cs` file
2. Verify the middleware order matches above
3. Ensure `.AllowAnonymous()` is present

## Quick Test: Check Server Logs

1. **Make a gRPC request** (via your test endpoint or Postman)
2. **Check the server logs** for:
   - `DEBUG: Incoming request - Path: ...` (from Program.cs middleware)
   - `DEBUG SERVER: AuthenticateRequest received ...` (from ValidateToken.cs)
   - `=== HttpGrpcService.Post called ===` (from HttpGrpcService.cs)

**If you see:**
- ✅ First log → Request reached application
- ✅ Second log → Request reached authentication
- ✅ Third log → Request reached gRPC handler
- ❌ No logs → Request blocked before reaching application (IIS issue)

## Summary Checklist

- [x] HTTP/2 is enabled (confirmed)
- [ ] Program.cs middleware order is correct (verify deployment)
- [ ] `.AllowAnonymous()` is present on gRPC mapping
- [ ] Request Filtering isn't blocking gRPC paths
- [ ] URL Rewrite rules aren't interfering
- [ ] Handler Mappings include ASP.NET Core handler
- [ ] Anonymous Authentication is enabled
- [ ] Authorization Rules aren't blocking gRPC paths
- [ ] Server logs show requests reaching the application

## Next Steps

1. **Verify Program.cs is deployed** with correct middleware order
2. **Check server logs** when making a gRPC request
3. **Test the InfrastructureCheckController** endpoint to see what protocol/headers are received
4. **Check IIS Request Filtering and URL Rewrite** for blocking rules

