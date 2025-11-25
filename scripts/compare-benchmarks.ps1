# Benchmark Comparison Script
# Compares two Lighthouse JSON results to show performance improvements

param(
    [Parameter(Mandatory=$true)]
    [string]$Baseline,

    [Parameter(Mandatory=$true)]
    [string]$Current
)

$ErrorActionPreference = 'Stop'

# Helper functions
function Write-Header($message) {
    Write-Host "`n==> $message" -ForegroundColor Cyan
}

function Write-Improvement($value) {
    if ($value -gt 0) {
        Write-Host "+$value" -ForegroundColor Green -NoNewline
        Write-Host " (improved)" -ForegroundColor Green
    }
    elseif ($value -lt 0) {
        Write-Host "$value" -ForegroundColor Red -NoNewline
        Write-Host " (regressed)" -ForegroundColor Red
    }
    else {
        Write-Host "0 (no change)" -ForegroundColor Gray
    }
}

function Write-MetricDiff($name, $baseline, $current, $lower_is_better = $true) {
    $diff = $current - $baseline
    $diffPercent = if ($baseline -ne 0) { [math]::Round(($diff / $baseline) * 100, 1) } else { 0 }

    Write-Host "  $name" -NoNewline

    if ($lower_is_better) {
        # For metrics like load time, lower is better
        if ($diff -lt 0) {
            Write-Host " " -NoNewline
            Write-Host "$diff ms ($diffPercent%)" -ForegroundColor Green -NoNewline
            Write-Host " ✓ Faster" -ForegroundColor Green
        }
        elseif ($diff -gt 0) {
            Write-Host " " -NoNewline
            Write-Host "+$diff ms (+$diffPercent%)" -ForegroundColor Red -NoNewline
            Write-Host " ✗ Slower" -ForegroundColor Red
        }
        else {
            Write-Host " No change" -ForegroundColor Gray
        }
    }
    else {
        # For scores, higher is better
        if ($diff -gt 0) {
            Write-Host " " -NoNewline
            Write-Host "+$diff points (+$diffPercent%)" -ForegroundColor Green -NoNewline
            Write-Host " ✓ Better" -ForegroundColor Green
        }
        elseif ($diff -lt 0) {
            Write-Host " " -NoNewline
            Write-Host "$diff points ($diffPercent%)" -ForegroundColor Red -NoNewline
            Write-Host " ✗ Worse" -ForegroundColor Red
        }
        else {
            Write-Host " No change" -ForegroundColor Gray
        }
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Performance Benchmark Comparison                         ║" -ForegroundColor Cyan
Write-Host "║  christaylor.codes                                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Verify files exist
if (-not (Test-Path $Baseline)) {
    Write-Host "`n✗ Baseline file not found: $Baseline" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Current)) {
    Write-Host "`n✗ Current file not found: $Current" -ForegroundColor Red
    exit 1
}

Write-Host "`nBaseline: $Baseline" -ForegroundColor Gray
Write-Host "Current:  $Current" -ForegroundColor Gray

# Load results
Write-Header "Loading benchmark results..."
$baselineData = Get-Content $Baseline | ConvertFrom-Json
$currentData = Get-Content $Current | ConvertFrom-Json

# Compare scores
Write-Header "Performance Scores Comparison"

$baselineScores = $baselineData.categories
$currentScores = $currentData.categories

$perfDiff = [math]::Round(($currentScores.performance.score - $baselineScores.performance.score) * 100)
$a11yDiff = [math]::Round(($currentScores.accessibility.score - $baselineScores.accessibility.score) * 100)
$bpDiff = [math]::Round(($currentScores.'best-practices'.score - $baselineScores.'best-practices'.score) * 100)
$seoDiff = [math]::Round(($currentScores.seo.score - $baselineScores.seo.score) * 100)

Write-Host "  Performance:    $([math]::Round($baselineScores.performance.score * 100)) → $([math]::Round($currentScores.performance.score * 100)) " -NoNewline
Write-Improvement $perfDiff

Write-Host "  Accessibility:  $([math]::Round($baselineScores.accessibility.score * 100)) → $([math]::Round($currentScores.accessibility.score * 100)) " -NoNewline
Write-Improvement $a11yDiff

Write-Host "  Best Practices: $([math]::Round($baselineScores.'best-practices'.score * 100)) → $([math]::Round($currentScores.'best-practices'.score * 100)) " -NoNewline
Write-Improvement $bpDiff

Write-Host "  SEO:            $([math]::Round($baselineScores.seo.score * 100)) → $([math]::Round($currentScores.seo.score * 100)) " -NoNewline
Write-Improvement $seoDiff

# Compare Core Web Vitals
Write-Header "Core Web Vitals Comparison"

$baselineAudits = $baselineData.audits
$currentAudits = $currentData.audits

$fcpBase = [math]::Round($baselineAudits.'first-contentful-paint'.numericValue)
$fcpCurr = [math]::Round($currentAudits.'first-contentful-paint'.numericValue)
Write-MetricDiff "FCP (First Contentful Paint):" $fcpBase $fcpCurr

$lcpBase = [math]::Round($baselineAudits.'largest-contentful-paint'.numericValue)
$lcpCurr = [math]::Round($currentAudits.'largest-contentful-paint'.numericValue)
Write-MetricDiff "LCP (Largest Contentful Paint):" $lcpBase $lcpCurr

$tbtBase = [math]::Round($baselineAudits.'total-blocking-time'.numericValue)
$tbtCurr = [math]::Round($currentAudits.'total-blocking-time'.numericValue)
Write-MetricDiff "TBT (Total Blocking Time):" $tbtBase $tbtCurr

$clsBase = [math]::Round($baselineAudits.'cumulative-layout-shift'.numericValue, 3)
$clsCurr = [math]::Round($currentAudits.'cumulative-layout-shift'.numericValue, 3)
Write-Host "  CLS (Cumulative Layout Shift): " -NoNewline
if ($clsCurr -lt $clsBase) {
    Write-Host "$clsCurr (improved)" -ForegroundColor Green
}
elseif ($clsCurr -gt $clsBase) {
    Write-Host "$clsCurr (regressed)" -ForegroundColor Red
}
else {
    Write-Host "$clsCurr (no change)" -ForegroundColor Gray
}

$siBase = [math]::Round($baselineAudits.'speed-index'.numericValue)
$siCurr = [math]::Round($currentAudits.'speed-index'.numericValue)
Write-MetricDiff "Speed Index:" $siBase $siCurr

# Summary
Write-Header "Summary"

$totalImprovements = 0
$totalRegressions = 0

if ($perfDiff -gt 0) { $totalImprovements++ } elseif ($perfDiff -lt 0) { $totalRegressions++ }
if ($fcpCurr -lt $fcpBase) { $totalImprovements++ } elseif ($fcpCurr -gt $fcpBase) { $totalRegressions++ }
if ($lcpCurr -lt $lcpBase) { $totalImprovements++ } elseif ($lcpCurr -gt $lcpBase) { $totalRegressions++ }
if ($tbtCurr -lt $tbtBase) { $totalImprovements++ } elseif ($tbtCurr -gt $tbtBase) { $totalRegressions++ }

Write-Host "  Improvements: " -NoNewline
Write-Host "$totalImprovements" -ForegroundColor Green

Write-Host "  Regressions:  " -NoNewline
if ($totalRegressions -gt 0) {
    Write-Host "$totalRegressions" -ForegroundColor Red
}
else {
    Write-Host "$totalRegressions" -ForegroundColor Green
}

if ($totalImprovements -gt $totalRegressions) {
    Write-Host "`n✓ Overall performance improved!" -ForegroundColor Green
}
elseif ($totalRegressions -gt $totalImprovements) {
    Write-Host "`n✗ Performance has regressed" -ForegroundColor Red
}
else {
    Write-Host "`n→ Performance is similar" -ForegroundColor Gray
}

Write-Host ""
