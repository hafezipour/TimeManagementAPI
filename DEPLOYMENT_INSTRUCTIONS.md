# Deployment Instructions for gRPC 403 Fix

## Problem
gRPC requests are returning 403 Permission Denied because `UseAuthorization()` middleware is blocking requests before they reach the gRPC handler.

## Solution
The gRPC service handles authentication internally via `ValidateToken`, so it should bypass the ASP.NET Core authorization middleware.

## Changes Required

### File: `TimeManagement/Program.cs`

**BEFORE (Current - Causes 403):**
```csharp
app.UseHttpsRedirection();

app.UseAuthorization();

// Map gRPC service
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>();

app.MapControllers();
```

**AFTER (Fixed):**
```csharp
app.UseHttpsRedirection();

app.UseRouting();

// Map gRPC service BEFORE UseAuthorization
// gRPC services handle authentication/authorization internally via ValidateToken
// This prevents UseAuthorization middleware from blocking gRPC requests
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>()
   .AllowAnonymous();

// Apply authorization only to regular HTTP controllers, not gRPC
app.UseAuthorization();

app.MapControllers();
```

## Key Changes:
1. ✅ Added `app.UseRouting()` - Required for endpoint routing
2. ✅ Moved `app.MapGrpcService()` BEFORE `app.UseAuthorization()`
3. ✅ Added `.AllowAnonymous()` to gRPC endpoint
4. ✅ Kept `UseAuthorization()` for regular controllers

## Deployment Steps:

1. **Update Program.cs** on the remote server with the changes above
2. **Build the application:**
   ```bash
   dotnet build
   ```
3. **Deploy to remote server** (`staff-scheduling-dev.vastpacific.com`)
4. **Restart the application**
5. **Test the endpoint:**
   - Call: `GET /api/GrpcTest/test-all`
   - Should return 200 with data instead of 403

## Verification:

After deployment, check the server logs. You should see:
- `=== HttpGrpcService.Post called ===` - Confirms request reached gRPC handler
- `=== ValidateToken.AuthenticateRequest ===` - Shows headers received
- If you DON'T see these logs, the request is being blocked by middleware/infrastructure

## Important Notes:

- **Security**: gRPC authentication is still enforced! It's handled inside `HttpGrpcService.RouteRequest()` via `ValidateToken.AuthenticateRequest()`
- **Regular Controllers**: Still protected by `[Authorize]` attribute if needed
- **Why `.AllowAnonymous()`**: This tells ASP.NET Core middleware to skip authorization checks, but gRPC service still validates the token internally

## If Still Getting 403 After Deployment:

1. **Check server logs** - Look for the debug messages to see if request reaches handler
2. **Verify deployment** - Ensure Program.cs changes were deployed
3. **Check infrastructure** - IIS, reverse proxy, or load balancer might be blocking
4. **Verify HTTP/2** - gRPC requires HTTP/2 support

