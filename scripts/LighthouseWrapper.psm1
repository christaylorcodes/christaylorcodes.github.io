# LighthouseWrapper.psm1
# PowerShell module for working with Lighthouse CLI

#region Private Helper Functions

<#
.SYNOPSIS
    Finds the path to Chrome browser executable.
.DESCRIPTION
    Lighthouse CLI requires Google Chrome. Edge is not reliably supported in recent versions.
#>
function Find-ChromePath {
    [CmdletBinding()]
    param()

    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    )

    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            Write-Verbose "Found Chrome at: $path"
            return $path
        }
    }

    # Check if Edge exists (to give helpful message)
    $edgePaths = @(
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    )

    $hasEdge = $false
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            $hasEdge = $true
            break
        }
    }

    if ($hasEdge) {
        throw @"
Google Chrome is required for Lighthouse CLI.

Edge was detected on your system, but Lighthouse 12.x does not reliably support Edge.

Please install Google Chrome:
  https://www.google.com/chrome/

After installing Chrome, this script will work automatically.
"@
    }
    else {
        throw @"
No Chrome installation found.

Please install Google Chrome:
  https://www.google.com/chrome/
"@
    }
}

<#
.SYNOPSIS
    Formats a Lighthouse score (0-1) as a percentage with color.
#>
function Format-LighthouseScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [double]$Score,

        [switch]$NoColor
    )

    $percentage = [math]::Round($Score * 100)

    if ($NoColor) {
        return $percentage
    }

    $color = if ($percentage -ge 90) { 'Green' }
             elseif ($percentage -ge 50) { 'Yellow' }
             else { 'Red' }

    Write-Host $percentage -ForegroundColor $color -NoNewline
}

#endregion

#region Public Functions

<#
.SYNOPSIS
    Runs a Lighthouse audit on a specified URL.

.DESCRIPTION
    Executes Lighthouse CLI against a URL and returns the results as a PowerShell object.
    Can optionally save JSON and HTML reports.

.PARAMETER URL
    The URL to audit. Can be local (http://localhost:4000) or remote.

.PARAMETER Device
    Device preset to use. Valid values: 'desktop', 'mobile'. Default: 'desktop'

.PARAMETER OutputPath
    Optional path to save the JSON report. If not specified, results are only returned as objects.

.PARAMETER HTMLReport
    Generate an HTML report alongside the JSON report.

.PARAMETER OpenReport
    Automatically open the HTML report in the default browser (requires -HTMLReport).

.PARAMETER Categories
    Lighthouse categories to audit. Default: all categories.
    Valid values: 'performance', 'accessibility', 'best-practices', 'seo', 'pwa'

.EXAMPLE
    Invoke-LighthouseAudit -URL 'https://example.com'

    Runs a desktop audit and returns the results object.

.EXAMPLE
    Invoke-LighthouseAudit -URL 'http://localhost:4000' -Device mobile -OutputPath 'results.json'

    Runs a mobile audit on local server and saves JSON results.

.EXAMPLE
    Invoke-LighthouseAudit -URL 'https://example.com' -HTMLReport -OpenReport -OutputPath 'audit'

    Runs audit, saves JSON and HTML reports, and opens the HTML report.

.OUTPUTS
    PSCustomObject with properties: URL, Device, Timestamp, Categories, Audits, RawJSON
#>
function Invoke-LighthouseAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$URL,

        [ValidateSet('desktop', 'mobile')]
        [string]$Device = 'desktop',

        [string]$OutputPath,

        [switch]$HTMLReport,

        [switch]$OpenReport,

        [string[]]$Categories
    )

    Write-Verbose "Starting Lighthouse audit for: $URL"
    Write-Verbose "Device preset: $Device"

    # Find Chrome/Edge
    $chromePath = Find-ChromePath

    # Build output paths
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $tempOutput = $false

    if (-not $OutputPath) {
        # Use temp file if no output specified
        $OutputPath = Join-Path $env:TEMP "lighthouse_$timestamp"
        $tempOutput = $true
    }

    # Remove extension if provided (Lighthouse adds it)
    $OutputPath = $OutputPath -replace '\.(json|html)$', ''
    $jsonPath = "$OutputPath.json"
    $htmlPath = "$OutputPath.html"

    # Build Lighthouse command arguments
    $lighthouseArgs = @(
        $URL
        '--output=json'
        "--output-path=$jsonPath"
        '--quiet'
        "--chrome-path=`"$chromePath`""
        '--chrome-flags="--headless"'
        "--preset=$Device"
    )

    # Add categories filter if explicitly specified
    if ($Categories -and $Categories.Count -gt 0) {
        $categoryList = $Categories -join ','
        $lighthouseArgs += "--only-categories=$categoryList"
        Write-Verbose "Filtering categories: $categoryList"
    }
    else {
        Write-Verbose "Running all categories (default)"
    }

    # Add HTML output if requested
    if ($HTMLReport) {
        $lighthouseArgs = @(
            $URL
            '--output=json'
            '--output=html'
            "--output-path=$OutputPath"
            '--quiet'
            "--chrome-path=`"$chromePath`""
            '--chrome-flags="--headless"'
            "--preset=$Device"
        )
        if ($Categories -and $Categories.Count -gt 0) {
            $categoryList = $Categories -join ','
            $lighthouseArgs += "--only-categories=$categoryList"
            Write-Verbose "Filtering categories: $categoryList"
        }
    }

    # Run Lighthouse
    Write-Verbose "Running Lighthouse (this may take 30-60 seconds)..."
    try {
        $lighthouseCmd = "lighthouse $($lighthouseArgs -join ' ')"
        Write-Verbose "Command: $lighthouseCmd"

        $output = Invoke-Expression $lighthouseCmd 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "Lighthouse failed with exit code $LASTEXITCODE. Output: $output"
        }

        Write-Verbose "Lighthouse audit completed successfully"
    }
    catch {
        throw "Failed to run Lighthouse: $_"
    }

    # Parse results
    if (-not (Test-Path $jsonPath)) {
        throw "Lighthouse did not generate expected JSON output at: $jsonPath"
    }

    $rawResults = Get-Content $jsonPath -Raw | ConvertFrom-Json

    # Build result object
    $result = [PSCustomObject]@{
        URL        = $URL
        Device     = $Device
        Timestamp  = Get-Date
        Categories = $rawResults.categories
        Audits     = $rawResults.audits
        JSONPath   = if ($tempOutput) { $null } else { $jsonPath }
        HTMLPath   = if ($HTMLReport -and -not $tempOutput) { $htmlPath } else { $null }
        RawJSON    = $rawResults
    }

    # Open HTML report if requested
    if ($OpenReport -and $HTMLReport -and (Test-Path $htmlPath)) {
        Write-Verbose "Opening HTML report..."
        Start-Process $htmlPath
    }

    # Clean up temp file if used
    if ($tempOutput) {
        Remove-Item $jsonPath -ErrorAction SilentlyContinue
        if ($HTMLReport -and (Test-Path $htmlPath)) {
            Remove-Item $htmlPath -ErrorAction SilentlyContinue
        }
    }

    return $result
}

