$htmlFile = "product-details.html"
$content = Get-Content $htmlFile -Raw

# We want to add IDs to specific elements so JS can update them easily.
# 1. Breadcrumb
$content = $content -replace '<span class="text-xs uppercase tracking-widest font-semibold text-\[\#8B4513\]/60 mb-2 block">Premium Wear / Consecrated Bracelets</span>', '<span id="product-breadcrumb" class="text-xs uppercase tracking-widest font-semibold text-[#8B4513]/60 mb-2 block">Premium Wear / Consecrated Bracelets</span>'

# 2. Description
$content = $content -replace '<p class="text-base text-\[\#8B4513\]/80 italic mb-6">Combining Karungali and Rudraksha for protection and positivity.</p>', '<p id="product-description" class="text-base text-[#8B4513]/80 italic mb-6">Combining Karungali and Rudraksha for protection and positivity.</p>'

# 3. Beads buttons (Option 1 & 2)
# We will give them IDs: beads-btn-1 and beads-btn-2
$content = $content -replace '<button onclick="selectOption\(this, ''beads''\)" class="beads-option-btn px-4 py-8 border-2 border-\[\#8B4513\] bg-\[\#8B4513\] text-\[\#FFF1E0\] text-sm font-semibold tracking-wide uppercase shape-heart focus:outline-none transition w-32 h-24 flex items-center justify-center">`s*<span class="-mt-2">20 Beads</span>`s*</button>', '<button id="beads-btn-1" onclick="selectOption(this, ''beads'')" class="beads-option-btn px-4 py-8 border-2 border-[#8B4513] bg-[#8B4513] text-[#FFF1E0] text-sm font-semibold tracking-wide uppercase shape-heart focus:outline-none transition w-32 h-24 flex items-center justify-center"><span class="-mt-2">20 Beads</span></button>'

$content = $content -replace '<button onclick="selectOption\(this, ''beads''\)" class="beads-option-btn px-4 py-8 border border-\[\#8B4513\]/30 bg-\[\#8B4513\]/20 hover:bg-\[\#8B4513\]/30 text-\[\#8B4513\] text-sm font-semibold tracking-wide uppercase shape-heart focus:outline-none transition w-32 h-24 flex items-center justify-center">`s*<span class="-mt-2">27 Beads</span>`s*</button>', '<button id="beads-btn-2" onclick="selectOption(this, ''beads'')" class="beads-option-btn px-4 py-8 border border-[#8B4513]/30 bg-[#8B4513]/20 hover:bg-[#8B4513]/30 text-[#8B4513] text-sm font-semibold tracking-wide uppercase shape-heart focus:outline-none transition w-32 h-24 flex items-center justify-center"><span class="-mt-2">27 Beads</span></button>'

# 4. Specifications
$content = $content -replace '<td class="p-4 text-\[\#8B4513\]">Pure Karungali Wood & Natural Rudraksha Beads</td>', '<td id="spec-material" class="p-4 text-[#8B4513]">Pure Karungali Wood & Natural Rudraksha Beads</td>'
$content = $content -replace '<td class="p-4 text-\[\#8B4513\]">54 Beads : 108 Beads</td>', '<td id="spec-beads" class="p-4 text-[#8B4513]">54 Beads : 108 Beads</td>'
$content = $content -replace '<td class="p-4 text-\[\#8B4513\]">Silver Plated Caps</td>', '<td id="spec-finish" class="p-4 text-[#8B4513]">Silver Plated Caps</td>'


Set-Content $htmlFile $content
