#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Jekyll build and serve script for christaylor.codes website

.DESCRIPTION
    Simplified build script for local development and testing.
    Handles dependency installation, building, and serving with live reload.

.PARAMETER Mode
    Build mode: 'serve' (default), 'build', 'clean', 'sync-stats', 'benchmark', 'optimize-images', or 'validate-images'
    - serve: Build and serve with live reload at http://localhost:4000
    - build: Build only (outputs to _site/)
    - clean: Clean build artifacts and cache
    - sync-stats: Sync project stats from _data/project-stats.yml to project files
    - benchmark: Run performance benchmarks and check for regressions
    - optimize-images: Convert images to WebP, extract dimensions, validate performance
    - validate-images: Check all images meet performance standards

.EXAMPLE
    .\build.ps1
    Builds and serves with live reload (default)

.EXAMPLE
    .\build.ps1 -Mode build
    Builds the site without serving

.EXAMPLE
    .\build.ps1 -Mode clean
    Cleans build artifacts

.EXAMPLE
    .\build.ps1 -Mode sync-stats
    Syncs centralized stats to project files for GitHub Pages compatibility

.EXAMPLE
    .\build.ps1 -Mode benchmark
    Runs performance benchmarks to check for regressions

.EXAMPLE
    .\build.ps1 -Mode optimize-images
    Optimizes images to WebP format with performance validation

.EXAMPLE
    .\build.ps1 -Mode validate-images
    Validates all images meet performance standards
#>

[CmdletBinding()]
param(
    [ValidateSet('serve', 'build', 'clean', 'sync-stats', 'benchmark', 'optimize-images', 'validate-images')]
    [string]$Mode = 'serve'
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Banner
Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "  Jekyll Build Script" -ForegroundColor Cyan
Write-Host "  christaylor.codes" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Verify we're in the Website directory
if (-not (Test-Path "Gemfile")) {
    Write-Host "`n[ERROR] Gemfile not found. Are you in the Website directory?" -ForegroundColor Red
    exit 1
}


# Sync stats mode
if ($Mode -eq 'sync-stats') {
    $syncScript = Join-Path $PSScriptRoot "scripts\sync-project-stats.ps1"
    if (-not (Test-Path $syncScript)) {
        Write-Host "`n[ERROR] scripts\sync-project-stats.ps1 not found!" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    & $syncScript
    exit $LASTEXITCODE
}

# Optimize images mode
if ($Mode -eq 'optimize-images') {
    Write-Host "`n[OPTIMIZE] Starting image optimization workflow..." -ForegroundColor Yellow
    Write-Host "  This will convert images to WebP and validate performance" -ForegroundColor Gray
    Write-Host ""

    # Step 1: Optimize and convert images
    Write-Host "[STEP 1/4] Converting images to WebP..." -ForegroundColor Cyan
    $optimizeScript = Join-Path $PSScriptRoot "scripts\optimize-images.ps1"
    if (-not (Test-Path $optimizeScript)) {
        Write-Host "[ERROR] scripts\optimize-images.ps1 not found!" -ForegroundColor Red
        exit 1
    }
    & $optimizeScript -ConvertAll
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[FAILED] Image optimization failed!" -ForegroundColor Red
        exit 1
    }

    # Step 2: Update references
    Write-Host "`n[STEP 2/4] Updating image references in HTML/MD files..." -ForegroundColor Cyan
    $updateScript = Join-Path $PSScriptRoot "scripts\update-image-references.ps1"
    if (-not (Test-Path $updateScript)) {
        Write-Host "[ERROR] scripts\update-image-references.ps1 not found!" -ForegroundColor Red
        exit 1
    }
    & $updateScript -AddLoadingAttributes -AddFetchPriority
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[FAILED] Reference update failed!" -ForegroundColor Red
        exit 1
    }

    # Step 3: Generate responsive sizes (optional, only for hero images)
    Write-Host "`n[STEP 3/4] Generating responsive image sizes..." -ForegroundColor Cyan
    $responsiveScript = Join-Path $PSScriptRoot "scripts\generate-responsive-sizes.ps1"
    if (-not (Test-Path $responsiveScript)) {
        Write-Host "[ERROR] scripts\generate-responsive-sizes.ps1 not found!" -ForegroundColor Red
        exit 1
    }
    & $responsiveScript -ImageTypes Hero,Screenshot
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[WARN] Responsive size generation had issues (continuing)" -ForegroundColor Yellow
    }

    # Step 4: Validate performance
    Write-Host "`n[STEP 4/4] Validating performance compliance..." -ForegroundColor Cyan
    $validateScript = Join-Path $PSScriptRoot "scripts\validate-image-performance.ps1"
    if (-not (Test-Path $validateScript)) {
        Write-Host "[ERROR] scripts\validate-image-performance.ps1 not found!" -ForegroundColor Red
        exit 1
    }
    & $validateScript -GenerateReport

    Write-Host "`n[SUCCESS] Image optimization workflow complete!" -ForegroundColor Green
    Write-Host "  Next steps:" -ForegroundColor Cyan
    Write-Host "    1. Review the changes in git" -ForegroundColor Gray
    Write-Host "    2. Test the site locally: .\build.ps1" -ForegroundColor Gray
    Write-Host "    3. Commit changes if everything looks good" -ForegroundColor Gray
    exit 0
}

