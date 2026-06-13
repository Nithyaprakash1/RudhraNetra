$content = Get-Content 'product.html' -Raw
$target = '<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-[#1E110A]/60"></div>
        </div>'
$replacement = @"
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
"@
$newContent = $content.Replace($target, $replacement)
Set-Content 'product.html' $newContent -NoNewline
.\fix_nav.ps1
