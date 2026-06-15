$htmlFile = "product-details.html"
$content = Get-Content $htmlFile -Raw

$replacement = @"
        const priceEl = document.getElementById('product-price');
        if(priceEl) priceEl.innerHTML = '&#8377;' + product.price;
        
        const oldPriceEl = priceEl.nextElementSibling;
        if(oldPriceEl && oldPriceEl.tagName === 'SPAN') {
            oldPriceEl.innerHTML = '&#8377;' + product.oldPrice; 
            const discountEl = oldPriceEl.nextElementSibling;
            if (discountEl && discountEl.tagName === 'SPAN') {
                const oldP = product.oldPrice;
                const newP = product.price;
                if (oldP > newP) {
                    const discount = Math.round(((oldP - newP) / oldP) * 100);
                    discountEl.innerHTML = discount + '% OFF';
                    discountEl.style.display = 'inline-block';
                    oldPriceEl.style.display = 'inline-block';
                } else {
                    // Hide if there is no discount (e.g., price increased)
                    discountEl.style.display = 'none';
                    oldPriceEl.style.display = 'none';
                }
            }
        }
"@

$target = @"
        const priceEl = document.getElementById('product-price');
        if(priceEl) priceEl.innerHTML = '&#8377;' + product.price;
        
        const oldPriceEl = priceEl.nextElementSibling;
        if(oldPriceEl && oldPriceEl.tagName === 'SPAN') {
            oldPriceEl.innerHTML = '&#8377;' + Math.round(product.price * 1.15); 
        }
"@

$content = $content.Replace($target, $replacement)

Set-Content $htmlFile $content
