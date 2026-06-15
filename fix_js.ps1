$htmlFiles = Get-ChildItem -Filter *.html
foreach ($f in $htmlFiles) {
    $c = Get-Content $f.FullName -Raw
    $c = $c.Replace('link.classList.remove("");', '')
    Set-Content $f.FullName $c
}
Write-Host "Fixed!"
