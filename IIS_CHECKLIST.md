# IIS Checklist for gRPC 403 Error (HTTP/2 Confirmed Enabled)

## ✅ Confirmed: HTTP/2 is Enabled
Since HTTP/2 is enabled in IIS Advanced Settings, the issue is elsewhere.

## Critical Checks in IIS Manager

### 1. Request Filtering ⚠️ MOST COMMON CAUSE

**Location:** IIS Manager → `StaffSchedulingService_DEV` → **Request Filtering**

**Check:**
- **File Name Extensions** → Ensure no blocking rules
- **Hidden Segments** → Check if gRPC paths are hidden
- **Rules** → Look for rules blocking paths like `/httpservice.HttpService/Post`

**Action:** If you see any rules blocking gRPC paths, remove or modify them.

---

### 2. URL Rewrite Rules ⚠️ SECOND MOST COMMON

**Location:** IIS Manager → `StaffSchedulingService_DEV` → **URL Rewrite**

**Check:**
- Any rules that redirect ALL requests
- Any rules blocking specific paths
- Any rules that modify/strip headers (especially `authorization` header)

**Action:** Temporarily disable URL Rewrite rules and test gRPC again.

---

### 3. Handler Mappings

**Location:** IIS Manager → `StaffSchedulingService_DEV` → **Handler Mappings**

**Check:**
- ASP.NET Core handler exists: `aspNetCore` with path `*`, verb `*`
- No handlers blocking gRPC paths

**Action:** Ensure ASP.NET Core Module handler is present and enabled.

---

### 4. Authentication

**Location:** IIS Manager → `StaffSchedulingService_DEV` → **Authentication**

**Check:**
- **Anonymous Authentication** → Should be **Enabled**
- Other authentication methods can be enabled, but shouldn't block gRPC

**Action:** Ensure Anonymous Authentication is enabled.

---

### 5. Authorization Rules

**Location:** IIS Manager → `StaffSchedulingService_DEV` → **Authorization Rules**

**Check:**
- No rules blocking all users
- No rules blocking gRPC paths

**Action:** If there are deny rules, ensure they don't affect gRPC paths.

---

## Most Important: Verify Program.cs is Deployed

Your local `Program.cs` has the correct configuration:

```csharp
app.UseRouting();

// Map gRPC BEFORE UseAuthorization ✅
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>()
   .AllowAnonymous();  // ✅ This is critical

app.UseAuthorization();
app.MapControllers();
```

**Action Required:**
1. **Copy this `Program.cs` to the remote server**
2. **Rebuild the application on the server**
3. **Restart the IIS site** (or application pool)

---

## Quick Test: Check Server Logs

After deploying `Program.cs`, make a gRPC request and check server logs for:

1. **`DEBUG: Incoming request - Path: ...`** 
   - ✅ If you see this → Request reached application
   - ❌ If you don't see this → Request blocked by IIS

2. **`DEBUG SERVER: AuthenticateRequest received ...`**
   - ✅ If you see this → Request reached authentication
   - ❌ If you don't see this → Request blocked before authentication

3. **`=== HttpGrpcService.Post called ===`**
   - ✅ If you see this → Request reached gRPC handler
   - ❌ If you don't see this → Request blocked before handler

---

## Deployment Steps

1. **Copy updated files to server:**
   - `Program.cs` (with correct middleware order)
   - `InfrastructureCheckController.cs` (for testing)
   - `ValidateToken.cs` (with debug logging)
   - `HttpGrpcService.cs` (with debug logging)

2. **Build on server:**
   ```powershell
   cd C:\path\to\TimeManagementAPI\TimeManagement
   dotnet build
   ```

3. **Restart IIS site:**
   - IIS Manager → `StaffSchedulingService_DEV` → **Restart** (in Actions pane)

4. **Test:**
   - Call: `GET /api/InfrastructureCheck/check` (verify protocol)
   - Call: `GET /api/GrpcTest/test-all` (test gRPC)

---

## Summary

Since HTTP/2 is enabled:
- ✅ HTTP/2 configuration is correct
- ⚠️ **Most likely issue:** `Program.cs` middleware order not deployed to server
- ⚠️ **Second likely issue:** IIS Request Filtering or URL Rewrite blocking gRPC
- ⚠️ **Third likely issue:** Handler Mappings or Authentication settings

**Next Step:** Deploy the updated `Program.cs` to the remote server and restart the site.