<#
.SYNOPSIS
    Displays Lighthouse audit results in a formatted table.

.DESCRIPTION
    Takes a Lighthouse result object (from Invoke-LighthouseAudit) and displays
    the scores and key metrics in a readable format.

.PARAMETER Result
    The result object from Invoke-LighthouseAudit.

.PARAMETER ShowMetrics
    Include Core Web Vitals metrics in the output.

.EXAMPLE
    $result = Invoke-LighthouseAudit -URL 'https://example.com'
    Show-LighthouseResults -Result $result -ShowMetrics

.EXAMPLE
    Invoke-LighthouseAudit -URL 'https://example.com' | Show-LighthouseResults
#>
function Show-LighthouseResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Result,

        [switch]$ShowMetrics
    )

    process {
        Write-Host "`nLighthouse Audit Results" -ForegroundColor Cyan
        Write-Host "URL: $($Result.URL)" -ForegroundColor Gray
        Write-Host "Device: $($Result.Device)" -ForegroundColor Gray
        Write-Host "Timestamp: $($Result.Timestamp)" -ForegroundColor Gray

        Write-Host "`nScores:" -ForegroundColor Cyan

        if ($Result.Categories.performance) {
            Write-Host '  Performance:    ' -NoNewline
            Format-LighthouseScore -Score $Result.Categories.performance.score
            Write-Host '/100'
        }

        if ($Result.Categories.accessibility) {
            Write-Host '  Accessibility:  ' -NoNewline
            Format-LighthouseScore -Score $Result.Categories.accessibility.score
            Write-Host '/100'
        }

        if ($Result.Categories.'best-practices') {
            Write-Host '  Best Practices: ' -NoNewline
            Format-LighthouseScore -Score $Result.Categories.'best-practices'.score
            Write-Host '/100'
        }

        if ($Result.Categories.seo) {
            Write-Host '  SEO:            ' -NoNewline
            Format-LighthouseScore -Score $Result.Categories.seo.score
            Write-Host '/100'
        }

        if ($Result.Categories.pwa) {
            Write-Host '  PWA:            ' -NoNewline
            Format-LighthouseScore -Score $Result.Categories.pwa.score
            Write-Host '/100'
        }

        if ($ShowMetrics -and $Result.Audits) {
            Write-Host "`nCore Web Vitals:" -ForegroundColor Cyan

            if ($Result.Audits.'first-contentful-paint') {
                Write-Host '  First Contentful Paint (FCP): ' -NoNewline
                Write-Host "$([math]::Round($Result.Audits.'first-contentful-paint'.numericValue))ms" -ForegroundColor Yellow
            }

            if ($Result.Audits.'largest-contentful-paint') {
                Write-Host '  Largest Contentful Paint (LCP): ' -NoNewline
                Write-Host "$([math]::Round($Result.Audits.'largest-contentful-paint'.numericValue))ms" -ForegroundColor Yellow
            }

            if ($Result.Audits.'total-blocking-time') {
                Write-Host '  Total Blocking Time (TBT): ' -NoNewline
                Write-Host "$([math]::Round($Result.Audits.'total-blocking-time'.numericValue))ms" -ForegroundColor Yellow
            }

            if ($Result.Audits.'cumulative-layout-shift') {
                Write-Host '  Cumulative Layout Shift (CLS): ' -NoNewline
                Write-Host "$([math]::Round($Result.Audits.'cumulative-layout-shift'.numericValue, 3))" -ForegroundColor Yellow
            }

            if ($Result.Audits.'speed-index') {
                Write-Host '  Speed Index: ' -NoNewline
                Write-Host "$([math]::Round($Result.Audits.'speed-index'.numericValue))ms" -ForegroundColor Yellow
            }
        }

        if ($Result.JSONPath) {
            Write-Host "`nJSON Report: $($Result.JSONPath)" -ForegroundColor Gray
        }

        if ($Result.HTMLPath) {
            Write-Host "HTML Report: $($Result.HTMLPath)" -ForegroundColor Gray
        }

        Write-Host ""
    }
}

