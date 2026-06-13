$indexContent = Get-Content 'index.html' -Raw

$navStartStr = '<nav class="fixed top-6 left-0 right-0 z-50 px-6 navbar-transition" id="navbar">'
$navEndStr = '</nav>'
$navStartIndex = $indexContent.IndexOf($navStartStr)
$navEndIndex = $indexContent.IndexOf($navEndStr, $navStartIndex) + $navEndStr.Length
$indexNav = $indexContent.Substring($navStartIndex, $navEndIndex - $navStartIndex)

$dynamicCss = @"
        /* Dynamic Navbar Colors */
        .nav-links, .nav-cart, .nav-mobile-btn {
            color: #FFF1E0;
            transition: color 0.3s ease;
        }
        .nav-link { transition: color 0.3s ease; }
        .nav-link:hover { color: #8B4513 !important; }
        .nav-shop-btn {
            background-color: transparent !important;
            color: #FFF1E0 !important;
            border: 1px solid #FFF1E0 !important;
            transition: all 0.3s ease;
        }
        .nav-shop-btn:hover {
            background-color: #FFF1E0 !important;
            color: #8B4513 !important;
        }

        /* Glass state */
        .glass-nav .nav-links, .glass-nav .nav-cart, .glass-nav .nav-mobile-btn {
            color: #8B4513 !important;
        }
        .glass-nav .nav-link:hover { color: #5c3a23 !important; }
        .glass-nav .nav-shop-btn {
            background-color: #8B4513 !important;
            color: #FFF1E0 !important;
            border: 1px solid #8B4513 !important;
        }
        .glass-nav .nav-shop-btn:hover {
            background-color: #5c3a23 !important;
            border-color: #5c3a23 !important;
        }
        
        .glass-nav .active-page {
            color: #8B4513 !important;
            text-shadow: 0 0 12px rgba(139, 69, 19, 0.4);
        }
"@

$dropdownCss = @"
        /* ── Product Dropdown Drawer ── */
        .product-drawer {
            visibility: hidden; opacity: 0;
            transform: translateY(10px);
            transition: all 0.4s cubic-bezier(0.175,0.885,0.32,1.275);
            background: linear-gradient(145deg, #FFF1E0, #F3E5D3);
            border: 1px solid rgba(142,89,54,0.18);
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.18);
        }
        .group:hover .product-drawer { visibility: visible; opacity: 1; transform: translateY(0); }

        /* ── Enhanced dropdown items ── */
        .enhanced-dropdown-item {
            display: block; text-align: center; padding: 12px;
            border-radius: 12px;
            background: linear-gradient(135deg,#A8704D,#8E5936);
            border: 2px solid transparent;
            transition: all 0.4s cubic-bezier(0.175,0.885,0.32,1.275);
        }
        .enhanced-dropdown-item:hover {
            transform: scale(1.06) translateY(-5px);
            border-color: #D4A373;
            box-shadow: 0 15px 30px rgba(142,89,54,0.4);
        }
        .enhanced-dropdown-item img { border-radius: 8px; display: block; margin: 0 auto; }
        .enhanced-dropdown-item span {
            color: #FFF2E2 !important;
            display: block; margin-top: 8px;
            font-size: 12px; font-weight: 600;
            letter-spacing: .05em;
            text-shadow: 0 1px 2px rgba(0,0,0,.5);
        }
"@

$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    if ($file.Name -ne 'index.html') {
        $content = Get-Content $file.FullName -Raw
        
        # 1. Replace <nav>
        $oldNavStartIndex = $content.IndexOf('<nav')
        $oldNavEndIndex = $content.IndexOf('</nav>', $oldNavStartIndex) + '</nav>'.Length
        
        if ($oldNavStartIndex -ge 0 -and $oldNavEndIndex -gt $oldNavStartIndex) {
            $content = $content.Remove($oldNavStartIndex, $oldNavEndIndex - $oldNavStartIndex)
            $content = $content.Insert($oldNavStartIndex, $indexNav)
        }
        
        # 2. Add Dynamic Navbar Colors if missing
        if ($content -notmatch 'Dynamic Navbar Colors') {
            $content = $content -replace '</style>', "`n$dynamicCss`n    </style>"
        }
        
        # 3. Add Dropdown CSS if missing
        if ($content -notmatch 'Product Dropdown Drawer') {
            $content = $content -replace '</style>', "`n$dropdownCss`n    </style>"
        }
        
        Set-Content $file.FullName $content -NoNewline
    }
}
