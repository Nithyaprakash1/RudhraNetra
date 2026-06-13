$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $newContent = $content -replace '<a href="#"([^>]*)>Karungali malai</a>', '<a href="product.html"$1>Karungali malai</a>'
    $newContent = $newContent -replace '<a href="#"([^>]*)>Karungali Bracelet</a>', '<a href="product-details.html"$1>Karungali Bracelet</a>'
    $newContent = $newContent -replace '<a href="#"([^>]*)>Karungali Necklace</a>', '<a href="product.html"$1>Karungali Necklace</a>'
    $newContent = $newContent -replace '<a href="#"([^>]*)>Karungali Ring</a>', '<a href="product.html"$1>Karungali Ring</a>'
    $newContent = $newContent -replace '<a href="#"([^>]*)>Karungali Damru Bracelet</a>', '<a href="product.html"$1>Karungali Damru Bracelet</a>'

    if ($newContent -cne $content) {
        [IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Updated $($file.Name)"
    }
}
