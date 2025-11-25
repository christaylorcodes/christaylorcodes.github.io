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
$imagesPath = Join-Path $PSScriptRoot '..\assets\images'

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

# Image type detection and performance targets
function Get-ImageTypeInfo {
    param(
        [string]$ImageName,
        [int]$Width,
        [int]$Height
    )

    # Detect type by filename patterns and dimensions
    if ($ImageName -match '^hero-background') {
        return @{
            Type = 'Hero'
            MaxSizeKB = 500
            TargetDimensions = '1920x1080'
            RecommendedQuality = 40
            Description = 'Hero background image'
        }
    }
    elseif ($ImageName -match 'profile|avatar|headshot|photo') {
        return @{
            Type = 'Profile'
            MaxSizeKB = 100
            TargetDimensions = '400x400'
            RecommendedQuality = 80
            Description = 'Profile photo'
        }
    }
    elseif ($ImageName -match 'screenshot|terminal|ui-|demo-') {
        return @{
            Type = 'Screenshot'
            MaxSizeKB = 300
            TargetDimensions = '800x600 or 1920x1080'
            RecommendedQuality = 70
            Description = 'Screenshot or demo image'
        }
    }
    elseif ($ImageName -match 'social|og-image|card|share') {
        return @{
            Type = 'Social'
            MaxSizeKB = 500
            TargetDimensions = '1200x630'
            RecommendedQuality = 75
            Description = 'Social sharing image'
        }
    }
    else {
        return @{
            Type = 'General'
            MaxSizeKB = 500
            TargetDimensions = 'Varies'
            RecommendedQuality = 65
            Description = 'General image'
        }
    }
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

# Get images to process (convert JPG/PNG to WebP)
$minSize = if ($ConvertAll) { 0 } else { 50KB }
$imagesToConvert = Get-ChildItem -Path $imagesPath -Recurse -File |
    Where-Object {
        $_.Extension -match '\.(jpg|jpeg|png)$' -and
        $_.Length -gt $minSize
    } |
    Sort-Object Length -Descending

# Also scan existing WebP files to generate metadata
$existingWebP = Get-ChildItem -Path $imagesPath -Recurse -File |
    Where-Object { $_.Extension -eq '.webp' } |
    Sort-Object Length -Descending

if ($imagesToConvert.Count -eq 0 -and $existingWebP.Count -eq 0) {
    Write-ColorOutput "No images found in $imagesPath" 'Yellow'
    exit 0
}

if ($imagesToConvert.Count -eq 0) {
    Write-ColorOutput "No JPG/PNG images to convert (all images already optimized)" 'Green'
    Write-ColorOutput "Scanning $($existingWebP.Count) existing WebP image(s) for metadata...`n" 'Cyan'
}
else {
    Write-ColorOutput "Found $($imagesToConvert.Count) image(s) to convert:`n" 'Cyan'
}

$images = $imagesToConvert

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

            # Extract WebP dimensions
            $webpWidth = 0
            $webpHeight = 0
            $webpDimensionsArgs = @('identify', '-format', '%w %h', $webpPath)
            $webpDimensionsOutput = & $magickPath $webpDimensionsArgs 2>&1

            if ($LASTEXITCODE -eq 0 -and $webpDimensionsOutput -match '(\d+) (\d+)') {
                $webpWidth = [int]$matches[1]
                $webpHeight = [int]$matches[2]
            }

            # Detect image type and get performance targets
            $imageTypeInfo = Get-ImageTypeInfo -ImageName $image.Name -Width $webpWidth -Height $webpHeight

            Write-ColorOutput "  -> Created: $([System.IO.Path]::GetFileName($webpPath)) ($webpSizeKB KB, quality: $qualityToUse)" 'Green'
            Write-ColorOutput "  -> Dimensions: ${webpWidth}x${webpHeight}" 'White'
            Write-ColorOutput "  -> Image type: $($imageTypeInfo.Description)" 'Cyan'
            Write-ColorOutput "  -> Saved: $savedKB KB ($savedPercent%)" 'Green'

            # Validate against performance targets
            $sizeCompliant = $webpSizeKB -le $imageTypeInfo.MaxSizeKB
            if (-not $sizeCompliant) {
                Write-ColorOutput "  -> WARNING: Exceeds performance target of $($imageTypeInfo.MaxSizeKB) KB" 'Yellow'
                Write-ColorOutput "  -> Consider reducing quality or dimensions" 'Yellow'
            }
            else {
                Write-ColorOutput "  -> Performance target: PASS (<$($imageTypeInfo.MaxSizeKB) KB)" 'Green'
            }

            # Delete original background image files after successful conversion
            if ($isBackgroundImage) {
                Remove-Item $image.FullName -Force
                Write-ColorOutput "  -> Deleted original file (background images use WebP only)" 'Yellow'
            }

            $results += [PSCustomObject]@{
                Original          = $relativePath
                OriginalKB        = $originalSizeKB
                WebP              = $webpPath.Replace("$PSScriptRoot\..\", '')
                WebPKB            = $webpSizeKB
                Width             = $webpWidth
                Height            = $webpHeight
                SavedKB           = $savedKB
                SavedPercent      = $savedPercent
                Type              = $imageTypeInfo.Type
                Description       = $imageTypeInfo.Description
                TargetSizeKB      = $imageTypeInfo.MaxSizeKB
                TargetDimensions  = $imageTypeInfo.TargetDimensions
                SizeCompliant     = $sizeCompliant
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

# Process existing WebP files to generate metadata
if ($existingWebP.Count -gt 0) {
    Write-ColorOutput "`nScanning existing WebP images for metadata..." 'Cyan'

    $rootPath = Split-Path $PSScriptRoot -Parent

    foreach ($webpImage in $existingWebP) {
        $webpPath = $webpImage.FullName
        $relativePath = $webpPath.Replace("$rootPath\", '')
        $webpSize = $webpImage.Length
        $webpSizeKB = [math]::Round($webpSize / 1KB, 2)

        # Extract dimensions
        $webpWidth = 0
        $webpHeight = 0
        $webpDimensionsArgs = @('identify', '-format', '%w %h', $webpPath)
        $webpDimensionsOutput = & $magickPath $webpDimensionsArgs 2>&1

        if ($LASTEXITCODE -eq 0 -and $webpDimensionsOutput -match '(\d+) (\d+)') {
            $webpWidth = [int]$matches[1]
            $webpHeight = [int]$matches[2]
        }

        # Detect image type and get performance targets
        $imageTypeInfo = Get-ImageTypeInfo -ImageName $webpImage.Name -Width $webpWidth -Height $webpHeight

        # Validate against performance targets
        $sizeCompliant = $webpSizeKB -le $imageTypeInfo.MaxSizeKB

        Write-ColorOutput "  $($webpImage.Name): ${webpWidth}x${webpHeight}, $webpSizeKB KB - $($imageTypeInfo.Type)" $(if ($sizeCompliant) { 'Green' } else { 'Yellow' })

        # Add to results for metadata export
        $results += [PSCustomObject]@{
            Original          = $relativePath
            OriginalKB        = $webpSizeKB
            WebP              = $relativePath
            WebPKB            = $webpSizeKB
            Width             = $webpWidth
            Height            = $webpHeight
            SavedKB           = 0
            SavedPercent      = 0
            Type              = $imageTypeInfo.Type
            Description       = $imageTypeInfo.Description
            TargetSizeKB      = $imageTypeInfo.MaxSizeKB
            TargetDimensions  = $imageTypeInfo.TargetDimensions
            SizeCompliant     = $sizeCompliant
        }
    }
}

# Summary
if ($results.Count -gt 0) {
    Write-ColorOutput "`n=== Optimization Summary ===" 'Cyan'

    # Group by type
    $imagesByType = $results | Group-Object -Property Type

    foreach ($typeGroup in $imagesByType) {
        $typeName = $typeGroup.Name
        $typeImages = $typeGroup.Group
        $nonCompliantCount = ($typeImages | Where-Object { -not $_.SizeCompliant }).Count

        Write-ColorOutput "`n$typeName Images:" 'Cyan'
        Write-ColorOutput "  Files processed: $($typeImages.Count)" 'White'

        foreach ($img in $typeImages) {
            $complianceStatus = if ($img.SizeCompliant) { 'PASS' } else { 'FAIL' }
            $complianceColor = if ($img.SizeCompliant) { 'Green' } else { 'Yellow' }
            $dimensionsText = "$($img.Width)x$($img.Height)"
            Write-ColorOutput "  - $($img.WebP)" 'White'
            Write-ColorOutput "    Size: $($img.WebPKB) KB | Dimensions: $dimensionsText | Target: <$($img.TargetSizeKB) KB | Status: $complianceStatus" $complianceColor
        }

        if ($nonCompliantCount -gt 0) {
            Write-ColorOutput "  Performance warnings: $nonCompliantCount image(s) exceed size targets" 'Yellow'
        }
        else {
            Write-ColorOutput "  All images meet performance targets" 'Green'
        }
    }

    Write-ColorOutput "`nTotal Statistics:" 'Cyan'

    if ($totalOriginal -gt 0) {
        $totalOriginalKB = [math]::Round($totalOriginal / 1KB, 2)
        $totalOptimizedKB = [math]::Round($totalOptimized / 1KB, 2)
        $totalSavedKB = [math]::Round(($totalOriginal - $totalOptimized) / 1KB, 2)
        $totalSavedPercent = [math]::Round((($totalOriginal - $totalOptimized) / $totalOriginal) * 100, 1)

        Write-ColorOutput "  Original size: $totalOriginalKB KB" 'White'
        Write-ColorOutput "  WebP size: $totalOptimizedKB KB" 'Green'
        Write-ColorOutput "  Total saved: $totalSavedKB KB ($totalSavedPercent%)" 'Green'
    }
    else {
        Write-ColorOutput "  Images scanned: $($results.Count)" 'White'
        $totalSizeKB = ($results | Measure-Object -Property WebPKB -Sum).Sum
        Write-ColorOutput "  Total size: $([math]::Round($totalSizeKB, 2)) KB" 'Green'
    }

    $totalCompliant = ($results | Where-Object SizeCompliant).Count
    $totalNonCompliant = ($results | Where-Object { -not $_.SizeCompliant }).Count
    Write-ColorOutput "  Performance compliance: $totalCompliant/$($results.Count) images" $(if ($totalNonCompliant -eq 0) { 'Green' } else { 'Yellow' })

    # Export metadata
    $metadataPath = Join-Path $PSScriptRoot '..\assets\images\image-metadata.json'
    $metadata = @{
        LastUpdated = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        Images = $results | ForEach-Object {
            @{
                Path = $_.WebP
                Width = $_.Width
                Height = $_.Height
                SizeKB = $_.WebPKB
                Type = $_.Type
                Compliant = $_.SizeCompliant
            }
        }
    }
    $metadata | ConvertTo-Json -Depth 10 | Set-Content $metadataPath -Encoding UTF8
    Write-ColorOutput "`nMetadata exported to: $metadataPath" 'Cyan'

    Write-ColorOutput "`nNext steps:" 'Cyan'
    Write-ColorOutput '1. Run update-image-references.ps1 to update HTML/MD files' 'Yellow'
    Write-ColorOutput '2. Run generate-responsive-sizes.ps1 for hero/large images' 'Yellow'
    Write-ColorOutput '3. Run validate-image-performance.ps1 to verify compliance' 'Yellow'
}
else {
    Write-ColorOutput 'No images were optimized.' 'Yellow'
}

Write-ColorOutput "`n=== Complete ===" 'Cyan'
