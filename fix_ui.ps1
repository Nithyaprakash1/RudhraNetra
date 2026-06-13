$files = Get-ChildItem -Filter *.html
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # 1. Update the CSS for the navbar
    $oldCssPattern = '(?s)\.nav-text-glow\s*\{.*?\.active-page\s*\{.*?\}.*?</style>'
    
    $newCss = @'
        .nav-text-glow {
            text-shadow: 0 0 8px rgba(139, 69, 19, 0.4);
        }
        .active-page {
            text-shadow: 0 0 12px rgba(139, 69, 19, 0.8);
            color: #8B4513 !important;
            font-weight: 800;
        }
    </style>
'@

    if ($content -match $oldCssPattern) {
        $content = $content -replace $oldCssPattern, $newCss
    }

    # 2. Update filter UI in product.html
    if ($file.Name -eq 'product.html') {
        # Update the initial HTML classes for the tabs
        $content = $content -replace 'class="tab-btn px-5 py-2 bg-\[#8B4513\] text-\[#FFF1E0\] text-xs uppercase tracking-wider font-semibold transition rounded-none"', 'class="tab-btn px-6 py-2.5 bg-[#8B4513] text-[#FFF1E0] text-xs uppercase tracking-wider font-bold transition rounded-full shadow-md"'
        $content = $content -replace 'class="tab-btn px-5 py-2 bg-transparent text-\[#8B4513\] border border-\[#8B4513\]/30 text-xs uppercase tracking-wider font-semibold hover:bg-\[#8B4513\]/10 transition rounded-none"', 'class="tab-btn px-6 py-2.5 bg-[#8B4513]/10 text-[#8B4513] text-xs uppercase tracking-wider font-semibold hover:bg-[#8B4513]/20 transition rounded-full"'
        
        # Also need to update the Javascript function setCategoryFilter inside product.html
        $jsOldActive = 'tab.className = "tab-btn px-5 py-2 bg-\[#8B4513\] text-\[#FFF1E0\] text-xs uppercase tracking-wider font-semibold transition rounded-none";'
        $jsNewActive = 'tab.className = "tab-btn px-6 py-2.5 bg-[#8B4513] text-[#FFF1E0] text-xs uppercase tracking-wider font-bold transition rounded-full shadow-md";'
        $content = $content.Replace($jsOldActive, $jsNewActive)
        
        $jsOldInactive = 'tab.className = "tab-btn px-5 py-2 bg-transparent text-\[#8B4513\] border border-\[#8B4513\]/30 text-xs uppercase tracking-wider font-semibold hover:bg-\[#8B4513\]/10 transition rounded-none";'
        $jsNewInactive = 'tab.className = "tab-btn px-6 py-2.5 bg-[#8B4513]/10 text-[#8B4513] text-xs uppercase tracking-wider font-semibold hover:bg-[#8B4513]/20 transition rounded-full";'
        $content = $content.Replace($jsOldInactive, $jsNewInactive)

        # Update sort selector to match the pill style
        $content = $content -replace 'class="bg-transparent border border-\[#8B4513\]/30 text-xs p-2 text-\[#8B4513\] focus:outline-none rounded-none"', 'class="bg-[#8B4513]/5 border border-[#8B4513]/20 text-xs py-2.5 px-4 text-[#8B4513] font-semibold focus:outline-none rounded-full"'
    }

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
