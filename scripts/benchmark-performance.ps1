# Performance Benchmark Script
# Runs Lighthouse CLI on local or live site and saves results

param(
    [ValidateSet('local', 'production')]
    [string]$Target = 'local',

    [ValidateSet('desktop', 'mobile')]
    [string]$Device = 'desktop',

    [string]$OutputDir = 'benchmarks',

    [switch]$HTMLReport,

    [switch]$OpenReport
)

$ErrorActionPreference = 'Stop'

# Configuration
$LocalURL = 'http://localhost:4000'
$ProductionURL = 'https://christaylor.codes'
$Timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

# Colors for output
function Write-Header($message) {
    Write-Host "`n==> $message" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[OK] $message" -ForegroundColor Green
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Success "Created $OutputDir directory"
}

# Determine URL
$URL = if ($Target -eq 'local') { $LocalURL } else { $ProductionURL }
Write-Header "Target: $URL ($Device)"

# Check if local server is running (for local tests)
if ($Target -eq 'local') {
    Write-Header 'Checking local server...'
    try {
        $response = Invoke-WebRequest -Uri $LocalURL -UseBasicParsing -TimeoutSec 5
        Write-Success 'Local server is running'
    }
    catch {
        Write-Error "Local server not running at $LocalURL"
        Write-Host "`nStart the server with: .\build.ps1" -ForegroundColor Yellow
        exit 1
    }
}

# Build output paths
$BaseFilename = "$OutputDir/lighthouse_${Target}_${Device}_$Timestamp"
$JSONPath = "$BaseFilename.json"
$HTMLPath = "$BaseFilename.html"

# Check for Chrome/Edge installation
$ChromePath = $null
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$ChromePaths = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    $EdgePath
)

foreach ($path in $ChromePaths) {
    if (Test-Path $path) {
        $ChromePath = $path
        break
    }
}

if (-not $ChromePath) {
    Write-Error "No Chrome or Edge installation found. Please install Google Chrome or Microsoft Edge."
    exit 1
}

# Build Lighthouse command
$LighthouseArgs = @(
    $URL
    '--output=json'
    "--output-path=$JSONPath"
    '--quiet'
    "--chrome-path=`"$ChromePath`""
    '--chrome-flags="--headless"'
)

# Add device preset
if ($Device -eq 'mobile') {
    $LighthouseArgs += '--preset=mobile'
}
else {
    $LighthouseArgs += '--preset=desktop'
}

# Add HTML report if requested
if ($HTMLReport) {
    $LighthouseArgs = @(
        $URL
        '--output=json'
        '--output=html'
        "--output-path=$BaseFilename"
        '--quiet'
        "--chrome-path=`"$ChromePath`""
        '--chrome-flags="--headless"'
    )
    if ($Device -eq 'mobile') {
        $LighthouseArgs += '--preset=mobile'
    }
    else {
        $LighthouseArgs += '--preset=desktop'
    }
}

# Run Lighthouse
Write-Header 'Running Lighthouse audit...'
Write-Host '  This may take 30-60 seconds...' -ForegroundColor Gray

try {
    # Build command string for proper execution
    $LighthouseCmd = "lighthouse $($LighthouseArgs -join ' ')"

    # Debug: Show the command being executed
    Write-Host "`nExecuting command:" -ForegroundColor Gray
    Write-Host $LighthouseCmd -ForegroundColor DarkGray
    Write-Host ""

    # Execute via Invoke-Expression to handle npm-installed commands
    $output = Invoke-Expression $LighthouseCmd 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success 'Lighthouse audit complete'
    }
    else {
        Write-Error "Lighthouse audit failed with exit code $LASTEXITCODE"
        if ($output) {
            Write-Host "`nOutput: $output" -ForegroundColor Gray
        }
        exit 1
    }
}
catch {
    Write-Error "Failed to run Lighthouse: $_"
    exit 1
}

# Parse and display results
if (Test-Path $JSONPath) {
    Write-Header 'Performance Scores'

    $results = Get-Content $JSONPath | ConvertFrom-Json
    $scores = $results.categories

    # Helper function to format score with color
    function Format-Score($score) {
        $percentage = [math]::Round($score * 100)
        if ($percentage -ge 90) {
            Write-Host "$percentage" -ForegroundColor Green -NoNewline
        }
        elseif ($percentage -ge 50) {
            Write-Host "$percentage" -ForegroundColor Yellow -NoNewline
        }
        else {
            Write-Host "$percentage" -ForegroundColor Red -NoNewline
        }
    }

    Write-Host '  Performance:    ' -NoNewline
    Format-Score $scores.performance.score
    Write-Host '/100'

    Write-Host '  Accessibility:  ' -NoNewline
    Format-Score $scores.accessibility.score
    Write-Host '/100'

    Write-Host '  Best Practices: ' -NoNewline
    Format-Score $scores.'best-practices'.score
    Write-Host '/100'

    Write-Host '  SEO:            ' -NoNewline
    Format-Score $scores.seo.score
    Write-Host '/100'

    # Display key metrics
    Write-Header 'Core Web Vitals'
    $audits = $results.audits

    Write-Host '  First Contentful Paint (FCP): ' -NoNewline
    Write-Host "$([math]::Round($audits.'first-contentful-paint'.numericValue))ms" -ForegroundColor Cyan

    Write-Host '  Largest Contentful Paint (LCP): ' -NoNewline
    Write-Host "$([math]::Round($audits.'largest-contentful-paint'.numericValue))ms" -ForegroundColor Cyan

    Write-Host '  Total Blocking Time (TBT): ' -NoNewline
    Write-Host "$([math]::Round($audits.'total-blocking-time'.numericValue))ms" -ForegroundColor Cyan

    Write-Host '  Cumulative Layout Shift (CLS): ' -NoNewline
    Write-Host "$([math]::Round($audits.'cumulative-layout-shift'.numericValue, 3))" -ForegroundColor Cyan

    Write-Host '  Speed Index: ' -NoNewline
    Write-Host "$([math]::Round($audits.'speed-index'.numericValue))ms" -ForegroundColor Cyan
}

# Display output file locations
Write-Header 'Results saved'
Write-Host "  JSON: $JSONPath" -ForegroundColor Gray
if ($HTMLReport) {
    Write-Host "  HTML: $HTMLPath" -ForegroundColor Gray

    if ($OpenReport) {
        Write-Header 'Opening HTML report...'
        Start-Process $HTMLPath
    }
}
