$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Replace all variations of Karungali malai to product.html
    $newContent = $content -replace '<a href="[^"]*"([^>]*)>Karungali [mM]alai</a>', '<a href="product.html"$1>Karungali malai</a>'
    
    # Replace all variations of Karungali Bracelet to product-details.html
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Karungali Bracelet</a>', '<a href="product-details.html"$1>Karungali Bracelet</a>'
    
    # Replace all variations of Karungali Necklace to product.html
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Karungali Necklace</a>', '<a href="product.html"$1>Karungali Necklace</a>'
    
    # Replace all variations of Karungali Ring to product.html
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Karungali Ring</a>', '<a href="product.html"$1>Karungali Ring</a>'
    
    # Replace all variations of Karungali Damru Bracelet to product.html
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Karungali Damru Bracelet</a>', '<a href="product.html"$1>Karungali Damru Bracelet</a>'

    if ($newContent -cne $content) {
        [IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Updated $($file.Name)"
    }
}
