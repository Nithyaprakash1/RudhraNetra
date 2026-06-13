$files = Get-ChildItem -Filter *.html

$ctaHtml = @"
        <div class="relative z-10 max-w-3xl mx-auto mt-8" data-aos="fade-up">
            <span class="text-xs uppercase tracking-widest font-semibold text-[#FFF1E0]/60 mb-4 block">Elevate Your Sacred Space</span>
            <h2 class="text-5xl md:text-6xl text-[#FFF1E0] mb-6 leading-tight animate-[pulse_3s_ease-in-out_infinite]">Awaken The Energy Within</h2>
            <p class="text-lg text-[#FFF1E0]/80 mb-10 max-w-xl mx-auto">Experience the shielding aura of consecrated Karungali crafted lovingly for your spiritual journey.</p>
            <a href="product.html" class="shining-button inline-block px-10 py-4 bg-[#8B4513] text-[#FFF1E0] rounded-full hover:bg-[#8B4513] transition-all font-medium tracking-wider text-sm shadow-2xl">
                EXPLORE THE COLLECTION
            </a>
        </div>
"@

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Fix duplicate nav-links
    while ($content -match 'nav-link nav-link') {
        $content = $content -replace 'nav-link nav-link', 'nav-link'
    }

    # Fix cart button class
    $content = $content -replace 'class="text-\[#8B4513\] hover:text-\[#8B4513\]([^"]*)transition relative"', 'class="nav-cart transition relative"'

    if ($content -match 'id="dynamic-nav-styles"') {
        if ($content -notmatch '\.transparent-nav \.nav-cart') {
            $styleAddition = @"
        .transparent-nav .nav-link { color: #FFF1E0 !important; }
        .transparent-nav .nav-cart { color: #FFF1E0 !important; }
        .transparent-nav .nav-mobile-btn { color: #FFF1E0 !important; }
        .glass-nav .nav-link { color: #8B4513 !important; }
        .glass-nav .nav-cart { color: #8B4513 !important; }
        .glass-nav .nav-mobile-btn { color: #8B4513 !important; }
"@
            $content = $content -replace '\.transparent-nav \.nav-link \{ color: #FFF1E0 !important; \}', ''
            $content = $content -replace '\.glass-nav \.nav-link \{ color: #8B4513 !important; \}', $styleAddition
        }
    }

    if ($file.Name -eq 'product.html') {
        if ($content -notmatch 'Awaken The Energy Within') {
            $pattern = '(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
            $content = [regex]::Replace($content, $pattern, "`$1`n" + $ctaHtml)
        }
    }

    if ($file.Name -eq 'combo.html') {
        $bannerStart = '<!-- Immersive Pre-Footer Banner & CTA -->'
        $bannerEnd = '</section>'
        
        $blocks = $content -split [regex]::Escape($bannerStart)
        if ($blocks.Count -gt 2) {
            $content = $blocks[0] + $bannerStart + $blocks[2]
        }
        
        $content = $content -replace 'For combo page.jpeg', 'combo-new.jpg'
        
        if ($content -notmatch 'Awaken The Energy Within') {
            $pattern = '(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
            $content = [regex]::Replace($content, $pattern, "`$1`n" + $ctaHtml)
        }
    }

    if ($file.Name -eq 'product-details.html') {
        $bannerStart = '<!-- Immersive Pre-Footer Banner & CTA -->'
        
        $blocks = $content -split [regex]::Escape($bannerStart)
        if ($blocks.Count -gt 2) {
            $content = $blocks[0] + $bannerStart + $blocks[$blocks.Count - 1]
        }
    }
    
    # Standardize about.html navbar by copying index.html navbar if needed
    
    Set-Content $file.FullName $content -NoNewline
}
