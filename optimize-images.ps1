#Requires -Version 5.1
<#
.SYNOPSIS
    Optimizes website images by converting to WebP format and comparing sizes.

.DESCRIPTION
    This script processes JPG and PNG images in the assets/images directory,
    converting them to WebP format for better compression and performance.

    Background images (hero-background*) are handled specially:
    - Standardized to 1920x1080 resolution
    - Converted to WebP at quality 40
    - Original files are deleted after successful conversion
    - Alerts if source image is smaller than 1920x1080

    Requirements:
    - ImageMagick (https://imagemagick.org/script/download.php)
    - cwebp tool (https://developers.google.com/speed/webp/download)

.PARAMETER Quality
    WebP quality setting for non-background images (0-100). Default: 65

.PARAMETER BackgroundQuality
    WebP quality setting for background images (0-100). Default: 40

.PARAMETER ConvertAll
    Convert all images, not just large ones (>50KB)

.EXAMPLE
    .\optimize-images.ps1
    Converts large images with default quality settings

.EXAMPLE
    .\optimize-images.ps1 -Quality 80 -BackgroundQuality 50 -ConvertAll
    Converts all images with custom quality settings
#>

param(
    [Parameter()]
    [ValidateRange(0, 100)]
    [int]$Quality = 65,

    [Parameter()]
    [ValidateRange(0, 100)]
    [int]$BackgroundQuality = 40,

    [Parameter()]
    [switch]$ConvertAll
)

$ErrorActionPreference = 'Stop'
$imagesPath = Join-Path $PSScriptRoot 'assets\images'

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

Write-ColorOutput "`n=== Website Image Optimization ===" 'Cyan'
Write-ColorOutput "Quality setting (regular): $Quality" 'White'
Write-ColorOutput "Quality setting (backgrounds): $BackgroundQuality" 'White'

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
    # Try glob pattern
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
    Write-ColorOutput 'Or install via Chocolatey: choco install imagemagick' 'Yellow'
    exit 1
}

Write-ColorOutput "Using ImageMagick: $magickPath" 'Green'

# Check for cwebp tool
$cwebpPath = $null
$cwebpLocations = @(
    'C:\Program Files\libwebp\bin\cwebp.exe',
    'C:\Program Files (x86)\libwebp\bin\cwebp.exe',
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
    Write-ColorOutput 'Please install WebP tools from: https://developers.google.com/speed/webp/download' 'Yellow'
    Write-ColorOutput 'Or install via Chocolatey: choco install webp' 'Yellow'
    exit 1
}

Write-ColorOutput "Using cwebp: $cwebpPath`n" 'Green'

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
    $relativePath = $image.FullName.Replace("$PSScriptRoot\", '')
    $isBackgroundImage = $image.Name -match '^hero-background.*\.(jpg|jpeg|png)$'

    Write-ColorOutput "Processing: $relativePath ($originalSizeKB KB)" 'White'

    if ($isBackgroundImage) {
        Write-ColorOutput "  -> Background image detected" 'Cyan'
    }

    # Create WebP filename
    $webpPath = [System.IO.Path]::ChangeExtension($image.FullName, '.webp')

    try {
        $tempResizedPath = $null
        $sourceForWebP = $image.FullName

        # Handle background images specially
        if ($isBackgroundImage) {
            # Get image dimensions
            $identifyArgs = @('identify', '-format', '%w %h', $image.FullName)
            $dimensionsOutput = & $magickPath $identifyArgs 2>&1

            if ($LASTEXITCODE -eq 0 -and $dimensionsOutput -match '(\d+) (\d+)') {
                $width = [int]$matches[1]
                $height = [int]$matches[2]

                Write-ColorOutput "  -> Current dimensions: ${width}x${height}" 'White'

                # Check if image is smaller than target
                if ($width -lt 1920 -or $height -lt 1080) {
                    Write-ColorOutput "  -> WARNING: Image is smaller than 1920x1080!" 'Yellow'
                    Write-ColorOutput "  -> Consider using a higher resolution source image" 'Yellow'
                }

                # Resize if needed (larger than 1920x1080 or smaller and needs standardization)
                if ($width -ne 1920 -or $height -ne 1080) {
                    $tempResizedPath = [System.IO.Path]::ChangeExtension($image.FullName, '.resized.jpg')

                    # Resize to exactly 1920x1080 (will crop/scale as needed)
                    $resizeArgs = @(
                        $image.FullName,
                        '-resize', '1920x1080^',
                        '-gravity', 'center',
                        '-extent', '1920x1080',
                        $tempResizedPath
                    )

                    $resizeProcess = & $magickPath $resizeArgs 2>&1

                    if ($LASTEXITCODE -eq 0 -and (Test-Path $tempResizedPath)) {
                        Write-ColorOutput "  -> Resized to 1920x1080" 'Green'
                        $sourceForWebP = $tempResizedPath
                    }
                    else {
                        Write-ColorOutput "  -> WARNING: Failed to resize, using original" 'Yellow'
                    }
                }
                else {
                    Write-ColorOutput "  -> Already at target size 1920x1080" 'Green'
                }
            }
        }

        # Convert to WebP
        $qualityToUse = if ($isBackgroundImage) { $BackgroundQuality } else { $Quality }
        $arguments = @(
            '-q', $qualityToUse,
            $sourceForWebP,
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

            Write-ColorOutput "  -> Created: $([System.IO.Path]::GetFileName($webpPath)) ($webpSizeKB KB, quality: $qualityToUse)" 'Green'
            Write-ColorOutput "  -> Saved: $savedKB KB ($savedPercent%)" 'Green'

            # Delete original background image files after successful conversion
            if ($isBackgroundImage) {
                Remove-Item $image.FullName -Force
                Write-ColorOutput "  -> Deleted original file (background images use WebP only)" 'Yellow'
            }

            $results += [PSCustomObject]@{
                Original     = $relativePath
                OriginalKB   = $originalSizeKB
                WebP         = $webpPath.Replace("$PSScriptRoot\", '')
                WebPKB       = $webpSizeKB
                SavedKB      = $savedKB
                SavedPercent = $savedPercent
                Type         = if ($isBackgroundImage) { 'Background' } else { 'Regular' }
            }
        }
        else {
            Write-ColorOutput '  -> FAILED to convert' 'Red'
        }

        # Clean up temp resized file
        if ($tempResizedPath -and (Test-Path $tempResizedPath)) {
            Remove-Item $tempResizedPath -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-ColorOutput "  -> ERROR: $($_.Exception.Message)" 'Red'
    }

    Write-Host ''
}

# Summary
if ($results.Count -gt 0) {
    Write-ColorOutput "`n=== Optimization Summary ===" 'Cyan'

    $backgroundImages = $results | Where-Object Type -eq 'Background'
    $regularImages = $results | Where-Object Type -eq 'Regular'

    if ($backgroundImages) {
        $bgQualityText = "Background Images (1920x1080, quality $BackgroundQuality):"
        Write-ColorOutput "`n$bgQualityText" 'Cyan'
        Write-ColorOutput "  Files processed: $($backgroundImages.Count)" 'White'
        foreach ($bg in $backgroundImages) {
            Write-ColorOutput "  - $($bg.WebP): $($bg.WebPKB) KB (saved $($bg.SavedPercent)%)" 'Green'
        }
        Write-ColorOutput "  Original files deleted (WebP only)" 'Yellow'
    }

    if ($regularImages) {
        $regQualityText = "Regular Images (quality $Quality):"
        Write-ColorOutput "`n$regQualityText" 'Cyan'
        Write-ColorOutput "  Files processed: $($regularImages.Count)" 'White'
        foreach ($reg in $regularImages) {
            Write-ColorOutput "  - $($reg.WebP): $($reg.WebPKB) KB (saved $($reg.SavedPercent)%)" 'Green'
        }
    }

    $totalOriginalKB = [math]::Round($totalOriginal / 1KB, 2)
    $totalOptimizedKB = [math]::Round($totalOptimized / 1KB, 2)
    $totalSavedKB = [math]::Round(($totalOriginal - $totalOptimized) / 1KB, 2)
    $totalSavedPercent = [math]::Round((($totalOriginal - $totalOptimized) / $totalOriginal) * 100, 1)

    Write-ColorOutput "`nTotal Statistics:" 'Cyan'
    Write-ColorOutput "  Original size: $totalOriginalKB KB" 'White'
    Write-ColorOutput "  WebP size: $totalOptimizedKB KB" 'Green'
    $savedMessage = "  Total saved: $totalSavedKB KB ($totalSavedPercent%)"
    Write-ColorOutput $savedMessage 'Green'

    if ($regularImages) {
        Write-ColorOutput "`nNext steps:" 'Cyan'
        Write-ColorOutput '1. Update HTML/CSS to use WebP with fallbacks for regular images' 'Yellow'
        Write-ColorOutput '2. Test WebP images load correctly' 'Yellow'
        Write-ColorOutput '3. Consider removing original images after verification' 'Yellow'
    }
}
else {
    Write-ColorOutput 'No images were optimized.' 'Yellow'
}

Write-ColorOutput "`n=== Complete ===" 'Cyan'
