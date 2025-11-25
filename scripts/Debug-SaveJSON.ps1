# Save raw JSON and check it

Import-Module .\scripts\LighthouseWrapper.psd1 -Force

Write-Host "Running audit with file output..." -ForegroundColor Cyan
$result = Invoke-LighthouseAudit -URL 'http://localhost:4000' -OutputPath 'benchmarks/debug-test'

Write-Host "`nJSON saved to: $($result.JSONPath)" -ForegroundColor Green

if (Test-Path $result.JSONPath) {
    Write-Host "`nReading JSON file directly..." -ForegroundColor Yellow
    $jsonContent = Get-Content $result.JSONPath -Raw
    $parsed = $jsonContent | ConvertFrom-Json

    Write-Host "Lighthouse version: $($parsed.lighthouseVersion)" -ForegroundColor Gray

    if ($parsed.categories) {
        Write-Host "`nCategories found in file!" -ForegroundColor Green

        # List all category properties
        $parsed.categories.PSObject.Properties | ForEach-Object {
            Write-Host "  Category: $($_.Name)" -ForegroundColor Cyan
            if ($_.Value.score -ne $null) {
                $score = [math]::Round($_.Value.score * 100)
                Write-Host "    Score: $score/100" -ForegroundColor Green
            }
        }
    }
    else {
        Write-Host "`nNo categories in JSON file!" -ForegroundColor Red
        Write-Host "Top level properties:" -ForegroundColor Yellow
        $parsed.PSObject.Properties.Name | ForEach-Object { Write-Host "  $_" }
    }
}
