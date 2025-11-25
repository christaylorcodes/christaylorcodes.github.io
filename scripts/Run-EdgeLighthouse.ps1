# Run-EdgeLighthouse.ps1
# Alternative method using Edge DevTools Protocol
# Since Lighthouse CLI doesn't detect Edge properly, use this workaround

param(
    [string]$URL = 'http://localhost:4000',
    [ValidateSet('desktop', 'mobile')]
    [string]$Device = 'desktop',
    [string]$OutputDir = 'benchmarks'
)

Write-Host "`n==> Edge Lighthouse Workaround" -ForegroundColor Cyan
Write-Host "This script launches Edge with remote debugging and runs Lighthouse against it.`n" -ForegroundColor Gray

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$outputPath = Join-Path $OutputDir "lighthouse_${Device}_$timestamp"

# Edge paths
$edgePaths = @(
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)

$edgePath = $null
foreach ($path in $edgePaths) {
    if (Test-Path $path) {
        $edgePath = $path
        break
    }
}

if (-not $edgePath) {
    Write-Host "[ERROR] Edge not found" -ForegroundColor Red
    exit 1
}

Write-Host "[1] Found Edge at: $edgePath" -ForegroundColor Green

# Kill any existing Edge instances to ensure clean start
Write-Host "[2] Stopping any existing Edge processes..." -ForegroundColor Yellow
Get-Process -Name msedge -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Launch Edge with remote debugging
$debugPort = 9222
$userDataDir = Join-Path $env:TEMP "edge-lighthouse-$(Get-Date -Format 'yyyyMMddHHmmss')"

Write-Host "[3] Launching Edge with remote debugging on port $debugPort..." -ForegroundColor Yellow

$edgeArgs = @(
    "--remote-debugging-port=$debugPort",
    "--user-data-dir=`"$userDataDir`"",
    "--headless",
    "--disable-gpu"
)

try {
    $edgeProcess = Start-Process -FilePath $edgePath `
        -ArgumentList $edgeArgs `
        -PassThru `
        -WindowStyle Hidden

    Write-Host "[OK] Edge process started (PID: $($edgeProcess.Id))" -ForegroundColor Green

    # Wait for debugging port to be ready
    Write-Host "[4] Waiting for debugging port to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3

    # Test if port is listening
    try {
        $testConnection = Test-NetConnection -ComputerName localhost -Port $debugPort -InformationLevel Quiet
        if ($testConnection) {
            Write-Host "[OK] Debugging port ready" -ForegroundColor Green
        }
        else {
            throw "Port not listening"
        }
    }
    catch {
        Write-Host "[ERROR] Debugging port not ready: $_" -ForegroundColor Red
        exit 1
    }

    # Run Lighthouse against the debugging port
    Write-Host "[5] Running Lighthouse..." -ForegroundColor Yellow
    Write-Host "    This may take 30-60 seconds...`n" -ForegroundColor Gray

    $lighthouseArgs = @(
        $URL,
        "--port=$debugPort",
        "--output=json",
        "--output=html",
        "--output-path=`"$outputPath`"",
        "--preset=$Device"
    )

    $lighthouseCmd = "lighthouse $($lighthouseArgs -join ' ')"
    Write-Host "    Command: $lighthouseCmd" -ForegroundColor DarkGray

    $output = Invoke-Expression $lighthouseCmd 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] Lighthouse completed successfully!" -ForegroundColor Green

        # Parse and display results
        $jsonPath = "$outputPath.json"
        if (Test-Path $jsonPath) {
            $results = Get-Content $jsonPath | ConvertFrom-Json
            $scores = $results.categories

            Write-Host "`nScores:" -ForegroundColor Cyan
            Write-Host ("=" * 40) -ForegroundColor Gray

            function Show-Score($name, $score) {
                $percentage = [math]::Round($score * 100)
                $color = if ($percentage -ge 90) { 'Green' }
                         elseif ($percentage -ge 50) { 'Yellow' }
                         else { 'Red' }

                Write-Host "  $name`.PadRight(20)" -NoNewline
                Write-Host "$percentage/100" -ForegroundColor $color
            }

            Show-Score "Performance" $scores.performance.score
            Show-Score "Accessibility" $scores.accessibility.score
            Show-Score "Best Practices" $scores.'best-practices'.score
            Show-Score "SEO" $scores.seo.score

            Write-Host "`nReports saved:" -ForegroundColor Cyan
            Write-Host "  JSON: $jsonPath" -ForegroundColor Gray
            Write-Host "  HTML: $outputPath.html" -ForegroundColor Gray

            # Open HTML report
            Write-Host "`nOpening HTML report..." -ForegroundColor Yellow
            Start-Process "$outputPath.html"
        }
    }
    else {
        Write-Host "`n[ERROR] Lighthouse failed" -ForegroundColor Red
        Write-Host "Output: $output" -ForegroundColor Gray
        exit 1
    }
}
finally {
    # Cleanup: Stop Edge and remove temp user data
    Write-Host "`n[6] Cleaning up..." -ForegroundColor Yellow

    if ($edgeProcess -and -not $edgeProcess.HasExited) {
        Stop-Process -Id $edgeProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Stopped Edge process" -ForegroundColor Green
    }

    if (Test-Path $userDataDir) {
        Start-Sleep -Seconds 2
        Remove-Item $userDataDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Cleaned up temp directory" -ForegroundColor Green
    }
}

Write-Host "`nDone!`n" -ForegroundColor Green
