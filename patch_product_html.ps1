$htmlFile = "product.html"
$content = Get-Content $htmlFile -Raw

# 1. Add <script src="products.js"></script> and remove hardcoded masterProducts
$content = $content -replace '(?s)const masterProducts = \[.*?\];', ''
$content = $content -replace '<script>', '<script src="products.js"></script>' + "`n    <script>"

# 2. Update renderProducts function template literals
$oldTemplate = '(?s)<div onclick="window\.location\.href=''product-details\.html''" class="sharp-card cursor-pointer group bg-white/40 border border-\[#8B4513\]/10 shadow-lg p-0 flex flex-col justify-between" data-aos="fade-up" data-aos-delay="\$\{\(i % 3\) \* 100\}">.*?</div>'

$newTemplate = @'
                    const imgSrc = (p.images && p.images.length > 0) ? p.images[0] : `https://placehold.co/400x400/8B4513/FFF1E0?text=${p.name.replace(/ /g, '+')}`;
                    grid.innerHTML += `
                    <div onclick="window.location.href='product-details.html?id=${p.id}'" class="sharp-card cursor-pointer group bg-white/40 border border-[#8B4513]/10 shadow-lg p-0 flex flex-col justify-between" data-aos="fade-up" data-aos-delay="${(i % 3) * 100}">
                        <div class="p-4">
                            <img src="${imgSrc}" class="w-full h-80 object-cover rounded-md mb-4" alt="${p.name}">
                        </div>
                        <div class="p-6 pt-0">
                            <span class="text-[10px] uppercase tracking-widest font-bold opacity-60">${p.category}</span>
                            <h3 class="text-xl font-bold mt-1 mb-2 text-[#8B4513]">${p.name}</h3>
                            <p class="text-lg font-extrabold mb-4">&#8377;${p.price}</p>
                            <div class="flex space-x-2">
                                 <button onclick="window.location.href='product-details.html?id=${p.id}'; event.stopPropagation();" class="flex-1 py-3 rounded-none font-medium bg-[#8B4513]/20 text-[#8B4513] hover:bg-[#8B4513]/30 transition text-sm tracking-wide">View Product</button>
                                 <button onclick="addToCart('${p.name.replace(/'/g, "\\'")}', ${p.price}, '${imgSrc}'); event.stopPropagation();" class="px-5 py-3 rounded-none font-medium bg-[#8B4513] text-[#FFF1E0] hover:bg-[#8B4513]/90 transition text-sm flex items-center justify-center" aria-label="Add to Cart">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                                      <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5V6a3.75 3.75 0 1 0-7.5 0v4.5m11.356-1.993l1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 0 1-1.12-1.243l1.264-12A1.125 1.125 0 0 1 5.513 7.5h12.974c.576 0 1.059.435 1.119 1.007ZM8.625 10.5a.375 0 1 1-.75 0 .375 0 0 1 .75 0Zm7.5 0a.375 0 1 1-.75 0 .375 0 0 1 .75 0Z" />
                                    </svg>
                                 </button>
                            </div>
                        </div>
                    </div>
                    `;
'@

$content = $content -replace '(?s)grid\.innerHTML \+= `.*?</div>\s+`;', $newTemplate

Set-Content $htmlFile $content
