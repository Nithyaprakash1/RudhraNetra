$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$masterProducts = @(
    @{ id = 1; name = "Classic Karungali Malai 54 & 108 beads"; category = "malas"; price = 749; oldPrice = 1200; isFeatured = $true; images = @() },
    @{ id = 2; name = "Karungali Malai with Rudraksha 54 & 108 beads"; category = "malas"; price = 849; oldPrice = 1500; isFeatured = $true; images = @() },
    @{ id = 3; name = "Polished Black Karungali Malai 54 & 108 beads"; category = "malas"; price = 1800; oldPrice = 1999; isFeatured = $false; images = @() },
    @{ id = 4; name = "Silver Spaced Karungali Malai 54 & 108 beads"; category = "malas"; price = 949; oldPrice = 2400; isFeatured = $false; images = @() },
    @{ id = 5; name = "Copper Karungali Malai 54 & 108 beads"; category = "malas"; price = 1299; oldPrice = 1600; isFeatured = $false; images = @() },
    @{ id = 6; name = "Red Accent Karungali Malai 54 & 108 beads"; category = "malas"; price = 1400; oldPrice = 1999; isFeatured = $false; images = @() },
    @{ id = 7; name = "Matte Finish Karungali Malai 54 & 108 beads"; category = "malas"; price = 849; oldPrice = 1300; isFeatured = $false; images = @() },
    
    @{ id = 8; name = "Classic Karungali Bracelet 20 & 27 beads"; category = "bracelets"; price = 399; oldPrice = 600; isFeatured = $true; images = @() },
    @{ id = 9; name = "Karungali Bracelet with Rudraksha 20 & 27 beads"; category = "bracelets"; price = 599; oldPrice = 800; isFeatured = $false; images = @() },
    @{ id = 10; name = "Polished Black Karungali Bracelet 20 & 27 beads"; category = "bracelets"; price = 499; oldPrice = 900; isFeatured = $false; images = @() },
    @{ id = 11; name = "Red Accent Karungali Bracelet 20 & 27 beads"; category = "bracelets"; price = 599; oldPrice = 700; isFeatured = $false; images = @() },
    @{ id = 12; name = "Golden Spaced Karungali Bracelet 20 & 27 beads"; category = "bracelets"; price = 1100; oldPrice = 1265; isFeatured = $false; images = @() },
    @{ id = 13; name = "Matte Finish Karungali Bracelet 20 & 27 beads"; category = "bracelets"; price = 399; oldPrice = 650; isFeatured = $false; images = @() },
    
    @{ id = 14; name = "Karungali Necklace with Karungali Dollar 54 Beads"; category = "necklaces"; price = 699; oldPrice = 1500; isFeatured = $true; images = @() },
    @{ id = 15; name = "Karungali Necklace with Murugan Dollar 54 Beads"; category = "necklaces"; price = 1149; oldPrice = 1600; isFeatured = $false; images = @() },
    @{ id = 16; name = "Karungali Necklace with Shivan Dollar 54 Beads"; category = "necklaces"; price = 1249; oldPrice = 1600; isFeatured = $false; images = @() },
    @{ id = 17; name = "Karungali Necklace with Thirisul Dollar 54 Beads"; category = "necklaces"; price = 1249; oldPrice = 1550; isFeatured = $false; images = @() },
    @{ id = 18; name = "Karungali Necklace with OM Vel Dollar 54 Beads"; category = "necklaces"; price = 1549; oldPrice = 1700; isFeatured = $false; images = @() },
    @{ id = 19; name = "Karungali Necklace with Vel Dollar 54 Beads"; category = "necklaces"; price = 1249; oldPrice = 1650; isFeatured = $false; images = @() },
    @{ id = 20; name = "Karungali Rudraksha Necklace with Vel Dollar 54 Beads"; category = "necklaces"; price = 1800; oldPrice = 1875; isFeatured = $false; images = @() },
    @{ id = 21; name = "Karungali Necklace with Rudraksha Dollar 54 Beads"; category = "necklaces"; price = 1249; oldPrice = 1750; isFeatured = $false; images = @() }
)

for ($i=1; $i -le 11; $i++) {
    $folder = Get-ChildItem "image\Product Images (1-11)\Product $i *" -Directory | Select-Object -First 1
    if ($folder) {
        $images = Get-ChildItem $folder.FullName -File | Select-Object -ExpandProperty Name
        
        # Sort images so that the "stand" / "display" image comes first
        # We will also add specific names for Product 1 and Product 2 if possible
        $sortedImages = $images | Sort-Object {
            $name = $_.ToLower()
            if ($name -match 'stand|display|pedestal|block') { return 0 }
            elseif ($name -match 'whatsapp.*\(2\)') { return 0 } # guess for Product 1
            elseif ($name -match 'stone') { return 0 } # guess for Product 2
            elseif ($name -match 'produc|whatsapp') { return 1 }
            else { return 2 }
        }

        $imagePaths = @()
        foreach ($img in $sortedImages) {
            $path = "image/Product Images (1-11)/$($folder.Name)/$img"
            $imagePaths += $path
        }
        $masterProducts[$i-1].images = $imagePaths
    }
}

$json = $masterProducts | ConvertTo-Json -Depth 5
$jsContent = "const masterProducts = $json;"

[System.IO.File]::WriteAllText("$(Get-Location)\products.js", $jsContent, [System.Text.Encoding]::UTF8)
