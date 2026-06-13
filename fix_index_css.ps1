$content = Get-Content 'index.html' -Raw

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
"@

# Since index.html has `.product-drawer` but NOT visibility hidden, let's just append the missing rule.
if ($content -notmatch 'visibility:\s*hidden') {
    # Remove the existing broken or partial product-drawer
    # Actually, simpler: just append the CSS block to the end of <style> so it overrides everything else
    $content = $content -replace '</style>', "`n$dropdownCss`n    </style>"
    Set-Content 'index.html' $content -NoNewline
}
