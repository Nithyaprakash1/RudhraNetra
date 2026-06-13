// Global Cart State and Animation Logic

function updateNavCartCount() {
    let cart = JSON.parse(localStorage.getItem('rudraCart')) || [];
    let totalQty = 0;
    cart.forEach(i => totalQty += i.quantity);
    const countElems = document.querySelectorAll('#navCartCount');
    countElems.forEach(el => {
        el.innerText = totalQty;
        // Small pop animation on the badge
        el.style.transform = 'scale(1.5)';
        el.style.transition = 'transform 0.2s';
        setTimeout(() => el.style.transform = 'scale(1)', 200);
    });
}

// Override any existing addToCart function
window.addToCart = function(name, price, image, qty = 1) {
    const event = window.event;
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }

    // 1. Add to local storage
    let cart = JSON.parse(localStorage.getItem('rudraCart')) || [];
    let existing = cart.find(i => i.name === name);
    if(existing) {
        existing.quantity += qty;
    } else {
        cart.push({ name, price, image, quantity: qty });
    }
    localStorage.setItem('rudraCart', JSON.stringify(cart));

    // 2. Play Flying Animation
    playCartAnimation(event, image, () => {
        // 3. Update Badge at the end of animation
        updateNavCartCount();
    });
}

function playCartAnimation(event, imageUrl, onComplete) {
    if (!event || !event.clientX) {
        // Fallback if no event coordinates
        if(onComplete) onComplete();
        return;
    }

    const startX = event.clientX;
    const startY = event.clientY;

    const cartIcon = document.querySelector('a[href="cart.html"]');
    if (!cartIcon) {
        if(onComplete) onComplete();
        return;
    }

    const cartRect = cartIcon.getBoundingClientRect();
    const endX = cartRect.left + cartRect.width / 2;
    const endY = cartRect.top + cartRect.height / 2;

    // Create the flying element
    const flyingDot = document.createElement('div');
    flyingDot.style.position = 'fixed';
    flyingDot.style.left = startX + 'px';
    flyingDot.style.top = startY + 'px';
    flyingDot.style.width = '40px';
    flyingDot.style.height = '40px';
    flyingDot.style.borderRadius = '50%';
    flyingDot.style.zIndex = '9999';
    flyingDot.style.pointerEvents = 'none';
    flyingDot.style.transition = 'all 0.8s cubic-bezier(0.25, 1, 0.5, 1)';
    flyingDot.style.boxShadow = '0 5px 15px rgba(0,0,0,0.3)';

    // Insert shopping bag SVG
    flyingDot.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="#FFF1E0" style="width:20px; height:20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5V6a3.75 3.75 0 1 0-7.5 0v4.5m11.356-1.993l1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 0 1-1.12-1.243l1.264-12A1.125 1.125 0 0 1 5.513 7.5h12.974c.576 0 1.059.435 1.119 1.007ZM8.625 10.5a.375 0 1 1-.75 0 .375 0 0 1 .75 0Zm7.5 0a.375 0 1 1-.75 0 .375 0 0 1 .75 0Z" />
        </svg>
    `;
    flyingDot.style.backgroundColor = '#8B4513';
    flyingDot.style.display = 'flex';
    flyingDot.style.alignItems = 'center';
    flyingDot.style.justifyContent = 'center';

    document.body.appendChild(flyingDot);

    // Force reflow
    flyingDot.getBoundingClientRect();

    // Animate to cart
    flyingDot.style.left = endX + 'px';
    flyingDot.style.top = endY + 'px';
    flyingDot.style.transform = 'scale(0.2) rotate(360deg)';
    flyingDot.style.opacity = '0.5';

    // Remove element and call onComplete
    setTimeout(() => {
        if (document.body.contains(flyingDot)) {
            document.body.removeChild(flyingDot);
        }
        if(onComplete) onComplete();
    }, 800);
}

// Initial load
window.addEventListener('DOMContentLoaded', () => {
    updateNavCartCount();
});
