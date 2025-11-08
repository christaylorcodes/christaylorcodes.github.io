# Calculate SHA-256 hash of critical CSS for CSP

# Read the critical CSS file
$content = Get-Content '_includes\critical-css.html' -Raw

# Extract CSS between style tags
$pattern = '(?s)<style>(.*?)</style>'
if ($content -match $pattern) {
    $css = $matches[1]

    # Calculate SHA-256 hash
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($css)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    $base64Hash = [Convert]::ToBase64String($hash)

    # Output results
    Write-Host "`nCritical CSS Hash (SHA-256):" -ForegroundColor Cyan
    Write-Host "sha256-$base64Hash" -ForegroundColor Green
    Write-Host "`nUse this in your CSP header:" -ForegroundColor Cyan
    Write-Host "style-src 'self' 'sha256-$base64Hash' https://fonts.googleapis.com https://cdnjs.cloudflare.com;" -ForegroundColor Yellow
}
