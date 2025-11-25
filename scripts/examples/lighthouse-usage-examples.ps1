# Lighthouse Wrapper Usage Examples
# Demonstrates various ways to use the LighthouseWrapper module

# Import the module
Import-Module (Join-Path $PSScriptRoot '..' 'LighthouseWrapper.psd1') -Force

#region Example 1: Quick audit with no file output
Write-Host "`nExample 1: Quick in-memory audit" -ForegroundColor Cyan
Write-Host "=" * 60

$result = Invoke-LighthouseAudit -URL 'http://localhost:4000'
Show-LighthouseResults -Result $result

#endregion

#region Example 2: Save JSON report
Write-Host "`nExample 2: Audit with JSON output" -ForegroundColor Cyan
Write-Host "=" * 60

$result = Invoke-LighthouseAudit -URL 'http://localhost:4000' -OutputPath 'benchmarks/test-audit'
Show-LighthouseResults -Result $result -ShowMetrics

#endregion

#region Example 3: Generate HTML report and open
Write-Host "`nExample 3: HTML report" -ForegroundColor Cyan
Write-Host "=" * 60

$result = Invoke-LighthouseAudit `
    -URL 'http://localhost:4000' `
    -OutputPath 'benchmarks/test-with-html' `
    -HTMLReport `
    -OpenReport

#endregion

#region Example 4: Mobile audit
Write-Host "`nExample 4: Mobile device audit" -ForegroundColor Cyan
Write-Host "=" * 60

$result = Invoke-LighthouseAudit -URL 'http://localhost:4000' -Device mobile
Show-LighthouseResults -Result $result

#endregion

#region Example 5: Compare local vs production
Write-Host "`nExample 5: Compare environments" -ForegroundColor Cyan
Write-Host "=" * 60

$localResult = Invoke-LighthouseAudit -URL 'http://localhost:4000'
$prodResult = Invoke-LighthouseAudit -URL 'https://christaylor.codes'

Compare-LighthouseResults -Results @($localResult, $prodResult)

#endregion

#region Example 6: Export scores to CSV
Write-Host "`nExample 6: Export scores to CSV" -ForegroundColor Cyan
Write-Host "=" * 60

$urls = @(
    'http://localhost:4000',
    'http://localhost:4000/about',
    'http://localhost:4000/blog',
    'http://localhost:4000/projects'
)

$results = $urls | ForEach-Object {
    Write-Host "Auditing $_..." -ForegroundColor Gray
    Invoke-LighthouseAudit -URL $_
}

$scores = $results | Get-LighthouseScores
$scores | Export-Csv 'benchmarks/scores.csv' -NoTypeInformation

Write-Host "`nScores saved to benchmarks/scores.csv" -ForegroundColor Green
$scores | Format-Table -AutoSize

#endregion

#region Example 7: Specific categories only
Write-Host "`nExample 7: Performance and SEO only" -ForegroundColor Cyan
Write-Host "=" * 60

$result = Invoke-LighthouseAudit `
    -URL 'http://localhost:4000' `
    -Categories @('performance', 'seo')

Show-LighthouseResults -Result $result -ShowMetrics

#endregion

#region Example 8: Pipeline usage
Write-Host "`nExample 8: Pipeline processing" -ForegroundColor Cyan
Write-Host "=" * 60

@('http://localhost:4000', 'http://localhost:4000/about') |
    ForEach-Object { Invoke-LighthouseAudit -URL $_ } |
    Show-LighthouseResults

#endregion

Write-Host "`n" -NoNewline
Write-Host "All examples completed!" -ForegroundColor Green
