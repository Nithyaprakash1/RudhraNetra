$htmlFiles = Get-ChildItem -Filter *.html

# New active footer script to use 'active-page' class
$footerScript = @'
    <script id="active-footer-script">
        document.addEventListener("DOMContentLoaded", function() {
            const footerLinks = document.querySelectorAll("footer a");
            let currentPath = window.location.pathname.split("/").pop();
            if(!currentPath || currentPath === "") currentPath = "index.html";
            footerLinks.forEach(link => {
                const href = link.getAttribute("href");
                if(href && href.split("#")[0] === currentPath) {
                    // Apply active-page class exactly like contact.html originally had
                    link.classList.add("active-page");
                    // Remove standard nav-link classes to avoid conflicts
                    link.classList.remove("text-[#FFF1E0]", "hover:text-[#8B4513]", "hover:text-[#8E5936]");
                    link.style = ""; // Clear previously injected styles
                }
            });
        });
    </script>
</body>
'@

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # 1. Update the JS Script for Active Footer
    if ($content -match 'id="active-footer-script"') {
        $content = $content -replace '(?s)<script id="active-footer-script">.*?</script>\s*</body>', $footerScript
    }

    # 2. Remove conflicting legacy CSS for .product-drawer and .enhanced-dropdown-item
    $content = $content -replace '(?s)/\* ── Product Dropdown Drawer ── \*/.*?\.group:hover \.product-drawer \{.*?\}', ''
    $content = $content -replace '(?s)/\* ── Enhanced dropdown items ── \*/.*?\.enhanced-dropdown-item span \{.*?\}', ''
    $content = $content -replace '(?s)/\* \?\? Product Dropdown Drawer \?\? \*/.*?\.group:hover \.product-drawer \{.*?\}', ''
    $content = $content -replace '(?s)/\* \?\? Enhanced dropdown items \?\? \*/.*?\.enhanced-dropdown-item span \{.*?\}', ''

    Set-Content $file.FullName $content
}

Write-Host "Global UI updates applied"
