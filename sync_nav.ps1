$indexContent = Get-Content 'index.html' -Raw

# Extract the exact <nav> block from index.html
$navRegex = '(?s)<nav\s+id="navbar"([^>]*)>.*?</nav>'
# Let's use a simpler regex for the nav block since we know it starts with <nav class="fixed top-6 left-0 right-0 z-50 px-6 navbar-transition" id="navbar">
$navStartStr = '<nav class="fixed top-6 left-0 right-0 z-50 px-6 navbar-transition" id="navbar">'
$navEndStr = '</nav>'
$navStartIndex = $indexContent.IndexOf($navStartStr)
$navEndIndex = $indexContent.IndexOf($navEndStr, $navStartIndex) + $navEndStr.Length
$indexNav = $indexContent.Substring($navStartIndex, $navEndIndex - $navStartIndex)

# Extract the required CSS blocks from index.html
$dynamicColorsStart = '/* Dynamic Navbar Colors */'
$glassStateEnd = 'text-shadow: 0 0 12px rgba(139, 69, 19, 0.4);' + "`n" + '        }'
$dynamicCssIndex = $indexContent.IndexOf($dynamicColorsStart)
$glassCssEndIndex = $indexContent.IndexOf($glassStateEnd, $dynamicCssIndex) + $glassStateEnd.Length
$dynamicCss = $indexContent.Substring($dynamicCssIndex, $glassCssEndIndex - $dynamicCssIndex)

$dropdownStart = '/* ── Product Dropdown Drawer ── */'
$dropdownEndStr = 'text-shadow: 0 1px 2px rgba(0,0,0,.5);' + "`n" + '        }'
$dropdownStartIndex = $indexContent.IndexOf($dropdownStart)
$dropdownEndIndex = $indexContent.IndexOf($dropdownEndStr, $dropdownStartIndex) + $dropdownEndStr.Length
$dropdownCss = $indexContent.Substring($dropdownStartIndex, $dropdownEndIndex - $dropdownStartIndex)

$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    if ($file.Name -ne 'index.html') {
        $content = Get-Content $file.FullName -Raw
        
        # 1. Replace <nav> ... </nav>
        # We need to find where the old nav starts and ends.
        $oldNavStartIndex = $content.IndexOf('<nav')
        $oldNavEndIndex = $content.IndexOf('</nav>', $oldNavStartIndex) + '</nav>'.Length
        
        if ($oldNavStartIndex -ge 0 -and $oldNavEndIndex -gt $oldNavStartIndex) {
            $content = $content.Remove($oldNavStartIndex, $oldNavEndIndex - $oldNavStartIndex)
            $content = $content.Insert($oldNavStartIndex, $indexNav)
        }
        
        # 2. Ensure dynamic CSS
        if ($content -notmatch 'Dynamic Navbar Colors') {
            $content = $content -replace '</style>', "`n        $dynamicCss`n    </style>"
        }
        
        # 3. Ensure dropdown CSS
        if ($content -notmatch 'Product Dropdown Drawer') {
            $content = $content -replace '</style>', "`n        $dropdownCss`n    </style>"
        }
        
        Set-Content $file.FullName $content -NoNewline
    }
}