# Validate images mode
if ($Mode -eq 'validate-images') {
    Write-Host "`n[VALIDATE] Checking image performance compliance..." -ForegroundColor Yellow
    Write-Host "  Standards: CLAUDE.md performance guidelines" -ForegroundColor Gray
    Write-Host ""

    $validateScript = Join-Path $PSScriptRoot "scripts\validate-image-performance.ps1"
    if (-not (Test-Path $validateScript)) {
        Write-Host "[ERROR] scripts\validate-image-performance.ps1 not found!" -ForegroundColor Red
        exit 1
    }

    & $validateScript -GenerateReport -FailOnWarnings
    exit $LASTEXITCODE
}

# Benchmark mode
if ($Mode -eq 'benchmark') {
    Write-Host "`n[BENCHMARK] Running performance regression tests..." -ForegroundColor Yellow
    Write-Host "  This will check for performance degradation since last optimization" -ForegroundColor Gray
    Write-Host ""

    # Check if server is running
    try {
        $null = Invoke-WebRequest -Uri "http://localhost:4000" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Local server not running at http://localhost:4000" -ForegroundColor Red
        Write-Host "  Please start the server first with: .\build.ps1" -ForegroundColor Yellow
        exit 1
    }

    # Run benchmark script
    $benchmarkScript = Join-Path $PSScriptRoot "scripts\benchmark-performance.ps1"
    if (-not (Test-Path $benchmarkScript)) {
        Write-Host "[ERROR] scripts\benchmark-performance.ps1 not found!" -ForegroundColor Red
        exit 1
    }

    Write-Host "[BENCHMARK] Testing homepage..." -ForegroundColor Cyan
    & $benchmarkScript -Target local -Device desktop

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[FAILED] Homepage benchmark failed!" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n[BENCHMARK] Testing about page..." -ForegroundColor Cyan
    & lighthouse http://localhost:4000/about/ `
        --output=json `
        --output-path=benchmarks/lighthouse_about_benchmark.json `
        --quiet `
        --chrome-path="C:\Program Files\Google\Chrome\Application\chrome.exe" `
        --chrome-flags="--headless" `
        --preset=desktop

    if ($LASTEXITCODE -eq 0) {
        # Display about page results
        $aboutResults = Get-Content benchmarks/lighthouse_about_benchmark.json | ConvertFrom-Json
        $perfScore = [math]::Round($aboutResults.categories.performance.score * 100)
        $clsScore = [math]::Round($aboutResults.audits.'cumulative-layout-shift'.numericValue, 3)

        Write-Host "`n[RESULTS] About Page Performance:" -ForegroundColor Cyan
        Write-Host "  Performance: $perfScore/100" -ForegroundColor $(if ($perfScore -ge 90) { 'Green' } else { 'Yellow' })
        Write-Host "  CLS: $clsScore" -ForegroundColor $(if ($clsScore -le 0.1) { 'Green' } else { 'Red' })

        # Check thresholds
        $failed = $false
        if ($perfScore -lt 90) {
            Write-Host "`n[WARN] Performance score below 90% threshold" -ForegroundColor Yellow
            $failed = $true
        }
        if ($clsScore -gt 0.1) {
            Write-Host "`n[FAIL] CLS exceeds 0.1 threshold - layout shift regression detected!" -ForegroundColor Red
            $failed = $true
        }

        if ($failed) {
            Write-Host "`n[FAILED] Performance regression detected!" -ForegroundColor Red
            Write-Host "  Review benchmarks in: benchmarks/" -ForegroundColor Gray
            exit 1
        } else {
            Write-Host "`n[SUCCESS] All performance benchmarks passed!" -ForegroundColor Green
            Write-Host "  ✅ Performance: $perfScore% (target: 90%)" -ForegroundColor Green
            Write-Host "  ✅ CLS: $clsScore (target: <0.1)" -ForegroundColor Green
            exit 0
        }
    } else {
        Write-Host "`n[ERROR] About page benchmark failed!" -ForegroundColor Red
        exit 1
    }
}

