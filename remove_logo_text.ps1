$files = Get-ChildItem -Filter *.html
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # Remove the RUDRA NETHRA text next to the logo in the navbar
    $pattern = '(?s)<span class="hidden md:inline-block[^>]*>RUDRA NETHRA</span>'
    $content = $content -replace $pattern, ''

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
