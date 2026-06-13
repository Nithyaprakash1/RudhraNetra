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
        showToast('This product is already in your cart!');
        return;
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

function showToast(message) {
    const toast = document.createElement('div');
    toast.innerText = message;
    toast.style.position = 'fixed';
    toast.style.bottom = '40px';
    toast.style.right = '40px';
    toast.style.backgroundColor = '#8B4513';
    toast.style.color = '#FFF1E0';
    toast.style.padding = '14px 28px';
    toast.style.borderRadius = '12px';
    toast.style.boxShadow = '0 15px 30px rgba(139, 69, 19, 0.3)';
    toast.style.zIndex = '10000';
    toast.style.fontFamily = "'Inter', sans-serif";
    toast.style.fontWeight = '500';
    toast.style.fontSize = '15px';
    toast.style.display = 'flex';
    toast.style.alignItems = 'center';
    toast.style.gap = '12px';
    toast.style.transform = 'translateY(100px) scale(0.9)';
    toast.style.opacity = '0';
    toast.style.transition = 'all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
    
    // Add warning icon
    toast.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" style="width:24px; height:24px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <span>${message}</span>
    `;

    document.body.appendChild(toast);
    
    // Force reflow
    toast.getBoundingClientRect();
    
    // Slide in
    toast.style.transform = 'translateY(0) scale(1)';
    toast.style.opacity = '1';
    
    // Remove after 3s
    setTimeout(() => {
        toast.style.transform = 'translateY(100px) scale(0.9)';
        toast.style.opacity = '0';
        setTimeout(() => {
            if(document.body.contains(toast)) document.body.removeChild(toast);
        }, 500);
    }, 3000);
}
