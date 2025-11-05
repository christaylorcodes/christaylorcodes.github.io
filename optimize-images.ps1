#Requires -Version 5.1
<#
.SYNOPSIS
    Optimizes website images by converting to WebP format and comparing sizes.

.DESCRIPTION
    This script processes JPG and PNG images in the assets/images directory,
    converting them to WebP format for better compression and performance.

    Requirements:
    - ImageMagick or cwebp tool (https://developers.google.com/speed/webp/download)

.PARAMETER Quality
    WebP quality setting (0-100). Default: 85

.PARAMETER ConvertAll
    Convert all images, not just large ones (>50KB)

.EXAMPLE
    .\optimize-images.ps1
    Converts large images with default quality 85

.EXAMPLE
    .\optimize-images.ps1 -Quality 90 -ConvertAll
    Converts all images with quality 90
#>

param(
    [Parameter()]
    [ValidateRange(0, 100)]
    [int]$Quality = 85,

    [Parameter()]
    [switch]$ConvertAll
)

$ErrorActionPreference = 'Stop'
$imagesPath = Join-Path $PSScriptRoot "assets\images"

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = 'White')
    $colors = @{
        'Red' = [ConsoleColor]::Red
        'Green' = [ConsoleColor]::Green
        'Yellow' = [ConsoleColor]::Yellow
        'Cyan' = [ConsoleColor]::Cyan
        'White' = [ConsoleColor]::White
    }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

Write-ColorOutput "`n=== Website Image Optimization ===" 'Cyan'
Write-ColorOutput "Quality setting: $Quality" 'White'

# Check for cwebp tool
$cwebpPath = $null
$cwebpLocations = @(
    "C:\Program Files\libwebp\bin\cwebp.exe",
    "C:\Program Files (x86)\libwebp\bin\cwebp.exe",
    "$env:ProgramFiles\libwebp\bin\cwebp.exe",
    (Get-Command cwebp -ErrorAction SilentlyContinue).Source
)

foreach ($location in $cwebpLocations) {
    if ($location -and (Test-Path $location)) {
        $cwebpPath = $location
        break
    }
}

if (-not $cwebpPath) {
    Write-ColorOutput "`nERROR: cwebp tool not found!" 'Red'
    Write-ColorOutput "Please install WebP tools from: https://developers.google.com/speed/webp/download" 'Yellow'
    Write-ColorOutput "Or install via Chocolatey: choco install webp" 'Yellow'
    exit 1
}

Write-ColorOutput "Using: $cwebpPath`n" 'Green'

# Get images to process
$minSize = if ($ConvertAll) { 0 } else { 50KB }
$images = Get-ChildItem -Path $imagesPath -Recurse -File |
    Where-Object {
        $_.Extension -match '\.(jpg|jpeg|png)$' -and
        $_.Length -gt $minSize
    } |
    Sort-Object Length -Descending

if ($images.Count -eq 0) {
    Write-ColorOutput "No images to optimize (threshold: $([math]::Round($minSize/1KB, 2)) KB)" 'Yellow'
    exit 0
}

Write-ColorOutput "Found $($images.Count) image(s) to optimize:`n" 'Cyan'

$totalOriginal = 0
$totalOptimized = 0
$results = @()

foreach ($image in $images) {
    $originalSize = $image.Length
    $originalSizeKB = [math]::Round($originalSize / 1KB, 2)
    $relativePath = $image.FullName.Replace("$PSScriptRoot\", "")

    Write-ColorOutput "Processing: $relativePath ($originalSizeKB KB)" 'White'

    # Create WebP filename
    $webpPath = [System.IO.Path]::ChangeExtension($image.FullName, '.webp')

    try {
        # Convert to WebP
        $arguments = @(
            '-q', $Quality,
            $image.FullName,
            '-o', $webpPath
        )

        $process = Start-Process -FilePath $cwebpPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -eq 0 -and (Test-Path $webpPath)) {
            $webpSize = (Get-Item $webpPath).Length
            $webpSizeKB = [math]::Round($webpSize / 1KB, 2)
            $savedKB = [math]::Round(($originalSize - $webpSize) / 1KB, 2)
            $savedPercent = [math]::Round((($originalSize - $webpSize) / $originalSize) * 100, 1)

            $totalOriginal += $originalSize
            $totalOptimized += $webpSize

            Write-ColorOutput "  → Created: $([System.IO.Path]::GetFileName($webpPath)) ($webpSizeKB KB)" 'Green'
            Write-ColorOutput "  → Saved: $savedKB KB ($savedPercent%)" 'Green'

            $results += [PSCustomObject]@{
                Original = $relativePath
                OriginalKB = $originalSizeKB
                WebP = $webpPath.Replace("$PSScriptRoot\", "")
                WebPKB = $webpSizeKB
                SavedKB = $savedKB
                SavedPercent = $savedPercent
            }
        } else {
            Write-ColorOutput "  → FAILED to convert" 'Red'
        }
    } catch {
        Write-ColorOutput "  → ERROR: $($_.Exception.Message)" 'Red'
    }

    Write-Host ""
}

# Summary
if ($results.Count -gt 0) {
    Write-ColorOutput "`n=== Optimization Summary ===" 'Cyan'
    Write-ColorOutput "Files processed: $($results.Count)" 'White'

    $totalOriginalKB = [math]::Round($totalOriginal / 1KB, 2)
    $totalOptimizedKB = [math]::Round($totalOptimized / 1KB, 2)
    $totalSavedKB = [math]::Round(($totalOriginal - $totalOptimized) / 1KB, 2)
    $totalSavedPercent = [math]::Round((($totalOriginal - $totalOptimized) / $totalOriginal) * 100, 1)

    Write-ColorOutput "Original size: $totalOriginalKB KB" 'White'
    Write-ColorOutput "WebP size: $totalOptimizedKB KB" 'Green'
    Write-ColorOutput "Total saved: $totalSavedKB KB ($totalSavedPercent%)" 'Green'

    Write-ColorOutput "`nNext steps:" 'Cyan'
    Write-ColorOutput "1. Update HTML/CSS to use WebP with fallbacks" 'Yellow'
    Write-ColorOutput "2. Test WebP images load correctly" 'Yellow'
    Write-ColorOutput "3. Consider removing original images after verification" 'Yellow'
} else {
    Write-ColorOutput "No images were optimized." 'Yellow'
}

Write-ColorOutput "`n=== Complete ===" 'Cyan'