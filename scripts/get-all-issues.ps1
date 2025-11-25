# Get all Lighthouse issues
param([string]$JsonPath)

$results = Get-Content $JsonPath | ConvertFrom-Json

Write-Host "`n=== LIGHTHOUSE ISSUES REPORT ===" -ForegroundColor Cyan
Write-Host ""

# Performance issues
Write-Host "PERFORMANCE ISSUES:" -ForegroundColor Yellow
$results.audits.GetEnumerator() | Where-Object {
    $_.Value.score -ne $null -and $_.Value.score -lt 1 -and $_.Value.scoreDisplayMode -eq 'numeric'
} | ForEach-Object {
    $audit = $_.Value
    if ($audit.details.items.Count -gt 0 -or $audit.description) {
        Write-Host "`n  $($audit.title)" -ForegroundColor White
        Write-Host "  Score: $($audit.score * 100)%" -ForegroundColor Red
        Write-Host "  $($audit.description)" -ForegroundColor Gray

        # Show specific items if available
        if ($audit.details.items) {
            $audit.details.items | Select-Object -First 3 | ForEach-Object {
                if ($_.url) { Write-Host "    - $($_.url)" -ForegroundColor DarkGray }
                if ($_.node.snippet) { Write-Host "    - $($_.node.snippet)" -ForegroundColor DarkGray }
            }
        }
    }
}

# List all audits that aren't passing
Write-Host "`n`nALL NON-PASSING AUDITS:" -ForegroundColor Yellow
$results.audits.PSObject.Properties | Where-Object {
    $_.Value.score -ne $null -and $_.Value.score -lt 1
} | Sort-Object { $_.Value.score } | ForEach-Object {
    $score = [math]::Round($_.Value.score * 100)
    $color = if ($score -ge 90) { 'Green' } elseif ($score -ge 50) { 'Yellow' } else { 'Red' }
    Write-Host "  [$score%] " -NoNewline -ForegroundColor $color
    Write-Host "$($_.Value.title)" -ForegroundColor White
}
