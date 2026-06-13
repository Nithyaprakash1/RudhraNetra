$files = Get-ChildItem -Filter *.html
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace 'image/1\.svg', 'image/logo.png'
    if ($content -ne $newContent) {
        Set-Content $file.FullName $newContent -NoNewline
    }
}
