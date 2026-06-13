$files = Get-ChildItem -Filter *.html

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

foreach ($file in $files) {
    if ($file.Name -ne 'index.html') {
        $content = Get-Content $file.FullName -Raw
        
        # Inject CSS if not present
        if ($content -notmatch '\.product-drawer \{') {
            $content = $content -replace '</style>', "`n$dropdownCss`n</style>"
            Set-Content $file.FullName $content -NoNewline
        }
    }
}
