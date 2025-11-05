# Analyze image files in the website
Get-ChildItem -Path "c:\_Code\Website\assets\images" -Recurse -File |
    Where-Object { $_.Extension -match '\.(jpg|png|svg|gif|webp)$' } |
    Select-Object @{N='File';E={$_.FullName.Replace('c:\_Code\Website\', '')}},
                  @{N='SizeKB';E={[math]::Round($_.Length/1KB, 2)}},
                  Extension |
    Sort-Object SizeKB -Descending |
    Format-Table -AutoSize
