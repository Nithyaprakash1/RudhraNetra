// auth-ui.js - Handles injecting auth UI into the navbar and protecting routes

document.addEventListener('DOMContentLoaded', () => {
    injectAuthUI();
    protectRoutes();
    
    // Listen for auth state changes to update UI dynamically without reload
    window.addEventListener('authStateChanged', () => {
        injectAuthUI();
    });
});

function injectAuthUI() {
    // Insert it after the Shop Now button
    const shopBtn = document.querySelector('.nav-shop-btn');
    if (!shopBtn) return; // Navbar might not be on this page

    let authContainer = document.getElementById('auth-nav-container');
    if (!authContainer) {
        authContainer = document.createElement('div');
        authContainer.id = 'auth-nav-container';
        authContainer.className = 'relative flex items-center h-full mx-1 md:mx-4';
        
        // Insert it right after the Shop Now button
        shopBtn.parentNode.insertBefore(authContainer, shopBtn.nextSibling);
    }

    if (Auth.isLoggedIn()) {
        const user = Auth.getUser();
        let avatarHTML = '';
        if (user.avatar) {
            avatarHTML = `<img src="${user.avatar}" class="w-6 h-6 md:w-8 md:h-8 rounded-full border-2 border-current object-cover opacity-90 shadow-sm">`;
        } else {
            const initials = user.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
            avatarHTML = `<div class="w-6 h-6 md:w-8 md:h-8 rounded-full border-2 border-current flex items-center justify-center text-[10px] md:text-xs font-bold opacity-90 shadow-sm">${initials}</div>`;
        }
        
        authContainer.innerHTML = `
            <div class="relative group cursor-pointer nav-cart">
                <div class="flex items-center gap-2 transition-transform hover:scale-105">
                    ${avatarHTML}
                </div>
                <!-- Dropdown -->
                <div class="absolute right-0 mt-2 py-2 w-48 bg-[#FFF1E0] shadow-xl rounded-xl border border-[#8B4513]/10 opacity-0 invisible group-hover:visible group-hover:opacity-100 transition-all z-50">
                    <a href="dashboard.html" class="block px-4 py-2 text-sm text-[#8B4513] hover:bg-[#8B4513]/5">My Profile</a>
                    <a href="dashboard.html" class="block px-4 py-2 text-sm text-[#8B4513] hover:bg-[#8B4513]/5">My Orders</a>
                    <a href="dashboard.html" class="block px-4 py-2 text-sm text-[#8B4513] hover:bg-[#8B4513]/5">Saved Addresses</a>
                    <div class="border-t border-[#8B4513]/10 my-1"></div>
                    <button onclick="Auth.logout()" class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50">Logout</button>
                </div>
            </div>
        `;
    } else {
        authContainer.innerHTML = `
            <div class="flex items-center self-center transform translate-y-[2px]">
                <a href="login.html" class="text-xs md:text-[15px] font-bold nav-cart hover:opacity-80 transition tracking-wide">Login</a>
            </div>
        `;
    }
}

function protectRoutes() {
    // If we are on checkout or cart, we need to handle auth checks
    const path = window.location.pathname;
    if (path.includes('checkout.html')) {
        Auth.requireAuth();
    }
}

// Override Add to Cart and Buy Now buttons globally
window.addEventListener('click', (e) => {
    // Identify Add to Cart or Buy Now buttons
    const btn = e.target.closest('button') || e.target.closest('a');
    if (!btn) return;
    
    const text = (btn.innerText || '').toLowerCase();
    const ariaLabel = (btn.getAttribute('aria-label') || '').toLowerCase();
    const onclickAttr = (btn.getAttribute('onclick') || '').toLowerCase();

    if (text.includes('buy now') || text.includes('add to cart') || text.includes('checkout') ||
        ariaLabel.includes('buy now') || ariaLabel.includes('add to cart') || ariaLabel.includes('checkout') ||
        onclickAttr.includes('addtocart')) {
        // If it's a shop now button (which navigates to products), let it pass
        if(text.includes('shop now') || ariaLabel.includes('shop now')) return;
        
        if (window.Auth && !Auth.isLoggedIn()) {
            e.preventDefault();
            e.stopPropagation();
            Auth.requireAuth(); // Go directly to sign in page
        }
    }
}, true); // use capture phase to intercept before other click handlers

