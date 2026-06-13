$htmlFiles = Get-ChildItem -Path "c:\Users\ELCOT\Downloads\RudhraNetra-main (1)\RudhraNetra-main" -Filter "*.html"

$cssToInject = @"
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

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # 1. Inject CSS right before </style>
    if ($content -notmatch "\/\* Dynamic Navbar Colors \*\/") {
        $content = $content -replace "</style>", "$cssToInject`n    </style>"
    }

    # 2. Update Nav Links Container (remove text-[#FFF1E0], add nav-links)
    $content = $content -replace "text-\[\#FFF1E0\](.*?>\s*<a)", "nav-links`$1"
    
    # Update individual nav links to have nav-link class (except those with product-drawer inside maybe? actually all a tags inside nav-links)
    $content = $content -replace "hover:text-\[\#8B4513\]", "hover:text-[#8B4513] nav-link"
    $content = $content -replace "hover:text-\[\#5c3a23\]", "hover:text-[#5c3a23] nav-link"

    # 3. Update Cart Icon (remove text-[#8B4513], add nav-cart)
    $content = $content -replace 'class="text-\[\#8B4513\] hover:text-\[\#8B4513\] transition relative" aria-label="Cart"', 'class="nav-cart transition relative" aria-label="Cart"'
    
    # 4. Update Shop Now Button (remove bg-[#8B4513] text-[#FFF1E0] hover:bg-[#8B4513], add nav-shop-btn)
    $content = $content -replace 'bg-\[\#8B4513\] text-\[\#FFF1E0\] rounded-full text-xs md:text-sm hover:bg-\[\#8B4513\]', 'rounded-full text-xs md:text-sm nav-shop-btn'
    $content = $content -replace 'bg-\[\#8B4513\] text-\[\#FFF2E2\] rounded-full text-sm hover:bg-\[\#5c3a23\]', 'rounded-full text-sm nav-shop-btn'
    
    # 5. Update Mobile Menu Button (remove text-[#8B4513] hover:text-[#8B4513], add nav-mobile-btn)
    $content = $content -replace 'class="md:hidden text-\[\#8B4513\] hover:text-\[\#8B4513\]', 'class="md:hidden nav-mobile-btn'

    # Save
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Output "Updated navbar colors across all HTML files."
