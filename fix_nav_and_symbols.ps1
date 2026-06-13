$files = @('product-details.html', 'combo.html', 'contact.html', 'product.html', 'cart.html')

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
    
    # Fix broken nav links (only in desktop navbar — hash anchors that don't redirect)
    $content = $content -replace 'href="#home"', 'href="index.html"'
    $content = $content -replace 'href="#store"', 'href="product.html"'
    
    # Fix ? rupee symbols in prices
    $content = $content -replace '\?599', '&#8377;599'
    $content = $content -replace '\?699', '&#8377;699'
    # General pattern for any ?<digits>
    $content = $content -replace '\?(\d+)', '&#8377;$1'
    
    # Fix ????? star symbols
    $content = $content -replace '\?\?\?\?\?', '&#9733;&#9733;&#9733;&#9733;&#9733;'
    
    [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Fixed: $file"
}
Write-Host "All done!"
