$files = Get-ChildItem -Filter *.html
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # 1. Add script tag right before </body> if not already there
    if ($content -notmatch '<script src="cart-anim.js"></script>') {
        $content = $content -replace '</body>', "<script src=`"cart-anim.js`"></script>`n</body>"
    }

    # 2. In product-details.html, fix the buttons
    if ($file.Name -eq 'product-details.html') {
        # Remove heart animation from Buy Now
        $content = $content -replace 'onclick="showHeartAnimation\(event\)" ', ''
        
        # Add addToCart to Add to Cart
        $oldCartBtn = '<button class="w-full py-4 bg-transparent border-2 border-\[#8B4513\] text-\[#8B4513\] hover:bg-\[#8B4513\] hover:text-\[#FFF1E0\] font-semibold text-xs tracking-widest uppercase transition sharp-edge">'
        $newCartBtn = '<button onclick="addToCart(''Karungali Malai'', 1200, ''https://placehold.co/600x600/8B4513/FFF1E0?text=Karungali+Malai'', parseInt(document.getElementById(''quantityVal'').value) || 1)" class="w-full py-4 bg-transparent border-2 border-[#8B4513] text-[#8B4513] hover:bg-[#8B4513] hover:text-[#FFF1E0] font-semibold text-xs tracking-widest uppercase transition sharp-edge">'
        $content = $content -replace $oldCartBtn, $newCartBtn
        
        # Also remove the heart DOM element if it exists in HTML
        # The user image showed a floating heart, maybe there's an img tag or emoji?
        # I checked earlier and found no "heart" text except in classes like "heart-btn".
        # Let's also remove the function showHeartAnimation block.
        $content = $content -replace '(?s)function showHeartAnimation\(e\)\s*\{.*?\}(?=\s*function|\s*</script>)', ''
    }

    # 3. Remove old cart logic in index.html and combo.html to prevent duplicate execution
    if ($file.Name -eq 'index.html' -or $file.Name -eq 'combo.html') {
        # Just wipe out the function updateNavCartCount block
        $content = $content -replace '(?s)function updateNavCartCount\(\)\s*\{.*?\}(?=\s*function|\s*window|\s*let)', ''
        # And wipe out addToCart block
        $content = $content -replace '(?s)function addToCart\(.*?\)\s*\{.*?\}(?=\s*window|\s*function|\s*let)', ''
        # And remove the duplicate window.addEventListener('load', updateNavCartCount);
        $content = $content -replace 'window.addEventListener\(''load'', updateNavCartCount\);', ''
    }

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
