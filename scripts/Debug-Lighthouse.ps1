# Debug-Lighthouse.ps1
# Diagnostic script to troubleshoot Lighthouse CLI issues

param(
    [string]$URL = 'http://localhost:4000'
)

$ErrorActionPreference = 'Continue'

Write-Host "`n==> Lighthouse CLI Diagnostics" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

#region Test 1: Check Lighthouse installation
Write-Host "`n[1] Checking Lighthouse CLI installation..." -ForegroundColor Yellow

try {
    $lighthouseVersion = lighthouse --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] Lighthouse installed: $lighthouseVersion" -ForegroundColor Green
    }
    else {
        Write-Host "    [ERROR] Lighthouse not found or not in PATH" -ForegroundColor Red
        Write-Host "    Install with: npm install -g lighthouse" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "    [ERROR] Failed to check Lighthouse: $_" -ForegroundColor Red
    exit 1
}
#endregion

#region Test 2: Check Chrome/Edge
Write-Host "`n[2] Checking for Chrome/Edge..." -ForegroundColor Yellow

$chromePaths = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)

$foundBrowser = $null
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        $foundBrowser = $path
        Write-Host "    [OK] Found browser: $path" -ForegroundColor Green
        break
    }
}

if (-not $foundBrowser) {
    Write-Host "    [ERROR] No Chrome or Edge found" -ForegroundColor Red
    exit 1
}
#endregion

#region Test 3: Check URL accessibility
Write-Host "`n[3] Checking URL accessibility..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $URL -UseBasicParsing -TimeoutSec 5
    Write-Host "    [OK] URL accessible: $URL (Status: $($response.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "    [WARNING] URL not accessible: $URL" -ForegroundColor Yellow
    Write-Host "    Error: $_" -ForegroundColor Gray
    Write-Host "    Continuing anyway (Lighthouse may handle it differently)..." -ForegroundColor Gray
}
#endregion

#region Test 4: Simple Lighthouse command
Write-Host "`n[4] Testing basic Lighthouse command..." -ForegroundColor Yellow

$testOutput = Join-Path $env:TEMP "lighthouse-test-$(Get-Date -Format 'yyyyMMddHHmmss').json"

# Method 1: Simple command with minimal args
Write-Host "    Method 1: Minimal arguments" -ForegroundColor Cyan

$simpleCmd = "lighthouse $URL --output=json --output-path=`"$testOutput`" --quiet"
Write-Host "    Command: $simpleCmd" -ForegroundColor DarkGray

try {
    $output = Invoke-Expression $simpleCmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "    [OK] Lighthouse ran successfully" -ForegroundColor Green
        if (Test-Path $testOutput) {
            Write-Host "    [OK] Output file created: $testOutput" -ForegroundColor Green
            Remove-Item $testOutput -Force
        }
    }
    else {
        Write-Host "    [ERROR] Exit code: $exitCode" -ForegroundColor Red
        Write-Host "    Output: $output" -ForegroundColor Gray
    }
}
catch {
    Write-Host "    [ERROR] Exception: $_" -ForegroundColor Red
}
#endregion

#region Test 5: With chrome-path argument
Write-Host "`n[5] Testing with explicit chrome-path..." -ForegroundColor Yellow

$testOutput2 = Join-Path $env:TEMP "lighthouse-test2-$(Get-Date -Format 'yyyyMMddHHmmss').json"

$chromeCmd = "lighthouse $URL --output=json --output-path=`"$testOutput2`" --chrome-path=`"$foundBrowser`" --quiet"
Write-Host "    Command: $chromeCmd" -ForegroundColor DarkGray

try {
    $output = Invoke-Expression $chromeCmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "    [OK] Lighthouse with chrome-path successful" -ForegroundColor Green
        if (Test-Path $testOutput2) {
            Write-Host "    [OK] Output file created" -ForegroundColor Green
            Remove-Item $testOutput2 -Force
        }
    }
    else {
        Write-Host "    [ERROR] Exit code: $exitCode" -ForegroundColor Red
        Write-Host "    Output: $output" -ForegroundColor Gray
    }
}
catch {
    Write-Host "    [ERROR] Exception: $_" -ForegroundColor Red
}
#endregion

#region Test 6: Using Start-Process instead
Write-Host "`n[6] Testing with Start-Process method..." -ForegroundColor Yellow

$testOutput3 = Join-Path $env:TEMP "lighthouse-test3-$(Get-Date -Format 'yyyyMMddHHmmss').json"

$arguments = @(
    $URL,
    '--output=json',
    "--output-path=`"$testOutput3`"",
    '--quiet'
)

try {
    $process = Start-Process -FilePath 'lighthouse' `
        -ArgumentList $arguments `
        -NoNewWindow `
        -Wait `
        -PassThru `
        -RedirectStandardOutput (Join-Path $env:TEMP 'lh-stdout.txt') `
        -RedirectStandardError (Join-Path $env:TEMP 'lh-stderr.txt')

    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-Host "    [OK] Start-Process method successful" -ForegroundColor Green
        if (Test-Path $testOutput3) {
            Write-Host "    [OK] Output file created" -ForegroundColor Green
            Remove-Item $testOutput3 -Force
        }
    }
    else {
        Write-Host "    [ERROR] Exit code: $exitCode" -ForegroundColor Red

        $stdout = Get-Content (Join-Path $env:TEMP 'lh-stdout.txt') -Raw -ErrorAction SilentlyContinue
        $stderr = Get-Content (Join-Path $env:TEMP 'lh-stderr.txt') -Raw -ErrorAction SilentlyContinue

        if ($stdout) { Write-Host "    STDOUT: $stdout" -ForegroundColor Gray }
        if ($stderr) { Write-Host "    STDERR: $stderr" -ForegroundColor Gray }
    }
}
catch {
    Write-Host "    [ERROR] Exception: $_" -ForegroundColor Red
}
#endregion

#region Test 7: Direct npx lighthouse
Write-Host "`n[7] Testing with npx lighthouse..." -ForegroundColor Yellow

$testOutput4 = Join-Path $env:TEMP "lighthouse-test4-$(Get-Date -Format 'yyyyMMddHHmmss').json"

try {
    $npxCmd = "npx lighthouse $URL --output=json --output-path=`"$testOutput4`" --quiet"
    Write-Host "    Command: $npxCmd" -ForegroundColor DarkGray

    $output = Invoke-Expression $npxCmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "    [OK] npx method successful" -ForegroundColor Green
        if (Test-Path $testOutput4) {
            Write-Host "    [OK] Output file created" -ForegroundColor Green
            Remove-Item $testOutput4 -Force
        }
    }
    else {
        Write-Host "    [ERROR] Exit code: $exitCode" -ForegroundColor Red
        Write-Host "    Output: $output" -ForegroundColor Gray
    }
}
catch {
    Write-Host "    [ERROR] Exception: $_" -ForegroundColor Red
}
#endregion

Write-Host "`n" -NoNewline
Write-Host "==> Diagnostics Complete" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "`nRecommendations:" -ForegroundColor Yellow

Write-Host "  - If Method 1 or 5 succeeded, the issue is with argument handling"
Write-Host "  - If Method 6 succeeded, use Start-Process instead of Invoke-Expression"
Write-Host "  - If Method 7 succeeded, use 'npx lighthouse' in scripts"
Write-Host "  - If all failed, check Lighthouse installation and browser paths"
Write-Host ""
