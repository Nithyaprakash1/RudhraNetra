$htmlFiles = Get-ChildItem -Filter *.html

$footerScript = @'
    <script id="active-footer-script">
        document.addEventListener("DOMContentLoaded", function() {
            const footerLinks = document.querySelectorAll("footer a");
            let currentPath = window.location.pathname.split("/").pop();
            if(!currentPath || currentPath === "") currentPath = "index.html";
            footerLinks.forEach(link => {
                const href = link.getAttribute("href");
                if(href && href.split("#")[0] === currentPath) {
                    link.style.color = "#8B4513";
                    link.style.fontWeight = "bold";
                    link.style.textShadow = "none";
                    link.classList.remove("text-[#FFF1E0]");
                    link.classList.remove("active-page");
                }
            });
        });
    </script>
</body>
'@

$energyCSS = @'
        /* Gold Energy Glow & Shimmer */
        .gold-energy-glow {
            color: #FFE1A8;
            font-weight: 700;
            display: inline-block;
            position: relative;
            background: linear-gradient(
                120deg, 
                #FFE1A8 0%, 
                #FFF8E7 25%, 
                #FFE1A8 50%, 
                #D4A373 75%, 
                #FFE1A8 100%
            );
            background-size: 200% auto;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: gold-shimmer-glow 6s linear infinite;
            text-shadow: 0 0 15px rgba(255, 225, 168, 0.25);
        }
        @keyframes gold-shimmer-glow {
            0% {
                background-position: 0% center;
                filter: drop-shadow(0 0 2px rgba(255, 225, 168, 0.25));
            }
            50% {
                background-position: 100% center;
                filter: drop-shadow(0 0 8px rgba(255, 225, 168, 0.5));
            }
            100% {
                background-position: 200% center;
                filter: drop-shadow(0 0 2px rgba(255, 225, 168, 0.25));
            }
        }
    </style>
'@

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # 1. Update Footer Script
    if ($content -match 'id="active-footer-script"') {
        $content = $content -replace '(?s)<script id="active-footer-script">.*?</script>\s*</body>', $footerScript
    }

    # 2. Add Energy Glow CSS if not present
    if ($content -notmatch '\.gold-energy-glow') {
        $content = $content -replace '</style>', $energyCSS
    }

    # 3. Add Energy Glow HTML
    if ($content -match 'Awaken The Energy Within') {
        $content = $content -replace 'Awaken The Energy Within', 'Awaken The <span class="gold-energy-glow">Energy</span> Within'
    }

    # Also clean up any lingering active-page class from the raw html links in footer
    $content = $content -replace 'active-page', ''

    Set-Content $file.FullName $content
}

Write-Host "Updates completed successfully"
