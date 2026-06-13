$content = Get-Content 'combo.html' -Raw

# 1. We want to remove the first banner. The first banner starts at:
# '<!-- Immersive Pre-Footer Banner with smooth top fade -->'
# and ends right before '</div> <!-- End Main Content Wrapper -->'
$patternToRemove = '(?s)<!-- Immersive Pre-Footer Banner with smooth top fade -->.*?(?=</div> <!-- End Main Content Wrapper -->)'
$content = [regex]::Replace($content, $patternToRemove, "")

# 2. We want to move '</div> <!-- End Main Content Wrapper -->' to AFTER the second banner.
# The second banner starts at '<!-- Immersive Pre-Footer Banner & CTA -->'
# and ends at '</section>' right before '<!-- Footer Area -->'
$patternToMove = '(?s)(</div> <!-- End Main Content Wrapper -->\s*)(<!-- Immersive Pre-Footer Banner & CTA -->.*?</section>\s*)'
$content = [regex]::Replace($content, $patternToMove, "`$2`n`$1")

# 3. Add the CTA wordings to the remaining banner
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

$bannerPattern = '(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
$content = [regex]::Replace($content, $bannerPattern, "`$1`n" + $ctaHtml)

Set-Content 'combo.html' $content -NoNewline
