#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Jekyll build and serve script for christaylor.codes website

.DESCRIPTION
    Simplified build script for local development and testing.
    Handles dependency installation, building, and serving with live reload.

.PARAMETER Mode
    Build mode: 'serve' (default), 'build', 'clean', or 'sync-stats'
    - serve: Build and serve with live reload at http://localhost:4000
    - build: Build only (outputs to _site/)
    - clean: Clean build artifacts and cache
    - sync-stats: Sync project stats from _data/project-stats.yml to project files

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
#>

[CmdletBinding()]
param(
    [ValidateSet('serve', 'build', 'clean', 'sync-stats')]
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
