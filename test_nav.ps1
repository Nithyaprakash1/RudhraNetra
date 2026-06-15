$file = "index.html"
$content = Get-Content $file -Raw

# 1. Fix empty CSS
$content = $content -replace '(?m)^\s*\.\s*\{', '        .active-nav-link {'
$content = $content -replace '(?m)^\s*\.glass-nav\s*\.\s*\{', '        .glass-nav .active-nav-link {'

# 2. Fix Nav Container
$content = $content -replace 'class="max-w-7xl mx-auto flex justify-between items-center[^"]*"(?:\r?\n\s*)?id="nav-container"', 'class="max-w-7xl w-full mx-auto flex justify-between items-center px-4 md:px-8 py-2 md:py-4 transition-all duration-500 glass-nav" id="nav-container"'

# 3. Fix Logo Container
$content = $content -replace '<a href="([^"]+)" class="flex items-center gap-1\.5 md:gap-3\.5 shrink-0">', '<a href="$1" class="flex items-center gap-1.5 md:gap-3.5 shrink min-w-0">'

# 4. Fix Logo Parts
$content = $content -replace '<img src="image/logo_icon\.png" alt="Rudra Nethra Icon" class="h-8 md:h-14 w-auto">', '<img src="image/logo_icon.png" alt="Rudra Nethra Icon" class="h-8 md:h-14 w-auto shrink-0">'
$content = $content -replace '<span class="w-\[1px\] h-5 md:h-8 bg-\[#8B4513\]/30 block"></span>', '<span class="w-[1px] h-5 md:h-8 bg-[#8B4513]/30 block shrink-0">'
$content = $content -replace '<img src="image/logo_text\.png" alt="Rudra Nethra Text" class="h-6 md:h-12 w-auto object-contain">', '<img src="image/logo_text.png" alt="Rudra Nethra Text" class="h-6 md:h-12 w-auto object-contain shrink min-w-0">'

# 5. Fix Nav Links Wrapping
$content = $content -replace 'class="hidden md:flex items-center space-x-8 font-medium text-sm uppercase tracking-widest nav-links"', 'class="hidden md:flex items-center space-x-4 lg:space-x-8 font-medium text-xs lg:text-sm uppercase tracking-widest nav-links whitespace-nowrap"'

# 6. Hide Shop Now button on mobile
$content = $content -replace 'class="shining-button px-2\.5 md:px-6 py-1\.5 md:py-2 rounded-full text-\[10px\] md:text-sm nav-shop-btn transition font-medium whitespace-nowrap"', 'class="hidden sm:inline-block shining-button px-2.5 md:px-6 py-1.5 md:py-2 rounded-full text-[10px] md:text-sm nav-shop-btn transition font-medium whitespace-nowrap"'

Set-Content $file $content
Write-Host "Tested on index.html"
