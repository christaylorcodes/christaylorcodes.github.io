# Test PowerShell Gallery API

$packageName = "ConnectWiseManageAPI"

Write-Host "Testing FindPackagesById endpoint..." -ForegroundColor Cyan
$findUrl = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='$packageName'"
$response = Invoke-RestMethod -Uri $findUrl

Write-Host "Response Type: $($response.GetType().FullName)"
Write-Host "Is Array: $($response -is [array])"
Write-Host "Count: $($response.Count)"
Write-Host ""

if ($response -is [array]) {
    Write-Host "First item properties:"
    $response[0] | Get-Member -MemberType Property | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Name): $($response[0].$($_.Name))"
    }

    Write-Host ""
    Write-Host "Download counts by version:"
    $response | ForEach-Object {
        Write-Host "  Version $($_.properties.Version.'#text'): $($_.properties.DownloadCount.'#text') downloads"
    }

    Write-Host ""
    $total = ($response | ForEach-Object { [int]$_.properties.DownloadCount.'#text' } | Measure-Object -Sum).Sum
    Write-Host "Total downloads: $total" -ForegroundColor Green
}
