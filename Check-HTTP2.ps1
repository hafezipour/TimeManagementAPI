# PowerShell script to check HTTP/2 support in IIS

Write-Host "=== Checking HTTP/2 Support ===" -ForegroundColor Cyan
Write-Host ""

# Check registry setting for HTTP/2
Write-Host "1. Checking Registry Setting:" -ForegroundColor Yellow
$http2Reg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" -Name "EnableHttp2Tls" -ErrorAction SilentlyContinue

if ($http2Reg) {
    if ($http2Reg.EnableHttp2Tls -eq 1) {
        Write-Host "   ✓ HTTP/2 is ENABLED in registry (EnableHttp2Tls = 1)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ HTTP/2 is DISABLED in registry (EnableHttp2Tls = 0)" -ForegroundColor Red
        Write-Host "   Run: Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters' -Name 'EnableHttp2Tls' -Value 1" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ HTTP/2 registry key not found (defaults to enabled on Windows Server 2016+)" -ForegroundColor Yellow
}

Write-Host ""

# Check Windows Version
Write-Host "2. Checking Windows Version:" -ForegroundColor Yellow
$osVersion = [System.Environment]::OSVersion
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "   OS Version: $($osVersion.VersionString)" -ForegroundColor White
Write-Host "   OS Name: $($osInfo.Caption)" -ForegroundColor White

if ($osVersion.Version.Major -ge 10 -or ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -ge 2)) {
    Write-Host "   ✓ Windows version supports HTTP/2" -ForegroundColor Green
} else {
    Write-Host "   ✗ Windows version may not support HTTP/2 (requires Windows Server 2016+ or Windows 10+)" -ForegroundColor Red
}

Write-Host ""

# Check IIS Site Bindings
Write-Host "3. Checking IIS Site Bindings:" -ForegroundColor Yellow
try {
    Import-Module WebAdministration -ErrorAction Stop
    
    $siteName = "StaffSchedulingService_DEV"
    $site = Get-WebSite -Name $siteName -ErrorAction SilentlyContinue
    
    if ($site) {
        Write-Host "   Site found: $siteName" -ForegroundColor White
        
        $bindings = Get-WebBinding -Name $siteName
        $httpsBinding = $bindings | Where-Object { $_.protocol -eq "https" }
        
        if ($httpsBinding) {
            Write-Host "   ✓ HTTPS binding found:" -ForegroundColor Green
            foreach ($binding in $httpsBinding) {
                Write-Host "      Protocol: $($binding.protocol)" -ForegroundColor White
                Write-Host "      Port: $($binding.bindingInformation.Split(':')[1])" -ForegroundColor White
                Write-Host "      Host: $($binding.bindingInformation.Split(':')[2])" -ForegroundColor White
            }
            Write-Host "   Note: HTTP/2 is automatically enabled for HTTPS bindings on Windows Server 2016+" -ForegroundColor Cyan
        } else {
            Write-Host "   ✗ No HTTPS binding found - HTTP/2 requires HTTPS" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠ Site '$siteName' not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠ Could not check IIS bindings: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# Test HTTP/2 via curl (if available)
Write-Host "4. Testing HTTP/2 Connection:" -ForegroundColor Yellow
$testUrl = "https://staff-scheduling-dev.vastpacific.com"

try {
    # Try using curl with --http2 flag
    $curlTest = curl.exe -I --http2 --max-time 5 $testUrl 2>&1
    
    if ($curlTest -match "HTTP/2") {
        Write-Host "   ✓ HTTP/2 connection successful!" -ForegroundColor Green
    } elseif ($curlTest -match "HTTP/1") {
        Write-Host "   ✗ Connection is using HTTP/1.1 (not HTTP/2)" -ForegroundColor Red
    } else {
        Write-Host "   ⚠ Could not determine protocol from curl output" -ForegroundColor Yellow
        Write-Host "   Output: $($curlTest -join '`n')" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠ curl test failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   Note: Install curl or use browser DevTools to test HTTP/2" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Recommendation ===" -ForegroundColor Cyan
Write-Host "Best way to verify HTTP/2:" -ForegroundColor White
Write-Host "1. Deploy InfrastructureCheckController.cs" -ForegroundColor White
Write-Host "2. Call: GET $testUrl/api/InfrastructureCheck/check" -ForegroundColor White
Write-Host "3. Check the 'protocol' field in the response" -ForegroundColor White
Write-Host ""
Write-Host "Or use Chrome DevTools (F12) → Network tab → Check Protocol column for 'h2'" -ForegroundColor White

