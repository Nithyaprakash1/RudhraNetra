$html = Get-Content -Path 'index.html' -Raw -Encoding UTF8

$header = ""
if ($html -match '(?s)(.*?</nav>)') {
    $header = $matches[1]
}

$header = $header -replace '<title>.*?</title>', '<title>Secure Checkout | Rudra Nethra</title>'
$header = $header -replace '</head>', '<script src="https://checkout.razorpay.com/v1/checkout.js"></script>`n</head>'

$footer = ""
if ($html -match '(?s)(<!-- Footer -->.*)') {
    $footer = $matches[1]
}

$checkoutBody = @"

<!-- Checkout Section -->
<section class="pt-32 pb-24 px-6 min-h-screen" style="background: #FFF1E0;">
    <div class="max-w-6xl mx-auto">
        
        <div class="mb-10 text-center">
            <h1 class="text-4xl md:text-5xl font-bold text-[#8B4513] mb-3" style="font-family: 'Playfair Display', serif;">Secure Checkout</h1>
            <p class="text-[#8B4513]/70 font-medium">Complete your order to receive your sacred blessings.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10">
            
            <!-- Left: Billing & Shipping -->
            <div class="lg:col-span-7 space-y-8">
                
                <!-- Contact Info -->
                <div class="bg-white p-8 rounded-2xl shadow-[0_10px_30px_rgba(139,69,19,0.05)] border border-[#8B4513]/10">
                    <h2 class="text-xl font-bold text-[#8B4513] mb-6 flex items-center gap-2">
                        <span class="w-8 h-8 rounded-full bg-[#8B4513]/10 flex items-center justify-center text-[#8B4513] text-sm">1</span>
                        Contact Information
                    </h2>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">Email Address *</label>
                            <input type="email" id="c_email" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="your@email.com">
                        </div>
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">Phone Number *</label>
                            <input type="tel" id="c_phone" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="+91 XXXXX XXXXX">
                        </div>
                    </div>
                </div>

                <!-- Shipping Address -->
                <div class="bg-white p-8 rounded-2xl shadow-[0_10px_30px_rgba(139,69,19,0.05)] border border-[#8B4513]/10">
                    <h2 class="text-xl font-bold text-[#8B4513] mb-6 flex items-center gap-2">
                        <span class="w-8 h-8 rounded-full bg-[#8B4513]/10 flex items-center justify-center text-[#8B4513] text-sm">2</span>
                        Shipping Address
                    </h2>
                    <div class="space-y-5">
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">Full Name *</label>
                            <input type="text" id="c_name" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="Enter your full name">
                        </div>
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">Address *</label>
                            <input type="text" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all mb-3" placeholder="House/Flat No., Building Name">
                            <input type="text" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="Street Address, Area">
                        </div>
                        <div class="grid grid-cols-2 md:grid-cols-3 gap-5">
                            <div class="col-span-2 md:col-span-1">
                                <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">PIN Code *</label>
                                <input type="text" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="000000">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">City *</label>
                                <input type="text" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="City">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-[#8B4513]/70 mb-2">State *</label>
                                <input type="text" class="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:border-[#8B4513] focus:ring-1 focus:ring-[#8B4513] outline-none transition-all" placeholder="State">
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Right: Order Summary & Payment -->
            <div class="lg:col-span-5">
                <div class="bg-[#FFF8F0] p-8 rounded-2xl shadow-[0_20px_40px_rgba(139,69,19,0.08)] border border-[#8B4513]/20 sticky top-32">
                    <h2 class="text-xl font-bold text-[#8B4513] mb-6 border-b border-[#8B4513]/10 pb-4">Order Summary</h2>
                    
                    <!-- Dynamic Cart Items Container -->
                    <div id="checkout-items" class="space-y-4 mb-6 max-h-64 overflow-y-auto pr-2">
                        <!-- Items will be injected here via JS -->
                    </div>

                    <div class="border-t border-[#8B4513]/10 pt-4 space-y-3 mb-6 text-sm text-[#8B4513]/80">
                        <div class="flex justify-between">
                            <span>Subtotal</span>
                            <span id="checkout-subtotal" class="font-medium">â‚¹0.00</span>
                        </div>
                        <div class="flex justify-between">
                            <span>Shipping</span>
                            <span class="font-medium text-green-600">Free</span>
                        </div>
                        <div class="flex justify-between text-lg font-bold text-[#8B4513] pt-3 border-t border-[#8B4513]/10">
                            <span>Total</span>
                            <span id="checkout-total">â‚¹0.00</span>
                        </div>
                    </div>

                    <!-- Payment Button -->
                    <button id="rzp-button1" class="w-full py-4 bg-gradient-to-r from-[#8B4513] to-[#A8704D] text-[#FFF1E0] font-bold uppercase tracking-widest rounded-xl hover:shadow-[0_10px_20px_rgba(139,69,19,0.3)] transform hover:-translate-y-1 transition-all flex items-center justify-center gap-3">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                        Pay Securely via Razorpay
                    </button>
                    
                    <div class="mt-6 flex items-center justify-center gap-4 opacity-60 grayscale">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/e/e1/UPI-Logo-vector.svg" alt="UPI" class="h-5">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg" alt="Visa" class="h-4">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg" alt="Mastercard" class="h-5">
                        <img src="https://razorpay.com/assets/razorpay-logo.svg" alt="Razorpay" class="h-5">
                    </div>
                    <p class="text-center text-[10px] text-[#8B4513]/50 mt-4 uppercase tracking-widest">100% Secure & Encrypted Payments</p>
                </div>
            </div>

        </div>
    </div>
</section>

<!-- Razorpay Integration Script -->
<script>
    // Load cart items from localStorage
    const cartItems = JSON.parse(localStorage.getItem('rudra_cart')) || [];
    const container = document.getElementById('checkout-items');
    let totalAmt = 0;

    if (cartItems.length === 0) {
        // Fallback dummy item for direct Buy Now if cart is empty
        container.innerHTML = `
            <div class="flex gap-4 items-center">
                <div class="w-16 h-16 bg-[#8B4513]/10 rounded-lg overflow-hidden flex-shrink-0">
                    <img src="https://placehold.co/100x100/8B4513/FFF1E0?text=Item" class="w-full h-full object-cover">
                </div>
                <div class="flex-1">
                    <h4 class="text-sm font-bold text-[#8B4513]">Karungali Product</h4>
                    <p class="text-xs text-[#8B4513]/70">Qty: 1</p>
                </div>
                <div class="text-sm font-bold text-[#8B4513]">â‚¹1200</div>
            </div>`;
        totalAmt = 1200;
    } else {
        cartItems.forEach(item => {
            totalAmt += (item.price * item.quantity);
            container.innerHTML += `
            <div class="flex gap-4 items-center">
                <div class="w-16 h-16 bg-[#8B4513]/10 rounded-lg overflow-hidden flex-shrink-0">
                    <img src="` + item.image + `" class="w-full h-full object-cover">
                </div>
                <div class="flex-1">
                    <h4 class="text-sm font-bold text-[#8B4513]">` + item.name + `</h4>
                    <p class="text-xs text-[#8B4513]/70">Qty: ` + item.quantity + `</p>
                </div>
                <div class="text-sm font-bold text-[#8B4513]">â‚¹` + (item.price * item.quantity) + `</div>
            </div>`;
        });
    }

    document.getElementById('checkout-subtotal').textContent = 'â‚¹' + totalAmt;
    document.getElementById('checkout-total').textContent = 'â‚¹' + totalAmt;

    // Razorpay Integration
    document.getElementById('rzp-button1').onclick = function(e) {
        e.preventDefault();
        
        const name = document.getElementById('c_name').value;
        const email = document.getElementById('c_email').value;
        const phone = document.getElementById('c_phone').value;
        
        if(!name || !email || !phone) {
            alert("Please fill in your Contact and Shipping details before proceeding to payment.");
            return;
        }

        var options = {
            "key": "rzp_test_T2hZdE4034sQPh", // Replace with actual Razorpay Key ID
            "amount": totalAmt * 100, // Amount is in currency subunits. Default currency is INR. Hence, 50000 refers to 50000 paise
            "currency": "INR",
            "name": "Rudra Nethra",
            "description": "Secure Checkout",
            "image": "image/logo.png",
            "handler": function (response){
                alert("Payment Successful! Payment ID: " + response.razorpay_payment_id);
                // Redirect to success page or clear cart
                localStorage.removeItem('rudra_cart');
                window.location.href = 'index.html';
            },
            "prefill": {
                "name": name,
                "email": email,
                "contact": phone
            },
            "notes": {
                "address": "Rudra Nethra Corporate Office"
            },
            "theme": {
                "color": "#8B4513"
            }
        };
        var rzp1 = new Razorpay(options);
        rzp1.on('payment.failed', function (response){
                alert("Payment Failed. Reason: " + response.error.description);
        });
        rzp1.open();
    }
</script>
"@

$finalHtml = $header + $checkoutBody + $footer
[IO.File]::WriteAllText('checkout.html', $finalHtml, [System.Text.Encoding]::UTF8)
Write-Host "Created checkout.html"

