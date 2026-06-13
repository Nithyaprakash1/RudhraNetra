$files = Get-ChildItem -Filter *.html

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Replace Privacy Policy links
    $newContent = $content -replace '<a href="[^"]*"([^>]*)>Privacy Policy</a>', '<a href="privacy-policy.html"$1>Privacy Policy</a>'
    
    # Replace Terms of Service links
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Terms of Service</a>', '<a href="terms-of-service.html"$1>Terms of Service</a>'
    
    # Replace Shipping Policy links
    $newContent = $newContent -replace '<a href="[^"]*"([^>]*)>Shipping Policy</a>', '<a href="shipping-policy.html"$1>Shipping Policy</a>'
    
    if ($newContent -cne $content) {
        [IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Updated $($file.Name)"
    }
}
