#Requires -Version 5.1
<#
.SYNOPSIS
    Generates responsive image sizes for srcset support.

.DESCRIPTION
    Creates multiple size variants of images for responsive srcset attributes.
    Reads image metadata from image-metadata.json and generates appropriate
    sizes based on image type (Hero, Screenshot, etc.).

    Size variants:
    - Hero images: 640w, 1280w, 1920w
    - Screenshots: 400w, 800w, 1600w
    - Profile: 200w, 400w
    - Social: 600w, 1200w

    Requires:
    - ImageMagick (https://imagemagick.org/script/download.php)
    - cwebp tool (https://developers.google.com/speed/webp/download)

.PARAMETER Quality
    WebP quality setting (0-100). Default: 75

.PARAMETER ImageTypes
    Image types to process (Hero, Screenshot, Profile, Social). Default: All

.EXAMPLE
    .\generate-responsive-sizes.ps1
    Generate responsive sizes for all applicable images

.EXAMPLE
    .\generate-responsive-sizes.ps1 -Quality 80 -ImageTypes Hero,Screenshot
    Generate only for Hero and Screenshot images at quality 80
#>

param(
    [Parameter()]
    [ValidateRange(0, 100)]
    [int]$Quality = 75,

    [Parameter()]
    [ValidateSet('Hero', 'Screenshot', 'Profile', 'Social', 'All')]
    [string[]]$ImageTypes = @('All')
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

Write-ColorOutput "`n=== Generate Responsive Image Sizes ===" 'Cyan'
Write-ColorOutput "Quality setting: $Quality`n" 'White'

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
    exit 1
}

Write-ColorOutput "Using cwebp: $cwebpPath`n" 'Green'

# Load image metadata
$metadataPath = Join-Path $PSScriptRoot '..\assets\images\image-metadata.json'
if (-not (Test-Path $metadataPath)) {
    Write-ColorOutput "`nERROR: Image metadata not found at: $metadataPath" 'Red'
    Write-ColorOutput 'Please run optimize-images.ps1 first to generate metadata' 'Yellow'
    exit 1
}

$metadata = Get-Content $metadataPath -Raw | ConvertFrom-Json
Write-ColorOutput "Loaded metadata for $($metadata.Images.Count) images`n" 'Green'

# Define size variants for each image type
$sizeVariants = @{
    Hero       = @(640, 1280, 1920)
    Screenshot = @(400, 800, 1600)
    Profile    = @(200, 400)
    Social     = @(600, 1200)
}

# Filter images based on ImageTypes parameter
$imagesToProcess = if ($ImageTypes -contains 'All') {
    $metadata.Images | Where-Object { $_.Type -in @('Hero', 'Screenshot', 'Profile', 'Social') }
}
else {
    $metadata.Images | Where-Object { $_.Type -in $ImageTypes }
}

if ($imagesToProcess.Count -eq 0) {
    Write-ColorOutput "No images to process for types: $($ImageTypes -join ', ')" 'Yellow'
    exit 0
}

Write-ColorOutput "Processing $($imagesToProcess.Count) image(s)`n" 'Cyan'

$results = @()
$totalGenerated = 0

foreach ($imageInfo in $imagesToProcess) {
    $imagePath = Join-Path $PSScriptRoot "..\$($imageInfo.Path)"

    if (-not (Test-Path $imagePath)) {
        Write-ColorOutput "WARNING: Image not found: $($imageInfo.Path)" 'Yellow'
        continue
    }

    $imageFileName = [System.IO.Path]::GetFileNameWithoutExtension($imagePath)
    $imageDir = [System.IO.Path]::GetDirectoryName($imagePath)

    Write-ColorOutput "Processing: $($imageInfo.Path)" 'White'
    Write-ColorOutput "  Type: $($imageInfo.Type) | Original: $($imageInfo.Width)x$($imageInfo.Height)" 'Cyan'

    $widths = $sizeVariants[$imageInfo.Type]
    $generatedSizes = @()

    foreach ($targetWidth in $widths) {
        # Skip if target width is larger than original
        if ($targetWidth -gt $imageInfo.Width) {
            Write-ColorOutput "  -> Skipping ${targetWidth}w (larger than original)" 'Yellow'
            continue
        }

        # Calculate proportional height
        $aspectRatio = $imageInfo.Height / $imageInfo.Width
        $targetHeight = [math]::Round($targetWidth * $aspectRatio)

        # Generate output filename
        $outputFileName = "${imageFileName}-${targetWidth}w.webp"
        $outputPath = Join-Path $imageDir $outputFileName

        # Skip if already exists and is recent
        if (Test-Path $outputPath) {
            $sourceTime = (Get-Item $imagePath).LastWriteTime
            $outputTime = (Get-Item $outputPath).LastWriteTime
            if ($outputTime -gt $sourceTime) {
                Write-ColorOutput "  -> ${targetWidth}w already exists (up to date)" 'Green'
                $generatedSizes += @{
                    Width  = $targetWidth
                    Height = $targetHeight
                    Path   = $outputFileName
                    Status = 'Existing'
                }
                continue
            }
        }

        try {
            # Create temp resized file
            $tempPath = [System.IO.Path]::ChangeExtension($outputPath, '.temp.jpg')

            # Resize with ImageMagick
            $resizeArgs = @(
                $imagePath,
                '-resize', "${targetWidth}x${targetHeight}!",
                '-strip',
                $tempPath
            )

            $null = & $magickPath $resizeArgs 2>&1

            if ($LASTEXITCODE -eq 0 -and (Test-Path $tempPath)) {
                # Convert to WebP
                $cwebpArgs = @(
                    '-q', $Quality,
                    $tempPath,
                    '-o', $outputPath
                )

                $null = Start-Process -FilePath $cwebpPath -ArgumentList $cwebpArgs -Wait -PassThru -NoNewWindow

                if ($LASTEXITCODE -eq 0 -and (Test-Path $outputPath)) {
                    $outputSize = (Get-Item $outputPath).Length
                    $outputSizeKB = [math]::Round($outputSize / 1KB, 2)

                    Write-ColorOutput "  -> ${targetWidth}w created: $outputSizeKB KB" 'Green'

                    $generatedSizes += @{
                        Width  = $targetWidth
                        Height = $targetHeight
                        Path   = $outputFileName
                        SizeKB = $outputSizeKB
                        Status = 'Created'
                    }

                    $totalGenerated++
                }
                else {
                    Write-ColorOutput "  -> ${targetWidth}w conversion failed" 'Red'
                }

                # Clean up temp file
                if (Test-Path $tempPath) {
                    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                }
            }
            else {
                Write-ColorOutput "  -> ${targetWidth}w resize failed" 'Red'
            }
        }
        catch {
            Write-ColorOutput "  -> ERROR: $($_.Exception.Message)" 'Red'
        }
    }

    if ($generatedSizes.Count -gt 0) {
        $results += [PSCustomObject]@{
            OriginalImage = $imageInfo.Path
            Type          = $imageInfo.Type
            Sizes         = $generatedSizes
        }
    }

    Write-Host ''
}

# Summary
Write-ColorOutput "`n=== Generation Summary ===" 'Cyan'

foreach ($result in $results) {
    Write-ColorOutput "`n$($result.OriginalImage) ($($result.Type)):" 'White'
    foreach ($size in $result.Sizes) {
        $statusColor = if ($size.Status -eq 'Created') { 'Green' } else { 'Cyan' }
        $sizeText = if ($size.SizeKB) { "$($size.SizeKB) KB" } else { 'existing' }
        Write-ColorOutput "  - ${size.Width}w: $sizeText [$($size.Status)]" $statusColor
    }
}

Write-ColorOutput "`nTotal Statistics:" 'Cyan'
Write-ColorOutput "  Images processed: $($results.Count)" 'White'
Write-ColorOutput "  New sizes generated: $totalGenerated" 'Green'

Write-ColorOutput "`nNext steps:" 'Cyan'
Write-ColorOutput '1. Update HTML to use srcset attributes for responsive images' 'Yellow'
Write-ColorOutput '2. Test responsive loading on different screen sizes' 'Yellow'
Write-ColorOutput '3. Run validate-image-performance.ps1 to verify compliance' 'Yellow'

Write-ColorOutput "`n=== Complete ===" 'Cyan'
