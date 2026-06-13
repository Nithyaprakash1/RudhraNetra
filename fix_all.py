import os
import re

files = [f for f in os.listdir('.') if f.endswith('.html')]

CTA_HTML = """
        <div class="relative z-10 max-w-3xl mx-auto mt-8" data-aos="fade-up">
            <span class="text-xs uppercase tracking-widest font-semibold text-[#FFF1E0]/60 mb-4 block">Elevate Your Sacred Space</span>
            <h2 class="text-5xl md:text-6xl text-[#FFF1E0] mb-6 leading-tight animate-[pulse_3s_ease-in-out_infinite]">Awaken The Energy Within</h2>
            <p class="text-lg text-[#FFF1E0]/80 mb-10 max-w-xl mx-auto">Experience the shielding aura of consecrated Karungali crafted lovingly for your spiritual journey.</p>
            <button onclick="window.location.href='product.html'" class="shining-button px-10 py-4 bg-[#8B4513] text-[#FFF1E0] rounded-full hover:bg-[#8B4513] transition-all font-medium tracking-wider text-sm shadow-2xl">
                EXPLORE THE COLLECTION
            </button>
        </div>
"""

def clean_duplicate_nav_links(content):
    # Fix multiple nav-link classes
    while 'nav-link nav-link' in content:
        content = content.replace('nav-link nav-link', 'nav-link')
    return content

def fix_cart_button(content):
    # Change the cart button class
    old_cart = 'class="text-[#8B4513] hover:text-[#8B4513] nav-link transition relative"'
    new_cart = 'class="nav-cart transition relative"'
    content = content.replace(old_cart, new_cart)
    # Also fix if it has multiple nav-links
    content = re.sub(r'class="text-\[#8B4513\] hover:text-\[#8B4513\]\s+(nav-link\s*)+transition relative"', new_cart, content)
    return content

for filename in files:
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    content = clean_duplicate_nav_links(content)
    content = fix_cart_button(content)
    
    # Ensure glass-nav and transparent-nav styles handle nav-cart
    if 'style id="dynamic-nav-styles"' not in content:
        # We need to add the style block or modify existing
        pass
    else:
        # Add nav-cart styling
        if '.transparent-nav .nav-cart' not in content:
            style_addition = """
        .transparent-nav .nav-link { color: #FFF1E0 !important; }
        .transparent-nav .nav-cart { color: #FFF1E0 !important; }
        .transparent-nav .nav-mobile-btn { color: #FFF1E0 !important; }
        .glass-nav .nav-link { color: #8B4513 !important; }
        .glass-nav .nav-cart { color: #8B4513 !important; }
        .glass-nav .nav-mobile-btn { color: #8B4513 !important; }
"""
            # Replace the old styles
            content = re.sub(r'\.transparent-nav \.nav-link \{ color: #FFF1E0 !important; \}', '', content)
            content = re.sub(r'\.glass-nav \.nav-link \{ color: #8B4513 !important; \}', style_addition, content)
            

    # --- product.html fixes ---
    if filename == 'product.html':
        # Find the pre-footer banner and inject CTA if not present
        if 'Awaken The Energy Within' not in content:
            banner_pattern = r'(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
            content = re.sub(banner_pattern, r'\1' + CTA_HTML, content)

    # --- combo.html fixes ---
    if filename == 'combo.html':
        # Remove duplicate pre-footer banners
        banner_start = '<!-- Immersive Pre-Footer Banner & CTA -->'
        banner_end = '</section>'
        
        # Count occurrences
        blocks = content.split(banner_start)
        if len(blocks) > 2: # More than 1 banner
            # Reconstruct with only 1 banner
            # The last block has the rest of the file
            end_of_banner_idx = blocks[1].find(banner_end) + len(banner_end)
            # Just keep the last banner and the rest of the file
            content = blocks[0] + banner_start + blocks[2]
            
        # Ensure image is combo-new.jpg and CTA is present
        content = content.replace('For combo page.jpeg', 'combo-new.jpg')
        if 'Awaken The Energy Within' not in content:
            banner_pattern = r'(<div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-\[#1E110A\]/60"></div>\s*</div>)'
            content = re.sub(banner_pattern, r'\1' + CTA_HTML, content)

    # --- product-details.html fixes ---
    if filename == 'product-details.html':
        # Remove duplicate pre-footer banners
        banner_start = '<!-- Immersive Pre-Footer Banner & CTA -->'
        banner_end = '</section>'
        blocks = content.split(banner_start)
        if len(blocks) > 2: # Duplicate!
            # Keep blocks[0] and the SECOND banner which is blocks[-1]
            content = blocks[0] + banner_start + blocks[-1]

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

print("Fixes applied.")
