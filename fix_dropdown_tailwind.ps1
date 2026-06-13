$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # We will search for the dropdown div
    # <div class="product-drawer absolute top-full left-1/2 -translate-x-1/2 mt-4 p-6 bg-[#FFF1E0] shadow-2xl rounded-2xl w-[600px] border border-[#8B4513]/10">
    # If it doesn't already have invisible, add it.
    
    $targetClass = 'product-drawer absolute'
    $replacementClass = 'product-drawer invisible opacity-0 group-hover:visible group-hover:opacity-100 transition-all duration-500 absolute'
    
    if ($content -notmatch 'opacity-0 group-hover:visible') {
        $content = $content -replace $targetClass, $replacementClass
        Set-Content $file.FullName $content -NoNewline
    }
}
