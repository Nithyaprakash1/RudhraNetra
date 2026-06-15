$htmlFiles = Get-ChildItem -Filter *.html

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw

    # Fix the missing </div> tag for the product-drawer
    $content = $content -replace '(?s)(<div class="product-drawer[^>]*>.*?</div>)(\s*<a href="combo\.html")', "`$1`n                </div>`$2"

    # Add a max-width to the logo text to prevent it from pushing right side off-screen on mobile
    $content = $content -replace 'class="h-6 md:h-12 w-auto object-contain shrink min-w-0"', 'class="h-6 md:h-12 w-auto max-w-[150px] sm:max-w-none object-contain shrink min-w-0"'

    Set-Content $file.FullName $content
}
Write-Host "Missing div and mobile logo width fixed."
