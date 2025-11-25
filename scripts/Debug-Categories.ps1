# Direct category access test

Import-Module .\scripts\LighthouseWrapper.psd1 -Force

Write-Host "Running audit..." -ForegroundColor Cyan
$result = Invoke-LighthouseAudit -URL 'http://localhost:4000'

Write-Host "`nDirect access tests:" -ForegroundColor Cyan

Write-Host "`n1. PSObject.Properties approach:" -ForegroundColor Yellow
$categoryNames = $result.RawJSON.categories.PSObject.Properties.Name
Write-Host "Category names: $($categoryNames -join ', ')"

foreach ($catName in $categoryNames) {
    $category = $result.RawJSON.categories.$catName
    if ($category.score -ne $null) {
        $scorePercent = [math]::Round($category.score * 100)
        Write-Host "  $catName`: $scorePercent/100" -ForegroundColor Green
    }
}

Write-Host "`n2. ConvertTo-Json and back:" -ForegroundColor Yellow
$jsonString = $result.RawJSON.categories | ConvertTo-Json -Depth 3
$categoriesObj = $jsonString | ConvertFrom-Json

$categoriesObj.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $score = $_.Value.score
    if ($score -ne $null) {
        $scorePercent = [math]::Round($score * 100)
        Write-Host "  $name`: $scorePercent/100" -ForegroundColor Cyan
    }
}
