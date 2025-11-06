$lines = Get-Content "c:\_Code\Website\README.md"
$lines[37] = ""
$lines[41] = "```"
$lines | Set-Content "c:\_Code\Website\README.md"
Write-Host "Fixed README backticks" -ForegroundColor Green