<#
.SYNOPSIS
    Compares Lighthouse results from multiple audits.

.DESCRIPTION
    Takes multiple Lighthouse result objects and displays a comparison table
    showing how scores differ across URLs or test runs.

.PARAMETER Results
    Array of Lighthouse result objects to compare.

.EXAMPLE
    $local = Invoke-LighthouseAudit -URL 'http://localhost:4000'
    $prod = Invoke-LighthouseAudit -URL 'https://example.com'
    Compare-LighthouseResults -Results @($local, $prod)

.EXAMPLE
    $results = @('url1', 'url2', 'url3') | ForEach-Object { Invoke-LighthouseAudit -URL $_ }
    Compare-LighthouseResults -Results $results
#>
function Compare-LighthouseResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$Results
    )

    if ($Results.Count -lt 2) {
        Write-Warning "Need at least 2 results to compare"
        return
    }

    Write-Host "`nLighthouse Comparison" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Gray

    # Create comparison table
    $comparisonData = foreach ($result in $Results) {
        [PSCustomObject]@{
            URL            = $result.URL
            Device         = $result.Device
            Performance    = [math]::Round($result.Categories.performance.score * 100)
            Accessibility  = [math]::Round($result.Categories.accessibility.score * 100)
            BestPractices  = [math]::Round($result.Categories.'best-practices'.score * 100)
            SEO            = [math]::Round($result.Categories.seo.score * 100)
            Timestamp      = $result.Timestamp
        }
    }

    $comparisonData | Format-Table -AutoSize

    Write-Host ""
}

<#
.SYNOPSIS
    Gets a summary object of Lighthouse scores.

.DESCRIPTION
    Extracts just the scores from a Lighthouse result as a simple object,
    useful for logging or storing in databases.

.PARAMETER Result
    The result object from Invoke-LighthouseAudit.

.EXAMPLE
    $result = Invoke-LighthouseAudit -URL 'https://example.com'
    $scores = Get-LighthouseScores -Result $result
    $scores | Export-Csv scores.csv -Append
#>
function Get-LighthouseScores {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Result
    )

    process {
        [PSCustomObject]@{
            URL           = $Result.URL
            Device        = $Result.Device
            Timestamp     = $Result.Timestamp
            Performance   = [math]::Round($Result.Categories.performance.score * 100)
            Accessibility = [math]::Round($Result.Categories.accessibility.score * 100)
            BestPractices = [math]::Round($Result.Categories.'best-practices'.score * 100)
            SEO           = [math]::Round($Result.Categories.seo.score * 100)
        }
    }
}

#endregion

# Export public functions
Export-ModuleMember -Function @(
    'Invoke-LighthouseAudit',
    'Show-LighthouseResults',
    'Compare-LighthouseResults',
    'Get-LighthouseScores'
)