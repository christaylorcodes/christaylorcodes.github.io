#Requires -Version 5.1
<#
.SYNOPSIS
    Validates images meet performance standards from CLAUDE.md.

.DESCRIPTION
    Comprehensive validation of all website images against performance guidelines:

    Size Limits (from CLAUDE.md):
    - Hero images: 1920x1080px, <500KB
    - Profile photos: 400x400px, <100KB
    - Screenshots: 800x600 or 1920x1080, <300KB
    - Social sharing: 1200x630px, <500KB

    Checks:
    - File format (WebP preferred)
    - File size compliance
    - Dimension validation
    - HTML/MD references have width/height attributes
    - Loading attributes present
    - CLS prevention (layout shift)

.PARAMETER GenerateReport
    Generate detailed HTML report of findings

.PARAMETER FailOnWarnings
    Exit with error code if any warnings found (for CI/CD)

.EXAMPLE
    .\validate-image-performance.ps1
    Validate all images and display results

.EXAMPLE
    .\validate-image-performance.ps1 -GenerateReport
    Generate detailed HTML validation report

.EXAMPLE
    .\validate-image-performance.ps1 -FailOnWarnings
    Fail build if any compliance issues found
#>

param(
    [Parameter()]
    [switch]$GenerateReport,

    [Parameter()]
    [switch]$FailOnWarnings
)

$ErrorActionPreference = 'Stop'

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = 'White')
    $colors = @{
        'Red'    = [ConsoleColor]::Red
        'Green'  = [ConsoleColor]::Green
        'Yellow' = [ConsoleColor]::Yellow
        'Cyan'   = [ConsoleColor]::Cyan
        'White'  = [ConsoleColor]::White
    }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

Write-ColorOutput "`n=== Image Performance Validation ===" 'Cyan'
Write-ColorOutput "Performance Standards: CLAUDE.md`n" 'White'

# Check for ImageMagick
$magickPath = $null
$magickLocations = @(
    'C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe',
    "$env:ProgramFiles\ImageMagick*\magick.exe",
    (Get-Command magick -ErrorAction SilentlyContinue).Source
)

foreach ($location in $magickLocations) {
    if ($location -and (Test-Path $location)) {
        $magickPath = $location
        break
    }
    if ($location -like '*\*') {
        $found = Get-Item $location -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $magickPath = $found.FullName
            break
        }
    }
}

if (-not $magickPath) {
    Write-ColorOutput "`nERROR: ImageMagick not found!" 'Red'
    Write-ColorOutput 'Please install ImageMagick from: https://imagemagick.org/script/download.php' 'Yellow'
    exit 1
}

# Performance standards from CLAUDE.md
$performanceStandards = @{
    Hero       = @{ MaxSizeKB = 500; TargetDimensions = @('1920x1080') }
    Profile    = @{ MaxSizeKB = 100; TargetDimensions = @('400x400') }
    Screenshot = @{ MaxSizeKB = 300; TargetDimensions = @('800x600', '1920x1080') }
    Social     = @{ MaxSizeKB = 500; TargetDimensions = @('1200x630') }
    General    = @{ MaxSizeKB = 500; TargetDimensions = @('Varies') }
}

# Get all images
$imagesPath = Join-Path $PSScriptRoot '..\assets\images'
$images = Get-ChildItem -Path $imagesPath -Recurse -File |
    Where-Object { $_.Extension -match '\.(webp|jpg|jpeg|png|svg)$' } |
    Sort-Object Length -Descending

Write-ColorOutput "Found $($images.Count) images to validate`n" 'Cyan'

$issues = @()
$warnings = @()
$passed = @()

