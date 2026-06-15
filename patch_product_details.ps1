$htmlFile = "product-details.html"
$content = Get-Content $htmlFile -Raw

$dynamicScript = @'
<script src="products.js"></script>
<script>
    window.changeProductImage = function(btn, src) {
        document.getElementById('mainProductImg').src = src;
        const thumbs = document.querySelectorAll('.thumbnail-btn');
        if (thumbs.length > 0) {
            thumbs.forEach(b => {
                b.classList.remove('border-2', 'border-[#8B4513]');
                b.classList.add('border', 'border-[#8B4513]/20');
            });
            btn.classList.remove('border', 'border-[#8B4513]/20');
            btn.classList.add('border-2', 'border-[#8B4513]');
        }
    };

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const productId = urlParams.get('id');
        let product = masterProducts[7] || masterProducts[0]; // default to "Classic Karungali Bracelet 20 & 27 beads" if no ID
        if (productId) {
            const found = masterProducts.find(p => p.id == parseInt(productId));
            if (found) product = found;
        }
        
        document.title = product.name + ' | Rudra Nethra';
        const h1s = document.querySelectorAll('h1');
        if(h1s.length > 0) h1s[0].textContent = product.name;
        
        const priceEl = document.getElementById('product-price');
        if(priceEl) priceEl.innerHTML = '&#8377;' + product.price;
        
        const oldPriceEl = priceEl.nextElementSibling;
        if(oldPriceEl && oldPriceEl.tagName === 'SPAN') {
            oldPriceEl.innerHTML = '&#8377;' + Math.round(product.price * 1.15); 
        }
        
        const tds = document.querySelectorAll('td.p-4.text-\\[\\#8B4513\\]');
        if(tds.length > 0) tds[0].textContent = product.name;
        
        const mainImg = document.getElementById('mainProductImg');
        const thumbsContainer = document.querySelector('.grid.grid-cols-4.gap-4');
        
        if (product.images && product.images.length > 0) {
            mainImg.src = product.images[0];
            mainImg.alt = product.name;
            
            if (thumbsContainer) {
                thumbsContainer.innerHTML = '';
                for (let i = 0; i < product.images.length && i < 5; i++) {
                    const img = product.images[i];
                    const activeClass = i === 0 ? 'border-2 border-[#8B4513]' : 'border border-[#8B4513]/20';
                    const btnHtml = `
                        <button onclick="changeProductImage(this, '${img.replace(/'/g, "\\'")}')" class="thumbnail-btn ${activeClass} p-1 bg-white/40 sharp-edge focus:outline-none">
                            <img src="${img}" class="w-full h-20 object-cover" alt="Thumbnail ${i+1}">
                        </button>
                    `;
                    thumbsContainer.innerHTML += btnHtml;
                }
            }
        } else {
            const fallback = `https://placehold.co/600x600/8B4513/FFF1E0?text=${product.name.replace(/ /g, '+')}`;
            mainImg.src = fallback;
            if(thumbsContainer) thumbsContainer.innerHTML = '';
        }
    });
</script>
'@

# Inject right before </body>
$content = $content -replace '(?i)</body>', "$dynamicScript`n</body>"

Set-Content $htmlFile $content
