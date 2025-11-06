# Sync Project Stats from YAML to Project Files
#
# This script reads stats from _data/project-stats.yml and writes them
# back to individual project files for GitHub Pages compatibility.
#
# GitHub Pages doesn't support custom Ruby plugins, so we need stats
# in the project front matter for the site to work when deployed.
#
# Options:
#   -WhatIf: Show what would be done without making changes
#   -FetchGalleryStats: Fetch live download counts from PowerShell Gallery

param(
    [switch]$WhatIf,  # Show what would be done without making changes
    [switch]$FetchGalleryStats  # Fetch live download counts from PowerShell Gallery
)

function Get-PowerShellGalleryDownloads {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    try {
        # Use FindPackagesById endpoint which returns all versions
        # Each version entry contains the TOTAL download count for the package
        $findUrl = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='$PackageName'"

        Write-Verbose "Fetching stats for $PackageName from PowerShell Gallery..."

        $response = Invoke-RestMethod -Uri $findUrl -ErrorAction Stop

        if ($response -is [array] -and $response.Count -gt 0) {
            # All versions show the same total download count, so just get it from the first entry
            $downloadCount = $response[0].properties.DownloadCount.'#text'
            if ($downloadCount) {
                return [int]$downloadCount
            }
        }
        elseif ($response.properties.DownloadCount) {
            # Single item response
            return [int]$response.properties.DownloadCount.'#text'
        }

        Write-Warning "No download data found for package: $PackageName"
        return 0
    }
    catch {
        Write-Warning "Failed to fetch stats for $PackageName : $_"
        return 0
    }
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Project Stats Sync" -ForegroundColor Cyan
Write-Host "  christaylor.codes" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Load the centralized stats
$statsFile = Join-Path $PSScriptRoot "_data\project-stats.yml"
if (-not (Test-Path $statsFile)) {
    Write-Host "[ERROR] Stats file not found: $statsFile" -ForegroundColor Red
    exit 1
}

Write-Host "[LOAD] Reading centralized stats from: _data/project-stats.yml" -ForegroundColor Yellow

# Parse YAML manually (simple parsing for this structure)
$stats = @{}
$currentProject = $null
Get-Content $statsFile | ForEach-Object {
    if ($_ -match '^([a-z-]+):$') {
        $currentProject = $matches[1]
        $stats[$currentProject] = @{}
    }
    elseif ($_ -match '^\s+stars:\s+(\d+)') {
        $stats[$currentProject].stars = [int]$matches[1]
    }
    elseif ($_ -match '^\s+gallery_downloads:\s+(\d+)') {
        $stats[$currentProject].gallery_downloads = [int]$matches[1]
    }
}

Write-Host "  Found stats for $($stats.Count) projects" -ForegroundColor Green
Write-Host ""

# Optionally fetch live PowerShell Gallery download counts
if ($FetchGalleryStats) {
    Write-Host "[FETCH] Fetching live download counts from PowerShell Gallery..." -ForegroundColor Yellow
    Write-Host ""

    # Read project files to get package names
    $projectsDir = Join-Path $PSScriptRoot "_projects"
    $projectFiles = Get-ChildItem "$projectsDir\*.md"

    foreach ($file in $projectFiles) {
        $projectId = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

        # Skip if no stats entry exists
        if (-not $stats.ContainsKey($projectId)) {
            continue
        }

        # Read file to find PowerShell Gallery URL
        $content = Get-Content $file.FullName -Raw

        if ($content -match 'powershell_gallery_url:\s*"https://www\.powershellgallery\.com/packages/([^"]+)"') {
            $packageName = $matches[1]

            Write-Host "  [FETCH] $packageName..." -NoNewline

            $downloads = Get-PowerShellGalleryDownloads -PackageName $packageName

            if ($downloads -gt 0) {
                $stats[$projectId].gallery_downloads = $downloads
                Write-Host " $downloads downloads" -ForegroundColor Green
            }
            else {
                Write-Host " Not found or 0 downloads" -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""
    Write-Host "[UPDATE] Updating _data/project-stats.yml with fetched counts..." -ForegroundColor Yellow

    # Rebuild YAML file with updated counts
    $yamlContent = @"
# Project Statistics - GitHub Stars and PowerShell Gallery Downloads
# Last Updated: $(Get-Date -Format 'yyyy-MM-dd')
#
# This file centralizes all project statistics to enable easy updates
# without modifying individual project files. Update these values
# periodically to keep the site current.
#
# To update:
# 1. Run .\sync-project-stats.ps1 -FetchGalleryStats to fetch live counts
# 2. Check GitHub for current star counts (manual update)
# 3. Commit and push changes

"@

    foreach ($projectId in ($stats.Keys | Sort-Object)) {
        $projectStats = $stats[$projectId]
        $displayName = $projectId -replace '-', ' ' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }

        $yamlContent += @"

# $displayName
$projectId`:
  stars: $($projectStats.stars)
  gallery_downloads: $($projectStats.gallery_downloads)
"@
    }

    if ($WhatIf) {
        Write-Host "  [WHATIF] Would update _data/project-stats.yml" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Preview of updated content:" -ForegroundColor DarkGray
        Write-Host $yamlContent -ForegroundColor DarkGray
    }
    else {
        Set-Content -Path $statsFile -Value $yamlContent -NoNewline
        Write-Host "  [SAVED] _data/project-stats.yml updated" -ForegroundColor Green
    }

    Write-Host ""
}

# Process each project file
$projectsDir = Join-Path $PSScriptRoot "_projects"
$projectFiles = Get-ChildItem "$projectsDir\*.md"

Write-Host "[SYNC] Updating project files..." -ForegroundColor Yellow

$updated = 0
$skipped = 0

foreach ($file in $projectFiles) {
    $projectId = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if (-not $stats.ContainsKey($projectId)) {
        Write-Host "  [SKIP] $($file.Name) - No stats found" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    $projectStats = $stats[$projectId]
    $content = Get-Content $file.FullName -Raw

    # Check if stats already exist
    $hasStars = $content -match '(?m)^stars:'
    $hasDownloads = $content -match '(?m)^gallery_downloads:'

    if ($hasStars -and $hasDownloads) {
        # Update existing values
        $newContent = $content -replace '(?m)^stars:.*$', "stars: $($projectStats.stars)"
        $newContent = $newContent -replace '(?m)^gallery_downloads:.*$', "gallery_downloads: $($projectStats.gallery_downloads)"
    }
    else {
        # Add stats before the 'order:' line (or at the end of front matter)
        if ($content -match '(?m)^order:') {
            # Insert before order line
            $newContent = $content -replace '(?m)(^order:)', "stars: $($projectStats.stars)`r`ngallery_downloads: $($projectStats.gallery_downloads)`r`n`$1"
        }
        elseif ($content -match '---\r?\n\r?\n') {
            # Insert before closing front matter
            $newContent = $content -replace '(---\r?\n)', "`$1stars: $($projectStats.stars)`r`ngallery_downloads: $($projectStats.gallery_downloads)`r`n"
        }
        else {
            Write-Host "  [WARN] $($file.Name) - Could not find insertion point" -ForegroundColor Yellow
            $skipped++
            continue
        }
    }

    if ($WhatIf) {
        Write-Host "  [WHATIF] Would update $($file.Name): stars=$($projectStats.stars), downloads=$($projectStats.gallery_downloads)" -ForegroundColor Cyan
    }
    else {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "  [UPDATE] $($file.Name): stars=$($projectStats.stars), downloads=$($projectStats.gallery_downloads)" -ForegroundColor Green
    }

    $updated++
}

Write-Host ""
Write-Host "[COMPLETE]" -ForegroundColor Cyan
Write-Host "  Updated: $updated projects" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Skipped: $skipped projects" -ForegroundColor Yellow
}

if ($WhatIf) {
    Write-Host ""
    Write-Host "This was a dry run. Run without -WhatIf to apply changes." -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Host "Project files have been synced with centralized stats." -ForegroundColor Green
    Write-Host "You can now build and deploy to GitHub Pages." -ForegroundColor Cyan
}
