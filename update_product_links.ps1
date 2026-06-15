$htmlFiles = Get-ChildItem -Filter *.html

$newDrawer = @'
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
                              <a href="product.html" class="px-6 py-4 hover:bg-[#8B4513]/5 transition flex items-center justify-between text-[#8B4513] text-[13px] font-bold uppercase tracking-widest">
                                  <span>KARUNGALI NECKLACE</span>
                                  <svg class="w-3 h-3 opacity-70" viewBox="0 0 24 24" fill="currentColor"><path d="M9 5l7 7-7 7z"></path></svg>
                              </a>
                          </div>
                      </div>
'@

$newFooterProducts = @'
               <div>
                  <h4 class="font-bold tracking-widest uppercase mb-4 text-[#FFF1E0]">Products</h4>
                  <ul class="space-y-2 text-sm">
                      <li><a href="product.html" class="hover:text-[#8B4513] nav-link transition">Karungali Malai</a></li>
                      <li><a href="product.html" class="hover:text-[#8B4513] nav-link transition">Karungali Bracelet</a></li>
                      <li><a href="product.html" class="hover:text-[#8B4513] nav-link transition">Karungali Necklace</a></li>
                  </ul>
              </div>
'@

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # Replace the Drawer
    $drawerRegex = '(?s)<div class="product-drawer.*?</div>\s*</div>\s*</div>'
    if ($content -match $drawerRegex) {
        $content = $content -replace $drawerRegex, $newDrawer
    }

    # Replace the Footer Products column
    $footerRegex = '(?s)<div>\s*<h4 class="font-bold tracking-widest uppercase mb-4 text-\[#FFF1E0\]">Products</h4>\s*<ul class="space-y-2 text-sm">.*?</ul>\s*</div>'
    if ($content -match $footerRegex) {
        $content = $content -replace $footerRegex, $newFooterProducts
    }

    Set-Content $file.FullName $content
}
Write-Host "Replaced products in navbar and footer!"
