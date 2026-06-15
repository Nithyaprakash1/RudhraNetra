$content = Get-Content .\product.html -Raw

$newMasterProducts = @'
        // Seeded Products Data
        const masterProducts = [
            { id: 1, name: "Classic Karungali Malai 54 & 108 beads", category: "malas", price: 1200, isFeatured: true },
            { id: 2, name: "Karungali Malai with Rudraksha 54 & 108 beads", category: "malas", price: 1500, isFeatured: true },
            { id: 3, name: "Polished Black Karungali Malai 54 & 108 beads", category: "malas", price: 1800, isFeatured: false },
            { id: 4, name: "Silver Spaced Karungali Malai 54 & 108 beads", category: "malas", price: 2400, isFeatured: false },
            { id: 5, name: "Copper Karungali Malai 54 & 108 beads", category: "malas", price: 1600, isFeatured: false },
            { id: 6, name: "Red Accent Karungali Malai 54 & 108 beads", category: "malas", price: 1400, isFeatured: false },
            { id: 7, name: "Matte Finish Karungali Malai 54 & 108 beads", category: "malas", price: 1300, isFeatured: false },
            { id: 8, name: "Classic Karungali Bracelet 20 & 27 beads", category: "bracelets", price: 600, isFeatured: true },
            { id: 9, name: "Karungali Bracelet with Rudraksha 20 & 27 beads", category: "bracelets", price: 800, isFeatured: false },
            { id: 10, name: "Polished Black Karungali Bracelet 20 & 27 beads", category: "bracelets", price: 900, isFeatured: false },
            { id: 11, name: "Red Accent Karungali Bracelet 20 & 27 beads", category: "bracelets", price: 700, isFeatured: false },
            { id: 12, name: "Golden Spaced Karungali Bracelet 20 & 27 beads", category: "bracelets", price: 1100, isFeatured: false },
            { id: 13, name: "Matte Finish Karungali Bracelet 20 & 27 beads", category: "bracelets", price: 650, isFeatured: false },
            { id: 14, name: "Karungali Necklace with Karungali Dollar 54 Beads", category: "necklaces", price: 1500, isFeatured: true },
            { id: 15, name: "Karungali Necklace with Murugan Dollar 54 Beads", category: "necklaces", price: 1600, isFeatured: false },
            { id: 16, name: "Karungali Necklace with Shivan Dollar 54 Beads", category: "necklaces", price: 1600, isFeatured: false },
            { id: 17, name: "Karungali Necklace with Thirisul Dollar 54 Beads", category: "necklaces", price: 1550, isFeatured: false },
            { id: 18, name: "Karungali Necklace with OM Vel Dollar 54 Beads", category: "necklaces", price: 1700, isFeatured: false },
            { id: 19, name: "Karungali Necklace with Vel Dollar 54 Beads", category: "necklaces", price: 1650, isFeatured: false },
            { id: 20, name: "Karungali Rudraksha Necklace with Vel Dollar 54 Beads", category: "necklaces", price: 1800, isFeatured: false },
            { id: 21, name: "Karungali Necklace with Rudraksha Dollar 54 Beads", category: "necklaces", price: 1750, isFeatured: false }
        ];
'@

$content = $content -replace '(?s)// Seeded Products Data\s*const masterProducts = \[.*?\];', $newMasterProducts

