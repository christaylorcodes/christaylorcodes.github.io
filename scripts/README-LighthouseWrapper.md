# LighthouseWrapper PowerShell Module

A simple, reusable PowerShell module for running Lighthouse audits and processing results.

## Installation

```powershell
# Import the module
Import-Module .\scripts\LighthouseWrapper.psd1
```

## Prerequisites

- **Lighthouse CLI**: `npm install -g lighthouse`
- **Chrome or Edge**: Must be installed on the system
- **PowerShell**: 5.1 or higher

## Quick Start

### Basic Usage

```powershell
# Simple audit
$result = Invoke-LighthouseAudit -URL 'https://example.com'
Show-LighthouseResults -Result $result
```

### Save Reports

```powershell
# Generate JSON and HTML reports
$result = Invoke-LighthouseAudit `
    -URL 'https://example.com' `
    -OutputPath 'benchmarks/my-audit' `
    -HTMLReport `
    -OpenReport
```

### Mobile Testing

```powershell
# Mobile device preset
$result = Invoke-LighthouseAudit -URL 'https://example.com' -Device mobile
```

### Compare Results

```powershell
# Compare local vs production
$local = Invoke-LighthouseAudit -URL 'http://localhost:4000'
$prod = Invoke-LighthouseAudit -URL 'https://example.com'

Compare-LighthouseResults -Results @($local, $prod)
```

### Export to CSV

```powershell
# Audit multiple URLs and export scores
$urls = @('url1', 'url2', 'url3')
$results = $urls | ForEach-Object { Invoke-LighthouseAudit -URL $_ }
$results | Get-LighthouseScores | Export-Csv 'scores.csv'
```

## Available Functions

### `Invoke-LighthouseAudit`

Runs a Lighthouse audit on a URL.

**Parameters:**
- `URL` (required) - URL to audit
- `Device` - 'desktop' or 'mobile' (default: desktop)
- `OutputPath` - Path to save JSON report (optional)
- `HTMLReport` - Generate HTML report
- `OpenReport` - Open HTML report in browser
- `Categories` - Categories to audit (default: all)

**Returns:** PSCustomObject with audit results

### `Show-LighthouseResults`

Displays formatted audit results in the console.

**Parameters:**
- `Result` (required) - Result object from Invoke-LighthouseAudit
- `ShowMetrics` - Include Core Web Vitals

### `Compare-LighthouseResults`

Compares multiple audit results side-by-side.

**Parameters:**
- `Results` (required) - Array of result objects

### `Get-LighthouseScores`

Extracts scores as a simple object for export/logging.

**Parameters:**
- `Result` (required) - Result object from Invoke-LighthouseAudit

**Returns:** PSCustomObject with score percentages

## Testing

Run the test script to validate functionality:

```powershell
.\scripts\Test-Lighthouse.ps1 -URL 'http://localhost:4000' -Verbose
```

## Examples

See `scripts/examples/lighthouse-usage-examples.ps1` for comprehensive usage examples.

## Troubleshooting

### "No Chrome or Edge installation found"
- Install Google Chrome or Microsoft Edge
- Ensure it's in the default installation path

### "Lighthouse failed with exit code 1"
- Verify Lighthouse CLI is installed: `lighthouse --version`
- Check the URL is accessible
- Run with `-Verbose` to see detailed output

### Local server audits fail
- Ensure Jekyll server is running: `.\build.ps1`
- Verify server is at http://localhost:4000
- Check firewall isn't blocking localhost connections

## Module Structure

```
scripts/
├── LighthouseWrapper.psm1      # Main module file
├── LighthouseWrapper.psd1      # Module manifest
├── Test-Lighthouse.ps1         # Test script
├── examples/
│   └── lighthouse-usage-examples.ps1
└── README-LighthouseWrapper.md # This file
```

## Version History

- **1.0.0** (2025-11-24) - Initial release
  - Core audit functionality
  - Result formatting and comparison
  - Score extraction and export
