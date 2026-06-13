$content = Get-Content 'combo.html' -Raw -Encoding UTF8

# Add to Cart hook for Combo 1 (Basic Setup)
$content = $content -replace '<button class="w-full py-3 bg-\[#8B4513\] text-\[#FFF1E0\] font-semibold text-xs tracking-widest uppercase hover:bg-\[#8B4513\] transition sharp-edge">', '<button onclick="addToCart(''Beginner Malai Combo'', 1500, ''https://placehold.co/400x500/8B4513/FFF1E0?text=Combo+1'')" class="w-full py-3 bg-[#8B4513] text-[#FFF1E0] font-semibold text-xs tracking-widest uppercase hover:bg-[#8B4513] transition sharp-edge">'

# Add to Cart hook for Combo 2 (Advanced)
$content = $content -replace '<button class="w-full py-3 bg-\[#8B4513\] text-\[#FFF1E0\] font-semibold text-xs tracking-widest uppercase hover:bg-\[#8B4513\] transition shadow-lg sharp-edge">', '<button onclick="addToCart(''Spiritual Master Combo'', 2500, ''https://placehold.co/400x500/8B4513/FFF1E0?text=Combo+2'')" class="w-full py-3 bg-[#8B4513] text-[#FFF1E0] font-semibold text-xs tracking-widest uppercase hover:bg-[#8B4513] transition shadow-lg sharp-edge">'

# Add to Cart hook for Combo 3 (Ultimate)
$content = $content -replace '<button class="w-full py-3 bg-transparent border-2 border-\[#8B4513\] text-\[#8B4513\] hover:bg-\[#8B4513\] hover:text-\[#FFF1E0\] font-semibold text-xs tracking-widest uppercase transition sharp-edge">', '<button onclick="addToCart(''Ultimate Devotion Bundle'', 4500, ''https://placehold.co/400x500/8B4513/FFF1E0?text=Combo+3'')" class="w-full py-3 bg-transparent border-2 border-[#8B4513] text-[#8B4513] hover:bg-[#8B4513] hover:text-[#FFF1E0] font-semibold text-xs tracking-widest uppercase transition sharp-edge">'

# Add to Cart hook for Custom Bundle
$oldCustom = '<button id="addBundleBtn" disabled class="w-full py-4 mt-8 bg-\[#8B4513\]/35 text-white font-bold tracking-widest uppercase transition cursor-not-allowed sharp-edge">'
$newCustom = '<button id="addBundleBtn" disabled onclick="addToCart(''Custom Bundle'', 0, ''https://placehold.co/400x500/8B4513/FFF1E0?text=Custom+Bundle'')" class="w-full py-4 mt-8 bg-[#8B4513]/35 text-white font-bold tracking-widest uppercase transition cursor-not-allowed sharp-edge">'
$content = $content -replace [regex]::Escape($oldCustom), $newCustom

Set-Content -Path 'combo.html' -Value $content -Encoding UTF8
