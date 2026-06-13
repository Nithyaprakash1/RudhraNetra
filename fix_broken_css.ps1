$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    if ($file.Name -ne 'index.html') {
        $content = Get-Content $file.FullName -Raw
        
        # Restore broken CSS rules
        $content = $content -replace '\. \{', '.active-page {'
        $content = $content -replace '\.glass-nav \. \{', '.glass-nav .active-page {'
        
        Set-Content $file.FullName $content -NoNewline
    }
}
