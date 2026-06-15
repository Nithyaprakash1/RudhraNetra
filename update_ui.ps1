$htmlFiles = Get-ChildItem -Filter *.html

$dropdownReplacement = @'
                    <div class="product-drawer invisible opacity-0 group-hover:visible group-hover:opacity-100 transition-all duration-300 absolute top-full left-0 mt-2 py-2 bg-[#F6EDE2] shadow-xl rounded-2xl w-64 border border-[#8B4513]/10">
                        <div class="flex flex-col">
                            <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest border-b border-[#8B4513]/10">
                                <span>KARUNGALI MALAI</span>
                                <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                            </a>
                            <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest border-b border-[#8B4513]/10">
                                <span>KARUNGALI BRACELET</span>
                                <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                            </a>
                            <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest border-b border-[#8B4513]/10">
                                <span>KARUNGALI NECKLACE</span>
                                <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                            </a>
                            <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest border-b border-[#8B4513]/10">
                                <span>KARUNGALI RING</span>
                                <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                            </a>
                            <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest">
                                <span>KARUNGALI DAMRU BRACELET</span>
                                <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                            </a>
                        </div>
                    </div>
'@

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # 1. Replace dropdown robustly
    $startIdx = $content.IndexOf('<div class="product-drawer')
    if ($startIdx -ge 0) {
        $innerDivClose = $content.IndexOf('</div>', $startIdx)
        if ($innerDivClose -ge 0) {
            $outerDivClose = $content.IndexOf('</div>', $innerDivClose + 6)
            if ($outerDivClose -ge 0) {
                $endIdx = $outerDivClose + 6
                $content = $content.Substring(0, $startIdx) + $dropdownReplacement + $content.Substring($endIdx)
            }
        }
    }

    # 2. Fix Energy text pulse
    $content = $content -replace ' animate-\[pulse_3s_ease-in-out_infinite\]', ''

    # 3. Fix Energy text in combo.html
    if ($file.Name -eq "combo.html") {
        $content = $content -replace 'Awaken The Energy Within', 'Awaken The <span class="gold-energy-glow">Energy</span> Within'
        if (-not ($content -match '\.gold-energy-glow')) {
            $css = @'
        /* Gold Energy Glow & Shimmer */
        .gold-energy-glow {
            color: #FFE1A8;
            font-weight: 700;
            display: inline-block;
            position: relative;
            background: linear-gradient(
                120deg, 
                #FFE1A8 0%, 
                #FFF8E7 25%, 
                #FFE1A8 50%, 
                #D4A373 75%, 
                #FFE1A8 100%
            );
            background-size: 200% auto;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: gold-shimmer-glow 6s linear infinite;
            text-shadow: 0 0 15px rgba(255, 225, 168, 0.25);
        }
        @keyframes gold-shimmer-glow {
            0% {
                background-position: 0% center;
                filter: drop-shadow(0 0 2px rgba(255, 225, 168, 0.25));
            }
            50% {
                background-position: 100% center;
                filter: drop-shadow(0 0 8px rgba(255, 225, 168, 0.45));
            }
            100% {
                background-position: 0% center;
                filter: drop-shadow(0 0 2px rgba(255, 225, 168, 0.25));
            }
        }
</style>
'@
            $content = $content -replace '</style>', $css
        }
    }

    # 4. Set Active Footer Links via JS script
    if (-not ($content -match 'id="active-footer-script"')) {
        $script = @'
    <script id="active-footer-script">
        document.addEventListener("DOMContentLoaded", function() {
            const footerLinks = document.querySelectorAll("footer a");
            let currentPath = window.location.pathname.split("/").pop();
            if(!currentPath || currentPath === "") currentPath = "index.html";
            footerLinks.forEach(link => {
                const href = link.getAttribute("href");
                if(href && href.split("#")[0] === currentPath) {
                    link.style.color = "#8E5936";
                    link.style.fontWeight = "bold";
                    link.style.textShadow = "0 0 12px rgba(142,89,54,0.6)";
                }
            });
        });
    </script>
</body>
'@
        $content = $content -replace '</body>', $script
    }

    Set-Content $file.FullName $content
}
Write-Host "Done updating UI"
