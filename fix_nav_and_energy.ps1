$files = Get-ChildItem -Filter *.html

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $original = $content
    
    if ($content.Contains(".gold-energy-glow {") -and -not $content.Contains("padding-bottom: 0.15em;")) {
        $content = $content.Replace(".gold-energy-glow {`n", ".gold-energy-glow {`n            padding-bottom: 0.15em;`n            margin-bottom: -0.15em;`n")
        $content = $content.Replace(".gold-energy-glow {`r`n", ".gold-energy-glow {`r`n            padding-bottom: 0.15em;`r`n            margin-bottom: -0.15em;`r`n")
    }
    
    if ($f.Name -ne 'index.html') {
        $content = $content.Replace('<a href="#home"', '<a href="index.html"')
        $content = $content.Replace('<a href="#store"', '<a href="product.html"')
    }
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Updated $($f.Name)"
    } else {
        Write-Host "No changes needed for $($f.Name)"
    }
}
Write-Host "Done."
