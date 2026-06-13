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

    if (imageUrl) {
        flyingDot.style.backgroundImage = `url(${imageUrl})`;
        flyingDot.style.backgroundSize = 'cover';
        flyingDot.style.backgroundPosition = 'center';
    } else {
        flyingDot.style.backgroundColor = '#8B4513';
    }

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
