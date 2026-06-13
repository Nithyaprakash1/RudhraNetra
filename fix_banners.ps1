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

        # 1. Remove my previously injected broken banner (it was right before <!-- Footer Area -->)
        $brokenBannerRegex = '(?s)\s*<!-- Immersive Pre-Footer Banner & CTA -->\s*<section class="relative min-h-\[500px\][^>]*>.*?<img src="[^"]*"[^>]*>.*?</section>\s*(?=<!-- Footer Area -->)'
        $content = $content -replace $brokenBannerRegex, "`n`n    "

        # 2. Check if the original banner exists (it contains "Awaken The Energy Within")
        $hasBanner = $content -match 'Awaken The Energy Within'

        if ($hasBanner) {
            # Update the image in the existing banner
            $content = $content -replace '(?s)(<section[^>]*>.*?Awaken The Energy Within.*?<img src=")[^"]*(")', "`${1}$imgUrl`$2"
            
            # Ensure the button links to product.html (some might have index.html#store or products.html)
            $content = $content -replace '(?s)(Awaken The Energy Within.*?<a href=")[^"]*(")', "`${1}product.html`$2"
        } else {
            # Create the full correct banner
            $fullBanner = @"
    <!-- Immersive Pre-Footer Banner & CTA -->
    <section class="relative min-h-[500px] bg-[#1E110A] overflow-hidden flex flex-col justify-center items-center text-center px-6 py-20 z-10">
        <div class="absolute top-0 left-0 right-0 h-28 z-10 pointer-events-none" style="background:linear-gradient(to bottom,#FFF1E0 0%,transparent 100%)"></div>
        <div class="absolute inset-0 z-0">
            <img src="$imgUrl" class="w-full h-full object-cover object-center opacity-40" alt="Immersive Graphic">
            <div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-[#1E110A]/60"></div>
        </div>
        <div class="relative z-10 max-w-3xl mx-auto" data-aos="fade-up">
            <span class="text-xs uppercase tracking-widest font-semibold text-[#FFF1E0]/60 mb-4 block">Elevate Your Sacred Space</span>
            <h2 class="text-5xl md:text-6xl text-[#FFF1E0] mb-6 leading-tight animate-[pulse_3s_ease-in-out_infinite]">Awaken The Energy Within</h2>
            <p class="text-lg text-[#FFF1E0]/80 mb-10 max-w-xl mx-auto">Experience the shielding aura of consecrated Karungali crafted lovingly for your spiritual journey.</p>
            <a href="product.html" class="shining-button inline-block px-10 py-4 bg-[#8B4513] text-[#FFF1E0] rounded-full hover:bg-[#8B4513] transition-all font-medium tracking-wider text-sm shadow-2xl">
                EXPLORE THE COLLECTION
            </a>
        </div>
    </section>
"@
            # Inject it right before "</div> <!-- End Main Content Wrapper -->"
            $content = $content -replace '(?s)(\s*)(</div> <!-- End Main Content Wrapper -->)', "`$1$fullBanner`n`n`$1`$2"
        }

        Set-Content -Path $fileName -Value $content -Encoding UTF8
    }
}
