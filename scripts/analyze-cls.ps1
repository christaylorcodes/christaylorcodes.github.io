# Analyze CLS data from Lighthouse report
param([string]$JsonPath)

$results = Get-Content $JsonPath | ConvertFrom-Json
$cls = $results.audits.'cumulative-layout-shift'

Write-Host "`nCLS Analysis:" -ForegroundColor Cyan
Write-Host "Score: $($cls.numericValue)" -ForegroundColor Yellow
Write-Host "Display: $($cls.displayValue)"
Write-Host ""

if ($cls.details.items) {
    Write-Host "Elements causing layout shift:" -ForegroundColor Cyan
    $cls.details.items | Select-Object -First 10 | ForEach-Object {
        if ($_.node) {
            Write-Host "  Element: $($_.node.snippet)" -ForegroundColor White
            Write-Host "  Shift Score: $($_.score)" -ForegroundColor Red
            if ($_.node.nodeLabel) {
                Write-Host "  Label: $($_.node.nodeLabel)" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
}

# Check for other CLS-related audits
Write-Host "`nOther relevant findings:" -ForegroundColor Cyan

$fontDisplay = $results.audits.'font-display'
if ($fontDisplay -and $fontDisplay.score -lt 1) {
    Write-Host "  Font Display: $($fontDisplay.displayValue)" -ForegroundColor Yellow
}

$imageAspectRatio = $results.audits.'image-aspect-ratio'
if ($imageAspectRatio -and $imageAspectRatio.score -lt 1) {
    Write-Host "  Images with incorrect aspect ratio detected" -ForegroundColor Yellow
}

$imageSize = $results.audits.'image-size-responsive'
if ($imageSize -and $imageSize.score -lt 1) {
    Write-Host "  Images without dimensions detected" -ForegroundColor Yellow
}
