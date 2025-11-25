# Quick debug script to check Lighthouse result structure

Import-Module .\scripts\LighthouseWrapper.psd1 -Force

Write-Host "Running audit..." -ForegroundColor Cyan
$result = Invoke-LighthouseAudit -URL 'http://localhost:4000'

Write-Host "`nResult object properties:" -ForegroundColor Cyan
$result | Get-Member -MemberType Properties | Select-Object Name, Definition

Write-Host "`nCategories object:" -ForegroundColor Cyan
$result.Categories | Format-List

Write-Host "`nChecking if categories have scores:" -ForegroundColor Cyan
if ($result.Categories.performance) {
    Write-Host "Performance category exists" -ForegroundColor Green
    Write-Host "Score: $($result.Categories.performance.score)" -ForegroundColor Yellow
}
else {
    Write-Host "Performance category is NULL" -ForegroundColor Red
}

Write-Host "`nCategory property names:" -ForegroundColor Cyan
$result.Categories | Get-Member -MemberType Properties | Select-Object Name