# Replace category circles
$newCircles = @'
            <div class="flex justify-start md:justify-center items-center space-x-8 md:space-x-12 pb-4 scrollbar-none">
                
                <!-- Circle 1 (All) -->
                <button onclick="setCategoryFilter('all')" class="category-circle-btn flex flex-col items-center group focus:outline-none shrink-0">
                    <div class="w-24 h-24 md:w-28 md:h-28 rounded-full overflow-hidden border-2 border-[#8B4513] p-1 group-hover:scale-105 transition-all duration-300 shadow-md">
                        <img src="https://placehold.co/150x150/8B4513/FFF1E0?text=All" class="w-full h-full object-cover rounded-full" alt="All Category">
                    </div>
                    <span class="text-xs font-bold uppercase tracking-wider mt-3 text-[#8B4513] group-hover:text-[#8B4513] nav-link">All Items</span>
                </button>

                <!-- Circle 2 (Malas) -->
                <button onclick="setCategoryFilter('malas')" class="category-circle-btn flex flex-col items-center group focus:outline-none shrink-0">
                    <div class="w-24 h-24 md:w-28 md:h-28 rounded-full overflow-hidden border-2 border-transparent p-1 group-hover:border-[#8B4513] group-hover:scale-105 transition-all duration-300 shadow-md">
                        <img src="https://placehold.co/150x150/8B4513/FFF1E0?text=Malas" class="w-full h-full object-cover rounded-full" alt="Malas Category">
                    </div>
                    <span class="text-xs font-bold uppercase tracking-wider mt-3 text-[#8B4513]/70 group-hover:text-[#8B4513] nav-link">Mala Beads</span>
                </button>

                <!-- Circle 3 (Bracelets) -->
                <button onclick="setCategoryFilter('bracelets')" class="category-circle-btn flex flex-col items-center group focus:outline-none shrink-0">
                    <div class="w-24 h-24 md:w-28 md:h-28 rounded-full overflow-hidden border-2 border-transparent p-1 group-hover:border-[#8B4513] group-hover:scale-105 transition-all duration-300 shadow-md">
                        <img src="https://placehold.co/150x150/8B4513/FFF1E0?text=Bracelets" class="w-full h-full object-cover rounded-full" alt="Bracelets Category">
                    </div>
                    <span class="text-xs font-bold uppercase tracking-wider mt-3 text-[#8B4513]/70 group-hover:text-[#8B4513] nav-link">Bracelets</span>
                </button>

                <!-- Circle 4 (Necklaces) -->
                <button onclick="setCategoryFilter('necklaces')" class="category-circle-btn flex flex-col items-center group focus:outline-none shrink-0">
                    <div class="w-24 h-24 md:w-28 md:h-28 rounded-full overflow-hidden border-2 border-transparent p-1 group-hover:border-[#8B4513] group-hover:scale-105 transition-all duration-300 shadow-md">
                        <img src="https://placehold.co/150x150/8B4513/FFF1E0?text=Necklaces" class="w-full h-full object-cover rounded-full" alt="Necklaces Category">
                    </div>
                    <span class="text-xs font-bold uppercase tracking-wider mt-3 text-[#8B4513]/70 group-hover:text-[#8B4513] nav-link">Necklaces</span>
                </button>

            </div>
'@
$content = $content -replace '(?s)<div class="flex justify-start md:justify-center items-center space-x-8 md:space-x-12 pb-4 scrollbar-none">.*?</div>\s*</div>\s*</section>', "$newCircles`n        </div>`n    </section>"

# Replace text filters
$newTabs = @'
            <div class="flex flex-wrap gap-2" id="filterTabs">
                <button onclick="setCategoryFilter('all')" class="tab-btn px-6 py-2.5 bg-[#8B4513] text-[#FFF1E0] text-xs uppercase tracking-wider font-bold transition rounded-full shadow-md">All</button>
                <button onclick="setCategoryFilter('malas')" class="tab-btn px-6 py-2.5 bg-[#8B4513]/10 text-[#8B4513] text-xs uppercase tracking-wider font-semibold hover:bg-[#8B4513]/20 transition rounded-full">Malas</button>
                <button onclick="setCategoryFilter('bracelets')" class="tab-btn px-6 py-2.5 bg-[#8B4513]/10 text-[#8B4513] text-xs uppercase tracking-wider font-semibold hover:bg-[#8B4513]/20 transition rounded-full">Bracelets</button>
                <button onclick="setCategoryFilter('necklaces')" class="tab-btn px-6 py-2.5 bg-[#8B4513]/10 text-[#8B4513] text-xs uppercase tracking-wider font-semibold hover:bg-[#8B4513]/20 transition rounded-full">Necklaces</button>
            </div>
'@
$content = $content -replace '(?s)<div class="flex flex-wrap gap-2" id="filterTabs">.*?</div>', $newTabs


Set-Content .\product.html $content
Write-Host "Products updated"
