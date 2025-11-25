# Test-Lighthouse.ps1
# Simple test script to validate Lighthouse wrapper functionality

param(
    [string]$URL = 'http://localhost:4000',

    [ValidateSet('desktop', 'mobile')]
    [string]$Device = 'desktop',

    [switch]$Verbose
)

if ($Verbose) {
    $VerbosePreference = 'Continue'
}

# Import the module
$modulePath = Join-Path $PSScriptRoot 'LighthouseWrapper.psd1'
Import-Module $modulePath -Force

Write-Host "`n==> Testing Lighthouse Wrapper Module" -ForegroundColor Cyan
Write-Host "URL: $URL" -ForegroundColor Gray
Write-Host "Device: $Device`n" -ForegroundColor Gray

try {
    # Test 1: Basic audit (no file output)
    Write-Host "Test 1: Running basic audit (in-memory only)..." -ForegroundColor Yellow
    $result = Invoke-LighthouseAudit -URL $URL -Device $Device

    if ($result) {
        Write-Host "[OK] Audit completed successfully`n" -ForegroundColor Green

        # Display results
        Show-LighthouseResults -Result $result -ShowMetrics

        # Test 2: Get scores as object
        Write-Host "`nTest 2: Extracting scores as object..." -ForegroundColor Yellow
        $scores = Get-LighthouseScores -Result $result
        $scores | Format-Table -AutoSize
        Write-Host "[OK] Scores extracted`n" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] No result returned" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "`n[ERROR] Test failed: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    exit 1
}

Write-Host "`n==> All tests passed!" -ForegroundColor Green
