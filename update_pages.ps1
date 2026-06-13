$files = @{
    "about.html" = "image/New images for each pages/For About Page.jpeg"
    "cart.html" = "image/New images for each pages/For Cart Page.jpeg"
    "combo.html" = "image/New images for each pages/For combo page.jpeg"
    "product-details.html" = "image/New images for each pages/For Product Detail page.jpeg"
    "product.html" = "image/New images for each pages/For Product Page.jpeg"
}

foreach ($fileName in $files.Keys) {
    if (Test-Path $fileName) {
        $content = Get-Content $fileName -Raw -Encoding UTF8
        $imgUrl = $files[$fileName]

        # 1. Update Navbar text color
        # Replace the main navbar text container color
        $content = $content -replace 'class="hidden md:flex items-center space-x-8 font-medium text-sm uppercase tracking-widest text-\[#8B4513\]"', 'class="hidden md:flex items-center space-x-8 font-medium text-sm uppercase tracking-widest text-[#FFF1E0]"'
        
        # Replace the active page CSS color
        $content = $content -replace 'color: #8B4513 !important;', 'color: #FFF1E0 !important;'

        # 2. Add or Replace Pre-Footer Banner
        $bannerRegex = '(?s)<!-- Immersive Pre-Footer Banner & CTA -->.*?</section>'
        
        $newBanner = @"
    <!-- Immersive Pre-Footer Banner & CTA -->
    <section class="relative min-h-[500px] bg-[#1E110A] overflow-hidden flex flex-col justify-center items-center text-center px-6 py-20 z-10">
        <div class="absolute top-0 left-0 right-0 h-28 z-10 pointer-events-none" style="background:linear-gradient(to bottom,#FFF1E0 0%,transparent 100%)"></div>
        <div class="absolute inset-0 z-0">
            <img src="$imgUrl" class="w-full h-full object-cover object-center opacity-40" alt="Immersive Graphic">
            <div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-[#1E110A]/60"></div>
        </div>
    </section>
"@

        if ($content -match $bannerRegex) {
            # Replace existing banner entirely to make sure it matches and removes the extra text
            $content = $content -replace $bannerRegex, $newBanner
        } else {
            # Insert banner right before the footer area
            $content = $content -replace '<!-- Footer Area -->', "$newBanner`n`n    <!-- Footer Area -->"
        }

        Set-Content -Path $fileName -Value $content -Encoding UTF8
    }
}

# Also update navbar text color in index.html and contact.html
$otherFiles = @("index.html", "contact.html")
foreach ($fileName in $otherFiles) {
    if (Test-Path $fileName) {
        $content = Get-Content $fileName -Raw -Encoding UTF8
        
        $content = $content -replace 'class="hidden md:flex items-center space-x-8 font-medium text-sm uppercase tracking-widest text-\[#8B4513\]"', 'class="hidden md:flex items-center space-x-8 font-medium text-sm uppercase tracking-widest text-[#FFF1E0]"'
        
        $content = $content -replace 'color: #8B4513 !important;', 'color: #FFF1E0 !important;'

        Set-Content -Path $fileName -Value $content -Encoding UTF8
    }
}
