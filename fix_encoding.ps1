$replacements = [ordered]@{
    "â€œ" = '"'
    "â€\u009d" = '"'
    "â€" = '"'
    "â˜…" = "★"
    "â€”" = "-"
    "â€™" = "'"
    "â‚¹" = "₹"
    "â€¢" = "•"
    "â†’" = "->"
}

$files = Get-ChildItem -Path . -Recurse -Include *.html,*.js
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $modified = $false
    foreach ($key in $replacements.Keys) {
        if ($content.Contains($key)) {
            $content = $content.Replace($key, $replacements[$key])
            $modified = $true
        }
    }
    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Fixed mojibake in $($file.Name)"
    }
}
