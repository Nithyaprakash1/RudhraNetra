$files = Get-ChildItem -Path . -Recurse -Include *.html
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $modified = $false
    if ($content.Contains('placeholder="admin@rudhranethra.com"')) {
        $content = $content.Replace('placeholder="admin@rudhranethra.com"', 'placeholder="Enter Email"')
        $modified = $true
    }
    if ($content.Contains('placeholder="••••••••"')) {
        $content = $content.Replace('placeholder="••••••••"', 'placeholder="Enter Password"')
        $modified = $true
    }
    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Removed placeholders in $($file.Name)"
    }
}
