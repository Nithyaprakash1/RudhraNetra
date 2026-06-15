$content = Get-Content "product-details.html" -Raw

$imgBase = 'image/Product Images (1-11)/Product 9 (Karungali Bracelet with Rudraksha (20  27 Beads))'
$img1 = "$imgBase/Karungali_bracelet_with_Rudraksha_202606111733.jpeg"
$img2 = "$imgBase/Karungali_bracelet_with_Rudraksha_202606111734 (1).jpeg"
$img3 = "$imgBase/Karungali_Bracelet_with_Rudraksha_202606111734.jpeg"
$img4 = "$imgBase/Karungali_bracelet_with_Rudraksha_202606111735.jpeg"
$img5 = "$imgBase/Karungali_bracelet_worn_on_wrist_202606111734.jpeg"

# Main image
$content = $content -replace 'src="https://placehold\.co/600x600/8B4513/FFF1E0\?text=Bracelet\+with\+Rudraksha"', "src=`"$img1`""

# Thumb 1
$content = $content -replace "changeProductImage\(this, 'https://placehold\.co/600x600/8B4513/FFF1E0\?text=Bracelet\+with\+Rudraksha'\)", "changeProductImage(this, '$img1')"
$content = $content -replace 'src="https://placehold\.co/150x150/8B4513/FFF1E0\?text=Beads\+View"', "src=`"$img1`""

# Thumb 2
$content = $content -replace "changeProductImage\(this, 'https://placehold\.co/600x600/8B4513/FFF1E0\?text=Bracelet\+Angle\+2'\)", "changeProductImage(this, '$img2')"
$content = $content -replace 'src="https://placehold\.co/150x150/8B4513/FFF1E0\?text=Angle\+2"', "src=`"$img2`""

# Thumb 3
$content = $content -replace "changeProductImage\(this, 'https://placehold\.co/600x600/8B4513/FFF1E0\?text=Bracelet\+Aura'\)", "changeProductImage(this, '$img3')"
$content = $content -replace 'src="https://placehold\.co/150x150/8B4513/FFF1E0\?text=Aura\+Shot"', "src=`"$img3`""

# Thumb 4
$content = $content -replace "changeProductImage\(this, 'https://placehold\.co/600x600/8B4513/FFF1E0\?text=Detailed\+Beads'\)", "changeProductImage(this, '$img4')"
$content = $content -replace 'src="https://placehold\.co/150x150/8B4513/FFF1E0\?text=Detail\+Zoom"', "src=`"$img4`""

Set-Content "product-details.html" $content
Write-Host "Updated product-details.html"
