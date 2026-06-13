$files = @{
    'product.html' = 'Products'
    'product-details.html' = 'Products'
    'combo.html' = 'Combo Offer'
    'about.html' = 'About'
    'contact.html' = 'Contact'
}

foreach ($fileName in $files.Keys) {
    if (Test-Path $fileName) {
        $content = Get-Content $fileName -Raw
        
        # Remove active-page from wherever it is currently
        $content = $content -replace 'active-page', ''
        
        # Find the link corresponding to the current file and add active-page to it.
        # It's an anchor tag like <a href="#store" class="hover:text-[#8B4513] nav-link cursor-pointer nav-text-glow">Products</a>
        $targetText = $files[$fileName]
        $pattern = '(<a[^>]*class="[^"]*)(">\s*' + [regex]::Escape($targetText) + '\s*</a>)'
        
        $content = [regex]::Replace($content, $pattern, '$1 active-page$2')
        
        Set-Content $fileName $content -NoNewline
    }
}
