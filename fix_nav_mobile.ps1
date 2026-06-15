$htmlFiles = Get-ChildItem -Filter *.html

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # 1. Normalize Shop Now button (removes hidden class, uses very small mobile sizing)
    $content = $content -replace '<button onclick="window\.location\.href=''product\.html''"[^>]*>\s*Shop\s*Now\s*</button>', '<button onclick="window.location.href=''product.html''" class="shining-button px-2 md:px-6 py-1.5 md:py-2 rounded-full text-[9px] md:text-sm nav-shop-btn transition font-medium whitespace-nowrap">Shop Now</button>'

    # 2. Normalize right container spacing
    $content = $content -replace '<div class="flex items-center space-x-[\d\.]+ md:space-x-6 shrink-0">', '<div class="flex items-center space-x-1.5 md:space-x-6 shrink-0">'

    # 3. Normalize left container spacing and ensure shrink min-w-0 is applied
    $content = $content -replace '<a href="(index\.html|#)" class="flex items-center gap-[\d\.]+ md:gap-3\.5 shrink(?:-0| min-w-0)?">', '<a href="$1" class="flex items-center gap-1 md:gap-3.5 shrink min-w-0">'

    # 4. Tweak logo max width to 110px on mobile
    $content = $content -replace 'max-w-\[150px\]', 'max-w-[110px]'

    # If logo image doesn't have max-w-[110px] because my previous script missed it due to some mismatch, add it.
    # E.g. in combo.html: class="h-8 md:h-12 w-auto object-contain"
    $content = $content -replace 'class="h-[68] md:h-12 w-auto object-contain( shrink min-w-0)?"', 'class="h-6 md:h-12 w-auto max-w-[110px] sm:max-w-none object-contain shrink min-w-0"'

    # 5. Make icons slightly smaller on mobile (w-6 h-6 -> w-5 h-5 md:w-6 md:h-6)
    # only targeting the ones inside nav container
    # Actually, simpler to just target the cart and menu SVG if they are exactly class="w-6 h-6"
    $content = $content -replace 'class="w-6 h-6"', 'class="w-5 h-5 md:w-6 md:h-6"'

    Set-Content $file.FullName $content
}
Write-Host "All navbars normalized for small mobile screens!"
