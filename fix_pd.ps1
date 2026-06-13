$indexContent = Get-Content 'index.html' -Raw
$productDetailContent = Get-Content 'product-details.html' -Raw

# Standardize navbar
$navRegex = '(?s)<nav.*?</nav>'
$indexNav = [regex]::Match($indexContent, $navRegex).Value
$productDetailContent = [regex]::Replace($productDetailContent, $navRegex, $indexNav)

# Add CTA wording to product-details.html banner
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

if ($productDetailContent -notmatch 'Awaken The Energy Within') {
    $pattern = '(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
    $productDetailContent = [regex]::Replace($productDetailContent, $pattern, "`$1`n" + $ctaHtml)
}

Set-Content 'product-details.html' $productDetailContent -NoNewline