foreach ($image in $images) {
    $relativePath = $image.FullName.Replace("$PSScriptRoot\..\", '')
    $sizeKB = [math]::Round($image.Length / 1KB, 2)

    # Detect image type from filename
    $imageType = 'General'
    if ($image.Name -match '^hero-background') { $imageType = 'Hero' }
    elseif ($image.Name -match 'profile|avatar|headshot|photo') { $imageType = 'Profile' }
    elseif ($image.Name -match 'screenshot|terminal|ui-|demo-') { $imageType = 'Screenshot' }
    elseif ($image.Name -match 'social|og-image|card|share') { $imageType = 'Social' }

    $standard = $performanceStandards[$imageType]

    # Check 1: File format (prefer WebP)
    if ($image.Extension -ne '.webp' -and $image.Extension -ne '.svg') {
        $warnings += [PSCustomObject]@{
            File    = $relativePath
            Type    = $imageType
            Issue   = 'Format'
            Message = "Not WebP format ($($image.Extension))"
            Severity = 'Warning'
        }
    }

    # Check 2: File size
    if ($sizeKB -gt $standard.MaxSizeKB) {
        $issues += [PSCustomObject]@{
            File     = $relativePath
            Type     = $imageType
            Issue    = 'Size'
            Message  = "Exceeds target: $sizeKB KB > $($standard.MaxSizeKB) KB"
            Severity = 'Error'
        }
    }

    # Check 3: Dimensions (skip SVG)
    if ($image.Extension -ne '.svg') {
        $identifyArgs = @('identify', '-format', '%w %h', $image.FullName)
        $dimensionsOutput = & $magickPath $identifyArgs 2>&1

        if ($LASTEXITCODE -eq 0 -and $dimensionsOutput -match '(\d+) (\d+)') {
            $width = [int]$matches[1]
            $height = [int]$matches[2]
            $actualDimensions = "${width}x${height}"

            # Check if dimensions match any target
            $dimensionMatch = $false
            foreach ($targetDim in $standard.TargetDimensions) {
                if ($targetDim -eq 'Varies' -or $actualDimensions -eq $targetDim) {
                    $dimensionMatch = $true
                    break
                }
            }

            if (-not $dimensionMatch -and $imageType -ne 'General') {
                $warnings += [PSCustomObject]@{
                    File     = $relativePath
                    Type     = $imageType
                    Issue    = 'Dimensions'
                    Message  = "Unexpected dimensions: $actualDimensions (expected: $($standard.TargetDimensions -join ' or '))"
                    Severity = 'Warning'
                }
            }
        }
    }

    # If no issues, mark as passed
    if (-not ($issues | Where-Object File -eq $relativePath) -and -not ($warnings | Where-Object File -eq $relativePath)) {
        $passed += [PSCustomObject]@{
            File   = $relativePath
            Type   = $imageType
            SizeKB = $sizeKB
        }
    }
}

# Check HTML/MD references
Write-ColorOutput "Validating HTML/Markdown references...`n" 'Cyan'

$rootPath = Split-Path $PSScriptRoot -Parent
$contentFiles = Get-ChildItem -Path $rootPath -Include *.html,*.md -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\node_modules\\|\\vendor\\|\\_site\\|\\.git\\' }

$missingDimensionsCount = 0
$missingLoadingCount = 0

foreach ($file in $contentFiles) {
    $content = Get-Content $file.FullName -Raw

    # Find all <img> tags
    $imgTags = [regex]::Matches($content, '<img[^>]+>')

    foreach ($match in $imgTags) {
        $imgTag = $match.Value

        # Check for width/height attributes
        $hasWidth = $imgTag -match 'width\s*='
        $hasHeight = $imgTag -match 'height\s*='

        if (-not ($hasWidth -and $hasHeight)) {
            $srcMatch = [regex]::Match($imgTag, 'src\s*=\s*[''"]([^''"]+)[''"]')
            $src = if ($srcMatch.Success) { $srcMatch.Groups[1].Value } else { 'unknown' }

            $warnings += [PSCustomObject]@{
                File     = $file.FullName.Replace("$rootPath\", '')
                Type     = 'Reference'
                Issue    = 'Missing Dimensions'
                Message  = "Image missing width/height: $src"
                Severity = 'Warning'
            }

            $missingDimensionsCount++
        }

        # Check for loading attribute
        $hasLoading = $imgTag -match 'loading\s*='

        if (-not $hasLoading) {
            $missingLoadingCount++
        }
    }
}

# Display Results
Write-ColorOutput "`n=== Validation Results ===" 'Cyan'

if ($issues.Count -gt 0) {
    Write-ColorOutput "`nERRORS ($($issues.Count)):" 'Red'
    foreach ($issue in $issues) {
        Write-ColorOutput "  $($issue.File)" 'White'
        Write-ColorOutput "    Type: $($issue.Type) | Issue: $($issue.Issue)" 'Red'
        Write-ColorOutput "    $($issue.Message)" 'Yellow'
    }
}

if ($warnings.Count -gt 0) {
    Write-ColorOutput "`nWARNINGS ($($warnings.Count)):" 'Yellow'
    foreach ($warning in $warnings) {
        Write-ColorOutput "  $($warning.File)" 'White'
        Write-ColorOutput "    Type: $($warning.Type) | Issue: $($warning.Issue)" 'Yellow'
        Write-ColorOutput "    $($warning.Message)" 'White'
    }
}

Write-ColorOutput "`nSUMMARY:" 'Cyan'
Write-ColorOutput "  Total images: $($images.Count)" 'White'
Write-ColorOutput "  Passed: $($passed.Count)" 'Green'
Write-ColorOutput "  Errors: $($issues.Count)" $(if ($issues.Count -gt 0) { 'Red' } else { 'Green' })
Write-ColorOutput "  Warnings: $($warnings.Count)" $(if ($warnings.Count -gt 0) { 'Yellow' } else { 'Green' })

Write-ColorOutput "`nREFERENCE VALIDATION:" 'Cyan'
Write-ColorOutput "  Images without dimensions: $missingDimensionsCount" $(if ($missingDimensionsCount -gt 0) { 'Yellow' } else { 'Green' })
Write-ColorOutput "  Images without loading attribute: $missingLoadingCount" $(if ($missingLoadingCount -gt 0) { 'Yellow' } else { 'Green' })

# Generate report if requested
if ($GenerateReport) {
    $reportPath = Join-Path $PSScriptRoot '..\image-performance-report.html'

    $reportHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>Image Performance Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #06b6d4; }
        .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .error { color: #dc2626; }
        .warning { color: #f59e0b; }
        .pass { color: #10b981; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #06b6d4; color: white; }
    </style>
</head>
<body>
    <h1>Image Performance Validation Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>

    <div class="summary">
        <h2>Summary</h2>
        <p>Total images: $($images.Count)</p>
        <p class="pass">Passed: $($passed.Count)</p>
        <p class="error">Errors: $($issues.Count)</p>
        <p class="warning">Warnings: $($warnings.Count)</p>
    </div>

    <h2>Issues</h2>
    <table>
        <tr><th>File</th><th>Type</th><th>Issue</th><th>Message</th><th>Severity</th></tr>
"@

    foreach ($issue in ($issues + $warnings)) {
        $severityClass = if ($issue.Severity -eq 'Error') { 'error' } else { 'warning' }
        $reportHtml += @"
        <tr class="$severityClass">
            <td>$($issue.File)</td>
            <td>$($issue.Type)</td>
            <td>$($issue.Issue)</td>
            <td>$($issue.Message)</td>
            <td>$($issue.Severity)</td>
        </tr>
"@
    }

    $reportHtml += @"
    </table>

    <h2>Passed Images</h2>
    <table>
        <tr><th>File</th><th>Type</th><th>Size (KB)</th></tr>
"@

    foreach ($pass in $passed) {
        $reportHtml += @"
        <tr>
            <td>$($pass.File)</td>
            <td>$($pass.Type)</td>
            <td>$($pass.SizeKB)</td>
        </tr>
"@
    }

    $reportHtml += @"
    </table>
</body>
</html>
"@

    Set-Content $reportPath -Value $reportHtml -Encoding UTF8
    Write-ColorOutput "`nReport generated: $reportPath" 'Cyan'
}

# Exit with error if requested and issues found
if ($FailOnWarnings -and ($issues.Count -gt 0 -or $warnings.Count -gt 0)) {
    Write-ColorOutput "`nValidation FAILED - Compliance issues found" 'Red'
    exit 1
}

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-ColorOutput "`nAll images meet performance standards!" 'Green'
}

Write-ColorOutput "`n=== Complete ===" 'Cyan'