// Custom Alert Box
function showCustomAlert(message, onOk) {
    // Remove existing if any
    const existing = document.getElementById('custom-auth-alert');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'custom-auth-alert';
    overlay.className = 'fixed inset-0 z-[9999] flex items-center justify-center bg-black/60 backdrop-blur-md transition-opacity duration-300 opacity-0';
    
    const box = document.createElement('div');
    box.className = 'bg-gradient-to-b from-[#3E2415] to-[#1A0F0A] border border-[#8B4513]/50 rounded-2xl p-8 max-w-sm w-full mx-4 shadow-[0_0_40px_rgba(139,69,19,0.3)] transform scale-75 opacity-0 transition-all duration-500';
    box.style.transitionTimingFunction = "cubic-bezier(0.34, 1.56, 0.64, 1)";
    
    const title = document.createElement('h3');
    title.className = 'text-[#FFF1E0] font-bold text-xl mb-3 flex items-center gap-3';
    title.innerHTML = `
        <div class="bg-[#8B4513]/20 p-2 rounded-full animate-pulse">
            <svg class="w-6 h-6 text-[#F3B79B]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
        </div>
        Authentication Required
    `;

    const msg = document.createElement('p');
    msg.className = 'text-[#FFF1E0]/80 text-[15px] mb-8 leading-relaxed';
    msg.innerText = message;

    const btnWrapper = document.createElement('div');
    btnWrapper.className = 'flex justify-end';

    const btn = document.createElement('button');
    btn.className = 'px-8 py-2.5 bg-gradient-to-r from-[#D98A6C] to-[#C06947] text-white font-bold rounded-full hover:from-[#E89E82] hover:to-[#D27E5E] transition-all duration-300 shadow-[0_4px_15px_rgba(217,138,108,0.4)] hover:shadow-[0_6px_20px_rgba(217,138,108,0.6)] transform hover:-translate-y-0.5 text-sm tracking-widest uppercase';
    btn.innerText = 'OK';
    btn.onclick = () => {
        overlay.classList.remove('opacity-100');
        box.classList.remove('scale-100', 'opacity-100');
        box.classList.add('scale-95', 'opacity-0');
        setTimeout(() => {
            overlay.remove();
            if(onOk) onOk();
        }, 300);
    };

    btnWrapper.appendChild(btn);
    box.appendChild(title);
    box.appendChild(msg);
    box.appendChild(btnWrapper);
    overlay.appendChild(box);
    document.body.appendChild(overlay);

    // Animate in
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            overlay.classList.add('opacity-100');
            box.classList.remove('scale-75', 'opacity-0');
            box.classList.add('scale-100', 'opacity-100');
        });
    });
}

// Seamless Cart DB Synchronization via LocalStorage proxy
const originalSetItem = localStorage.setItem;
localStorage.setItem = async function(key, value) {
    originalSetItem.apply(this, arguments);
    if (key === 'rudraCart' && window.Auth && Auth.isLoggedIn()) {
        const user = Auth.getUser();
        let userCart = await DB.findOne('Cart', { userId: user.id });
        if (!userCart) {
            userCart = await DB.insert('Cart', { userId: user.id, products: JSON.parse(value) });
        } else {
            await DB.update('Cart', userCart.id, { products: JSON.parse(value) });
        }
    }
};

// On load, sync DB cart to local storage if logged in
document.addEventListener('DOMContentLoaded', async () => {
    if (window.Auth && Auth.isLoggedIn()) {
        const user = Auth.getUser();
        let userCart = await DB.findOne('Cart', { userId: user.id });
        if (userCart) {
            originalSetItem.call(localStorage, 'rudraCart', JSON.stringify(userCart.products));
        }
    }
});