# Clean mode
if ($Mode -eq 'clean') {
    Write-Host "`n[CLEAN] Removing build artifacts..." -ForegroundColor Yellow

    $itemsToRemove = @('_site', '.sass-cache', '.jekyll-cache', '.jekyll-metadata')
    foreach ($item in $itemsToRemove) {
        if (Test-Path $item) {
            Remove-Item -Path $item -Recurse -Force
            Write-Host "  Removed: $item" -ForegroundColor Gray
        }
    }

    Write-Host "`n[SUCCESS] Clean complete!" -ForegroundColor Green
    exit 0
}

# Check if bundle is installed
Write-Host "`n[CHECK] Verifying Ruby and Bundler..." -ForegroundColor Yellow
try {
    $null = bundle --version
    Write-Host "  Bundler found" -ForegroundColor Gray
} catch {
    Write-Host "`n[ERROR] Bundler not found. Install Ruby and Bundler first." -ForegroundColor Red
    Write-Host "  Visit: https://jekyllrb.com/docs/installation/windows/" -ForegroundColor Gray
    exit 1
}

# Check if dependencies are installed
Write-Host "`n[CHECK] Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "Gemfile.lock")) {
    Write-Host "  Gemfile.lock not found. Installing dependencies..." -ForegroundColor Gray
    bundle install
} else {
    Write-Host "  Dependencies installed" -ForegroundColor Gray
}

# Optional: Minify JavaScript if terser is available
Write-Host "`n[MINIFY] Checking for JavaScript minifier..." -ForegroundColor Yellow
try {
    $terserVersion = npx --no-install terser --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Terser found (version $terserVersion)" -ForegroundColor Gray
        Write-Host "  Minifying JavaScript files..." -ForegroundColor Gray

        $jsSource = "assets/js/main.js"
        $jsOutput = "assets/js/main.min.js"

        if (Test-Path $jsSource) {
            npx --no-install terser $jsSource --compress --mangle --comments false --output $jsOutput

            if ($LASTEXITCODE -eq 0) {
                $originalSize = (Get-Item $jsSource).Length
                $minifiedSize = (Get-Item $jsOutput).Length
                $reduction = [math]::Round((1 - ($minifiedSize / $originalSize)) * 100, 1)

                Write-Host "  JavaScript minified successfully" -ForegroundColor Green
                Write-Host "    Original: $([math]::Round($originalSize / 1KB, 1)) KB" -ForegroundColor Gray
                Write-Host "    Minified: $([math]::Round($minifiedSize / 1KB, 1)) KB" -ForegroundColor Gray
                Write-Host "    Reduction: $reduction%" -ForegroundColor Gray
            } else {
                Write-Host "  Minification failed, continuing with original JS" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  Terser not installed (optional)" -ForegroundColor Gray
        Write-Host "  Install with: npm install -g terser" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Node.js/npm not found (optional)" -ForegroundColor Gray
    Write-Host "  Local development will use non-minified JavaScript" -ForegroundColor Gray
}

# Build or Serve
if ($Mode -eq 'build') {
    Write-Host "`n[BUILD] Building site..." -ForegroundColor Yellow
    Write-Host "  Output: _site/" -ForegroundColor Gray

    bundle exec jekyll build

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[SUCCESS] Build complete!" -ForegroundColor Green
        Write-Host "  Site generated in: _site/" -ForegroundColor Gray

        # Check for compiled CSS
        $cssPath = "_site/assets/css/styles.css"
        if (Test-Path $cssPath) {
            $cssSize = (Get-Item $cssPath).Length
            $cssSizeKB = [math]::Round($cssSize / 1KB, 1)
            Write-Host "  Compiled CSS: $cssSizeKB KB" -ForegroundColor Gray
        }
    } else {
        Write-Host "`n[ERROR] Build failed. Check errors above." -ForegroundColor Red
        exit 1
    }

} else {
    # Serve mode
    Write-Host "`n[SERVE] Starting Jekyll server with live reload..." -ForegroundColor Yellow
    Write-Host "  URL: http://localhost:4000" -ForegroundColor Gray
    Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host "`n" -NoNewline

    bundle exec jekyll serve --livereload
}
