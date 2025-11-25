param([string]$JsonPath)

$r = Get-Content $JsonPath | ConvertFrom-Json

Write-Host "`nPerformance Scores:" -ForegroundColor Cyan
Write-Host "  Performance:    $($r.categories.performance.score * 100)/100"
Write-Host "  Accessibility:  $($r.categories.accessibility.score * 100)/100"
Write-Host "  Best Practices: $($r.categories.'best-practices'.score * 100)/100"
Write-Host "  SEO:            $($r.categories.seo.score * 100)/100"

Write-Host "`nCore Web Vitals:" -ForegroundColor Cyan
Write-Host "  CLS: $([math]::Round($r.audits.'cumulative-layout-shift'.numericValue, 3))"
Write-Host "  LCP: $([math]::Round($r.audits.'largest-contentful-paint'.numericValue))ms"
Write-Host "  FCP: $([math]::Round($r.audits.'first-contentful-paint'.numericValue))ms"
Write-Host "  TBT: $([math]::Round($r.audits.'total-blocking-time'.numericValue))ms"
