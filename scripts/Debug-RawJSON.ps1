# Check raw JSON structure

Import-Module .\scripts\LighthouseWrapper.psd1 -Force

Write-Host "Running audit..." -ForegroundColor Cyan
$result = Invoke-LighthouseAudit -URL 'http://localhost:4000'

Write-Host "`nRaw JSON top-level properties:" -ForegroundColor Cyan
$result.RawJSON | Get-Member -MemberType Properties | Select-Object Name

Write-Host "`nChecking for categories in RawJSON:" -ForegroundColor Cyan
if ($result.RawJSON.categories) {
    Write-Host "Categories exist in RawJSON!" -ForegroundColor Green
    Write-Host "`nCategory names:" -ForegroundColor Yellow
    $result.RawJSON.categories | Get-Member -MemberType Properties | Select-Object Name

    if ($result.RawJSON.categories.performance) {
        Write-Host "`nPerformance score: $($result.RawJSON.categories.performance.score)" -ForegroundColor Green
    }
}
else {
    Write-Host "No categories in RawJSON" -ForegroundColor Red
}

Write-Host "`nLighthouse version: $($result.RawJSON.lighthouseVersion)" -ForegroundColor Gray
Write-Host "Requested URL: $($result.RawJSON.requestedUrl)" -ForegroundColor Gray
