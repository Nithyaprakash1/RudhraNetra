
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-app.js";
        import { getFirestore, collection, query, orderBy, getDocs, doc, getDoc, updateDoc, onSnapshot, where, addDoc, deleteDoc } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-firestore.js";
        import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut, createUserWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-auth.js";

        const firebaseConfig = {
            apiKey: "AIzaSyC8NPDb0efimxJE_WHA3-rbmFdynla6TwI",
            authDomain: "studio-6539281913-cab55.firebaseapp.com",
            projectId: "studio-6539281913-cab55",
            storageBucket: "studio-6539281913-cab55.firebasestorage.app",
            messagingSenderId: "654131616933",
            appId: "1:654131616933:web:1411cc691a6fe9a700c14c"
        };

        const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);
        const auth = getAuth(app);

        // --- AUTHENTICATION & SECURITY FLOW ---

        async function verifyAdminRole(user) {
            try {
                let isAdmin = false;
                if (user && user.email && user.email.toLowerCase() === 'admin@rudranethra.com') {
                    isAdmin = true;
                } else if (user && user.email) {
                    const q = query(collection(db, "admins"), where("email", "==", user.email));
                    const snapshot = await getDocs(q);
                    if (!snapshot.empty) {
                        isAdmin = true;
                    }
                }

                if (!isAdmin) {
                    // Not in admins collection
                    alert("Access Denied: Your email is not registered as an Administrator.");
                    await signOut(auth);
                    sessionStorage.removeItem('isAdminLoggedIn');
                    window.location.href = 'admin-login.html';
                } else {
                    console.log("Admin verified.");
                    document.getElementById('authOverlay').style.display = 'none';
                    if (document.getElementById('adminEmailDisplay')) {
                        document.getElementById('adminEmailDisplay').innerText = user.email;
                    }
                    loadAdminsList(); // Load admins tab data
                }
            } catch (e) {
                console.error("Error verifying admin role:", e);
                alert("Security Error: Could not verify admin role.");
                await signOut(auth);
                window.location.href = 'admin-login.html';
            }
        }

        onAuthStateChanged(auth, (user) => {
            if (!user) {
                window.location.href = 'admin-login.html';
            } else {
                verifyAdminRole(user);
            }
        });

        window.logoutAdmin = function() {
            signOut(auth).then(() => {
                sessionStorage.removeItem('isAdminLoggedIn');
                window.location.href = 'admin-login.html';
            });
        };

        window.updateOrderStatus = async function(orderId, newStatus, selectElement) {
            selectElement.disabled = true;
            try {
                const orderRef = doc(db, "orders", orderId);
                await updateDoc(orderRef, {
                    status: newStatus
                });
                
                // Show success toast
                const toast = document.getElementById('customToast');
                toast.querySelector('span').innerText = 'Order status updated to ' + newStatus;
                toast.classList.add('show');
                setTimeout(() => toast.classList.remove('show'), 4000);
                
                // Remove all color classes
                selectElement.classList.remove(
                    'text-yellow-600', 'border-yellow-600/30', 'bg-yellow-600/10', 'focus:ring-yellow-600/50',
                    'text-blue-600', 'border-blue-600/30', 'bg-blue-600/10', 'focus:ring-blue-600/50',
                    'text-green-600', 'border-green-600/30', 'bg-green-600/10', 'focus:ring-green-600/50'
                );

                if (newStatus === 'Delivered') {
                    selectElement.classList.add('text-green-600', 'border-green-600/30', 'bg-green-600/10', 'focus:ring-green-600/50');
                } else if (newStatus === 'Shipped') {
                    selectElement.classList.add('text-blue-600', 'border-blue-600/30', 'bg-blue-600/10', 'focus:ring-blue-600/50');
                } else {
                    // Pending
                    selectElement.classList.add('text-yellow-600', 'border-yellow-600/30', 'bg-yellow-600/10', 'focus:ring-yellow-600/50');
                }
            } catch (error) {
                console.error("Error updating status: ", error);
                alert("Could not update status due to database permissions.");
            }
            selectElement.disabled = false;
        };

        // Custom Dropdown UI Logic
        window.toggleCustomDropdown = function(btn) {
            // close all others
            document.querySelectorAll('.dropdown-menu').forEach(m => {
                if(m !== btn.nextElementSibling) m.classList.add('hidden');
            });
            btn.nextElementSibling.classList.toggle('hidden');
        };

        document.addEventListener('click', function(e) {
            if(!e.target.closest('[data-dropdown]')) {
                document.querySelectorAll('.dropdown-menu').forEach(m => m.classList.add('hidden'));
            }
        });

        window.selectCustomStatus = function(docId, newStatus, item, colorClass) {
            const dropdown = item.closest('[data-dropdown]');
            const btn = dropdown.querySelector('button');
            const statusText = btn.querySelector('.status-text');
            
            statusText.textContent = newStatus;
            btn.className = `w-full bg-white text-${colorClass}-600 border border-${colorClass}-300 px-3 py-1.5 rounded-md text-xs font-bold flex justify-between items-center shadow-sm focus:outline-none transition-colors`;
            
            const menuItems = dropdown.querySelectorAll('ul li a');
            menuItems.forEach(mi => {
                mi.classList.remove('bg-blue-600', 'text-white');
                mi.classList.add('text-gray-800');
            });
            item.classList.remove('text-gray-800');
            item.classList.add('bg-blue-600', 'text-white');
            
            dropdown.querySelector('.dropdown-menu').classList.add('hidden');
            
            // Actually call the firebase update function directly here
            try {
                updateDoc(doc(db, "orders", docId), { status: newStatus }).then(async () => {
                    // Update Dashboard Orders too
                    try {
                        const orderData = (await getDoc(doc(db, "orders", docId))).data();
                        if (orderData && orderData.razorpay_payment_id) {
                            const orderNum = orderData.razorpay_payment_id.slice(-6).toUpperCase();
                            const qDash = query(collection(db, "Orders"), where("orderNumber", "==", orderNum));
                            const dashDocs = await getDocs(qDash);
                            dashDocs.forEach(dashDoc => {
                                updateDoc(doc(db, "Orders", dashDoc.id), { status: newStatus });
                            });
                        }
                    } catch(err) { console.error("Failed to sync to user dashboard", err); }

                    const toast = document.getElementById('customToast');
                    toast.querySelector('span').innerText = 'Order status updated to: ' + newStatus;
                    toast.classList.add('show');
                    setTimeout(() => toast.classList.remove('show'), 4000);
                });
            } catch(e) {}
        }

        window.openSidebar = function() {
            const sidebar = document.getElementById('adminSidebar');
            const btn = document.getElementById('openSidebarBtn');
            sidebar.style.marginLeft = '0';
            sidebar.style.transform = '';
            sidebar.classList.remove('-translate-x-full');
            btn.classList.add('md:hidden');
        };

        window.closeSidebar = function() {
            if (window.innerWidth >= 768) return;
            const sidebar = document.getElementById('adminSidebar');
            const btn = document.getElementById('openSidebarBtn');
            sidebar.style.marginLeft = '-16rem';
            sidebar.style.transform = 'translateX(-100%)';
            sidebar.classList.add('-translate-x-full');
            btn.classList.remove('md:hidden');
        };

        // Tab Switching
        window.goToTab = function(targetId) {
            document.querySelectorAll('.sidebar-item').forEach(i => {
                if(i.dataset.target === targetId) i.classList.add('active');
                else i.classList.remove('active');
            });
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            const targetElement = document.getElementById(targetId);
            if (targetElement) targetElement.classList.add('active');
            window.scrollTo({ top: 0, behavior: 'smooth' });
            // Automatically hide sidebar when changing tabs
            closeSidebar();
        };

        // Tab Navigation
        document.querySelectorAll('.sidebar-item').forEach(item => {
            item.addEventListener('click', (e) => {
                document.querySelectorAll('.sidebar-item').forEach(i => i.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                
                e.target.classList.add('active');
                document.getElementById(e.target.dataset.target).classList.add('active');
                
                // Automatically hide sidebar on click
                closeSidebar();
            });
        });

        // Load Products
        function loadProducts() {
            const tbody = document.getElementById('productsTbody');
            if(typeof masterProducts !== 'undefined') {
                tbody.innerHTML = masterProducts.map(p => {
                    const imgUrl = p.images && p.images.length > 0 ? p.images[0] : 'https://placehold.co/100x100/8B4513/FFF1E0?text=No+Image';
                    const beadsStr = Array.isArray(p.beads) && p.beads.length ? `<br><span class="text-[10px] uppercase opacity-70">Beads: ${p.beads.join(', ')}</span>` : '';
                    const sizeStr = Array.isArray(p.sizes) && p.sizes.length ? `<br><span class="text-[10px] uppercase opacity-70">Sizes: ${p.sizes.join(', ')}</span>` : '';

                    return `
                        <tr class="hover:bg-[#8B4513]/5 transition-colors">
                            <td class="text-xs opacity-60">#${p.id}</td>
                            <td><img src="${imgUrl}" class="w-12 h-12 object-cover rounded shadow"></td>
                            <td class="font-bold min-w-[150px]">${p.name} ${beadsStr} ${sizeStr}</td>
                            <td class="whitespace-nowrap">&#8377;${p.price.toLocaleString('en-IN')}</td>
                            <td class="uppercase text-xs tracking-wider opacity-70">${p.category || 'Standard'}</td>
                            <td>
                                <button onclick="deleteProduct(${p.id})" class="text-red-500 font-bold hover:bg-red-50 px-3 py-1 rounded transition whitespace-nowrap">Delete</button>
                            </td>
                        </tr>
                    `;
                }).join('');
            }
        }
        loadProducts();

        // --- Drag & Drop Image Logic ---
        const dropZone = document.getElementById('dropZone');
        const fileInput = document.getElementById('newProdImg');
        const previewContainer = document.getElementById('imagePreviewContainer');
        const removeImgBtn = document.getElementById('removeImgBtn');
        window.primaryImageIndex = 0;

        fileInput.addEventListener('change', async function(e) {
            // Remove existing previews except the close button
            const existingPreviews = previewContainer.querySelectorAll('.preview-wrapper');
            existingPreviews.forEach(el => el.remove());
            window.primaryImageIndex = 0; // reset on new upload

            if (this.files && this.files.length > 0) {
                const files = Array.from(this.files).slice(0, 5); // Max 5 images
                for (let i = 0; i < files.length; i++) {
                    const base64 = await getBase64(files[i]);
                    
                    const wrapper = document.createElement('div');
                    wrapper.className = 'preview-wrapper relative cursor-pointer group transition-transform hover:scale-105';
                    wrapper.onclick = (ev) => {
                        ev.stopPropagation();
                        window.primaryImageIndex = i;
                        updatePrimaryImageUI();
                    };

                    const img = document.createElement('img');
                    img.src = base64;
                    img.className = 'h-16 w-16 object-cover rounded shadow-sm border-2 transition-colors ' + (i === 0 ? 'border-green-500' : 'border-transparent');
                    
                    const badge = document.createElement('span');
                    badge.className = 'primary-badge absolute -top-2 -left-2 bg-green-500 text-white text-[9px] font-bold px-1 py-0.5 rounded shadow z-10 ' + (i === 0 ? '' : 'hidden');
                    badge.innerText = 'MAIN';

                    const overlay = document.createElement('div');
                    overlay.className = 'absolute inset-0 bg-black/40 rounded flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity';
                    overlay.innerHTML = '<span class="text-white text-[10px] font-bold text-center leading-tight px-1">Set as<br>Main</span>';

                    wrapper.appendChild(img);
                    wrapper.appendChild(badge);
                    wrapper.appendChild(overlay);
                    previewContainer.insertBefore(wrapper, removeImgBtn);
                }
                previewContainer.classList.remove('hidden');
                previewContainer.classList.add('flex');
            }
        });

        function updatePrimaryImageUI() {
            const wrappers = previewContainer.querySelectorAll('.preview-wrapper');
            wrappers.forEach((wrapper, index) => {
                const img = wrapper.querySelector('img');
                const badge = wrapper.querySelector('.primary-badge');
                if (index === window.primaryImageIndex) {
                    img.classList.remove('border-transparent');
                    img.classList.add('border-green-500');
                    badge.classList.remove('hidden');
                } else {
                    img.classList.add('border-transparent');
                    img.classList.remove('border-green-500');
                    badge.classList.add('hidden');
                }
            });
        }

        removeImgBtn.addEventListener('click', function(e) {
            e.stopPropagation(); // prevent opening file dialog
            fileInput.value = ''; // clear input
            previewContainer.classList.add('hidden');
            previewContainer.classList.remove('flex');
            const existingPreviews = previewContainer.querySelectorAll('.preview-wrapper');
            existingPreviews.forEach(el => el.remove());
            window.primaryImageIndex = 0;
        });

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) { e.preventDefault(); e.stopPropagation(); }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropZone.addEventListener(eventName, () => dropZone.classList.add('border-[#8B4513]', 'bg-[#8B4513]/10'), false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, () => dropZone.classList.remove('border-[#8B4513]', 'bg-[#8B4513]/10'), false);
        });

        dropZone.addEventListener('drop', function(e) {
            const dt = e.dataTransfer;
            const files = dt.files;
            if(files && files.length > 0) {
                fileInput.files = files; // Assign files to input
                const event = new Event('change', { bubbles: true });
                fileInput.dispatchEvent(event); // Trigger change event for preview
            }
        }, false);

        // Make modal closing also reset form & image
        const closeBtn = document.querySelector('#addProductModalContent button');
        closeBtn.addEventListener('click', () => {
            document.getElementById('addProductForm').reset();
            removeImgBtn.click();
        });

        window.deleteProduct = function(id) {
            const modal = document.getElementById('customConfirmModal');
            const content = document.getElementById('customConfirmContent');
            const confirmBtn = document.getElementById('confirmDeleteBtn');
            const cancelBtn = document.getElementById('cancelDeleteBtn');
            
            modal.style.display = 'flex';
            setTimeout(() => content.classList.add('active'), 10);
            
            confirmBtn.onclick = null;
            cancelBtn.onclick = null;
            
            cancelBtn.onclick = () => {
                content.classList.remove('active');
                setTimeout(() => modal.style.display = 'none', 300);
            };
            
            confirmBtn.onclick = () => {
                let currentProds = JSON.parse(localStorage.getItem('rudraProductsV8')) || masterProducts;
                currentProds = currentProds.filter(p => p.id !== id);
                localStorage.setItem('rudraProductsV8', JSON.stringify(currentProds));
                masterProducts = currentProds;
                
                content.classList.add('delete-blackhole');
                
                setTimeout(() => {
                    loadProducts();
                    modal.style.display = 'none';
                    content.classList.remove('active', 'delete-blackhole');
                    
                    const toast = document.getElementById('customToast');
                    toast.classList.add('show');
                    setTimeout(() => toast.classList.remove('show'), 4000);
                }, 800);
            };
        };

        window.addDynamicField = function(containerId, nameAttr, placeholder) {
            const container = document.getElementById(containerId);
            if (!container) return;
            const div = document.createElement('div');
            div.className = 'flex gap-2';
            div.innerHTML = `
                <input type="text" name="${nameAttr}" placeholder="${placeholder}" class="w-full px-4 py-2 rounded-lg border border-[#8B4513]/30 bg-white/50 focus:outline-none focus:border-[#8B4513]">
                <button type="button" onclick="this.parentElement.remove()" class="text-red-500 font-bold px-3 hover:bg-red-50 rounded-lg text-lg">&times;</button>
            `;
            container.appendChild(div);
        };

        window.addVariantField = function() {
            const container = document.getElementById('variantsContainer');
            const div = document.createElement('div');
            div.className = 'flex gap-2 items-center bg-white/40 p-2 rounded-lg border border-[#8B4513]/20 variant-row';
            div.innerHTML = `
                <input type="text" placeholder="Beads (e.g. 54)" class="w-1/4 px-2 py-1.5 rounded border border-[#8B4513]/30 bg-white/50 focus:outline-none text-xs var-beads">
                <input type="text" placeholder="Size (e.g. 8mm)" class="w-1/4 px-2 py-1.5 rounded border border-[#8B4513]/30 bg-white/50 focus:outline-none text-xs var-size">
                <input type="number" placeholder="Price (Ã¢â€šÂ¹)" class="w-1/4 px-2 py-1.5 rounded border border-[#8B4513]/30 bg-white/50 focus:outline-none text-xs var-price" required>
                <input type="number" placeholder="Old Price" class="w-1/4 px-2 py-1.5 rounded border border-[#8B4513]/30 bg-white/50 focus:outline-none text-xs var-oldPrice">
                <button type="button" onclick="this.parentElement.remove()" class="text-red-500 font-bold hover:bg-red-50 px-1.5 py-1 rounded text-lg leading-none">&times;</button>
            `;
            container.appendChild(div);
        };

        function getBase64(file) {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsDataURL(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = error => reject(error);
            });
        }

        // Handle Add Product
        document.getElementById('addProductForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const fileInput = document.getElementById('newProdImg');
            let imagesArray = [];
            if(fileInput.files.length > 0) {
                const files = Array.from(fileInput.files).slice(0, 5);
                for (let file of files) {
                    imagesArray.push(await getBase64(file));
                }
                
                // Swap the selected main image to the first position
                if (window.primaryImageIndex > 0 && window.primaryImageIndex < imagesArray.length) {
                    const temp = imagesArray[0];
                    imagesArray[0] = imagesArray[window.primaryImageIndex];
                    imagesArray[window.primaryImageIndex] = temp;
                }
            } else {
                imagesArray.push("https://placehold.co/100x100/8B4513/FFF1E0?text=No+Image");
            }

            let currentProds = JSON.parse(localStorage.getItem('rudraProductsV8')) || masterProducts;
            
            const newId = currentProds.length > 0 ? Math.max(...currentProds.map(p => p.id)) + 1 : 1;
            
            const variants = [];
            const uniqueBeads = new Set();
            const uniqueSizes = new Set();
            document.querySelectorAll('.variant-row').forEach(row => {
                const beads = row.querySelector('.var-beads').value.trim();
                const size = row.querySelector('.var-size').value.trim();
                const price = parseFloat(row.querySelector('.var-price').value) || 0;
                const oldPrice = parseFloat(row.querySelector('.var-oldPrice').value) || null;
                
                if (price > 0) {
                    variants.push({ beads, size, price, oldPrice });
                    if (beads) uniqueBeads.add(beads);
                    if (size) uniqueSizes.add(size);
                }
            });

            const newProduct = {
                id: newId,
                name: document.getElementById('newProdName').value,
                price: parseFloat(document.getElementById('newProdPrice').value),
                oldPrice: document.getElementById('newProdOldPrice').value ? parseFloat(document.getElementById('newProdOldPrice').value) : null,
                category: document.getElementById('newProdCat').value.toLowerCase(),
                isFeatured: document.getElementById('newProdFeatured').checked,
                images: imagesArray,
                beads: Array.from(uniqueBeads),
                sizes: Array.from(uniqueSizes),
                variants: variants
            };
            
            currentProds.unshift(newProduct); // Add to beginning
            localStorage.setItem('rudraProductsV8', JSON.stringify(currentProds));
            masterProducts = currentProds;
            
            loadProducts();

            // --- UNBELIEVABLE 3D ANIMATION ---
            const submitBtn = document.getElementById('saveProductBtn');
            const modalContent = document.getElementById('addProductModalContent');
            
            submitBtn.innerHTML = '<div class="loader" style="width:20px;height:20px;border-width:3px;border-top-color:#FFF1E0;"></div>';
            submitBtn.classList.add('opacity-80', 'cursor-not-allowed');

            setTimeout(() => {
                // Fire golden confetti
                confetti({
                    particleCount: 150,
                    spread: 80,
                    origin: { y: 0.6 },
                    colors: ['#FFD700', '#FFA500', '#8B4513'],
                    zIndex: 9999
                });

                // Trigger 3D flip out
                modalContent.classList.add('success-3d-flip');

                setTimeout(() => {
                    document.getElementById('addProductModal').style.display = 'none';
                    this.reset();
                    // Reset dynamic fields
                    document.getElementById('beadsContainer').innerHTML = '<input type="text" name="newProdBeads[]" placeholder="e.g. 54" class="w-full px-4 py-2 rounded-lg border border-[#8B4513]/30 bg-white/50 focus:outline-none focus:border-[#8B4513] text-sm">';
                    document.getElementById('sizesContainer').innerHTML = '<input type="text" name="newProdSize[]" placeholder="e.g. 8mm" class="w-full px-4 py-2 rounded-lg border border-[#8B4513]/30 bg-white/50 focus:outline-none focus:border-[#8B4513] text-sm">';
                    
                    // Reset Animation classes
                    modalContent.classList.remove('success-3d-flip');
                    submitBtn.innerHTML = 'Save Product';
                    submitBtn.classList.remove('opacity-80', 'cursor-not-allowed');
                }, 1000); // Wait for 3D flip to finish
            }, 600); // Short delay for UX loader
        });

        // Fetch Orders & Reviews
        async function fetchDashboardData() {
            try {
                // Fetch Orders
                const qOrders = query(collection(db, "orders"), orderBy("timestamp", "desc"));
                const ordersSnap = await getDocs(qOrders);
                let totalRev = 0;
                let pendingCount = 0;
                let ordersHtml = '';
                let recentOrdersHtml = '';
                
                ordersSnap.forEach((doc, index) => {
                    const data = doc.data();
                    totalRev += data.totalAmount || 0;
                    if (data.status !== 'Delivered') pendingCount++;
                    
                    const date = data.timestamp ? data.timestamp.toDate().toLocaleDateString() : 'Just now';
                    const cust = data.customer || {};
                    const items = data.items || [];
                    const itemsDesc = items.map(i => `${i.quantity||1}x ${i.name}`).join(', ');
                    const addressStr = `${cust.address}, ${cust.city}, ${cust.state} - ${cust.pin}`;
                    
                    let statusColor = 'yellow';
                    if (data.status === 'Delivered') statusColor = 'green';
                    else if (data.status === 'Shipped') statusColor = 'blue';

                    // Full Table Row
                    ordersHtml += `
                        <tr class="hover:bg-[#8B4513]/5 transition-colors">
                            <td class="text-xs opacity-60 break-all max-w-[80px]">${doc.id}</td>
                            <td class="whitespace-nowrap">${date}</td>
                            <td class="font-bold whitespace-nowrap">${cust.name || 'N/A'}</td>
                            <td class="text-xs whitespace-nowrap">
                                <div><a href="mailto:${cust.email}" class="text-blue-600 hover:underline">${cust.email || 'N/A'}</a></div>
                                <div><a href="tel:${cust.phone}" class="text-[#8B4513] hover:underline">${cust.phone || 'N/A'}</a></div>
                            </td>
                            <td class="text-[11px] leading-tight min-w-[200px]">
                                ${cust.address || 'N/A'}<br>
                                ${cust.city || ''}, ${cust.state || ''} - <span class="font-bold">${cust.pin || ''}</span>
                            </td>
                            <td class="text-xs min-w-[150px]">${itemsDesc}</td>
                            <td class="font-bold text-[#8B4513] whitespace-nowrap">&#8377;${(data.totalAmount||0).toLocaleString('en-IN')}</td>
                            <td class="align-middle">
                                <div class="relative inline-block w-28 text-left" data-dropdown>
                                    <button type="button" onclick="toggleCustomDropdown(this)" class="w-full bg-white text-${statusColor}-600 border border-${statusColor}-300 px-3 py-1.5 rounded-md text-xs font-bold flex justify-between items-center shadow-sm focus:outline-none transition-colors">
                                        <span class="status-text">${data.status || 'Pending'}</span>
                                        <svg class="h-4 w-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                    </button>
                                    <div class="absolute right-0 mt-1 w-full bg-white border border-gray-300 rounded-md shadow-lg z-[100] hidden dropdown-menu overflow-hidden">
                                        <ul class="py-0 text-xs font-medium">
                                            <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Pending', this, 'yellow'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(!data.status || data.status === 'Pending') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Pending</a></li>
                                            <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Shipped', this, 'blue'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(data.status === 'Shipped') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Shipped</a></li>
                                            <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Delivered', this, 'green'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(data.status === 'Delivered') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Delivered</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    `;

                    // Recent Table Row (only first 5)
                    if(index < 5) {
                        recentOrdersHtml += `
                            <tr>
                                <td>${cust.name}</td>
                                <td>${date}</td>
                                <td>&#8377;${(data.totalAmount||0).toLocaleString('en-IN')}</td>
                                <td class="align-middle">
                                    <div class="relative inline-block w-28 text-left" data-dropdown>
                                        <button type="button" onclick="toggleCustomDropdown(this)" class="w-full bg-white text-${statusColor}-600 border border-${statusColor}-300 px-3 py-1.5 rounded-md text-xs font-bold flex justify-between items-center shadow-sm focus:outline-none transition-colors">
                                            <span class="status-text">${data.status || 'Pending'}</span>
                                            <svg class="h-4 w-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                        </button>
                                        <div class="absolute right-0 mt-1 w-full bg-white border border-gray-300 rounded-md shadow-lg z-[100] hidden dropdown-menu overflow-hidden">
                                            <ul class="py-0 text-xs font-medium">
                                                <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Pending', this, 'yellow'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(!data.status || data.status === 'Pending') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Pending</a></li>
                                                <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Shipped', this, 'blue'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(data.status === 'Shipped') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Shipped</a></li>
                                                <li><a href="#" onclick="selectCustomStatus('${doc.id}', 'Delivered', this, 'green'); return false;" class="block px-3 py-2 hover:bg-blue-600 hover:text-white transition-colors ${(data.status === 'Delivered') ? 'bg-blue-600 text-white' : 'text-gray-800'}">Delivered</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }
                });

                document.getElementById('metricRevenue').innerHTML = `&#8377;${totalRev.toLocaleString('en-IN')}`;
                document.getElementById('metricOrders').innerHTML = ordersSnap.size;
                document.getElementById('metricPending').innerHTML = pendingCount;
                
                const fullTbody = document.querySelector('#fullOrdersTable tbody');
                const recentTbody = document.querySelector('#recentOrdersTable tbody');
                
                if (fullTbody) fullTbody.innerHTML = ordersHtml || `<tr><td colspan="6" class="text-center opacity-50">No orders found.</td></tr>`;
                if (recentTbody) recentTbody.innerHTML = recentOrdersHtml || `<tr><td colspan="4" class="text-center opacity-50">No recent activity.</td></tr>`;


                // Fetch Reviews
                let allReviews = [];
                
                try {
                    const qReviews = query(collection(db, "reviews"), orderBy("timestamp", "desc"));
                    const reviewsSnap = await getDocs(qReviews);
                    reviewsSnap.forEach((doc) => {
                        const data = doc.data();
                        allReviews.push({
                            id: doc.id,
                            isFirebase: true,
                            status: data.status || 'pending',
                            name: data.name || 'Anonymous',
                            rating: data.rating || 5,
                            reviewText: data.reviewText || data.text || '',
                            date: data.timestamp ? data.timestamp.toDate().toLocaleDateString() : 'Just now',
                            timestamp: data.timestamp ? data.timestamp.toMillis() : Date.now()
                        });
                    });
                } catch(e) {
                    console.warn("Firebase reviews fetch failed, falling back to local storage.", e);
                }

                // Merge local reviews
                let localReviews = JSON.parse(localStorage.getItem('rudraAdminReviews') || '[]');
                
                // Seed with initial dummy reviews if completely empty to maintain premium look
                if (localReviews.length === 0 && allReviews.length === 0) {
                    localReviews = [
                        { id: 'local_1', isFirebase: false, status: 'pending', name: "Priya M.", rating: 5, reviewText: "The Karungali malai is absolutely authentic and beautifully crafted. I can feel the positive energy. Very fast delivery too!", date: new Date(Date.now() - 86400000 * 2).toLocaleDateString(), timestamp: Date.now() - 86400000 * 2 },
                        { id: 'local_2', isFirebase: false, status: 'pending', name: "Rahul S.", rating: 4, reviewText: "Excellent quality beads. The silver spacing looks very elegant. Will definitely order again for my family.", date: new Date(Date.now() - 86400000 * 5).toLocaleDateString(), timestamp: Date.now() - 86400000 * 5 }
                    ];
                    localStorage.setItem('rudraAdminReviews', JSON.stringify(localReviews));
                }

                // Patch any local reviews missing an ID from older sessions
                let needsLocalSave = false;
                localReviews.forEach((r, idx) => {
                    if (!r.id) {
                        r.id = 'local_' + Date.now() + '_' + idx;
                        needsLocalSave = true;
                    }
                    if (!r.status) {
                        r.status = 'pending';
                        needsLocalSave = true;
                    }
                    r.isFirebase = false;
                });
                if (needsLocalSave) {
                    localStorage.setItem('rudraAdminReviews', JSON.stringify(localReviews));
                }
                
                allReviews = [...allReviews, ...localReviews];
                
                // Deduplicate by name and review text since Firebase server timestamp and local timestamp might differ slightly
                const uniqueReviews = [];
                const seen = new Set();
                for (let i = 0; i < allReviews.length; i++) {
                    const review = allReviews[i];
                    const key = review.name + '|' + review.reviewText;
                    if (!seen.has(key)) {
                        seen.add(key);
                        uniqueReviews.push(review);
                    }
                }
                allReviews = uniqueReviews;
                
                // Sort by timestamp desc
                allReviews.sort((a, b) => b.timestamp - a.timestamp);

                let reviewsHtml = '';
                allReviews.forEach(data => {
                    const stars = 'Ã¢Ëœâ€¦'.repeat(data.rating) + 'Ã¢Ëœâ€ '.repeat(5 - data.rating);
                    const isAllowed = data.status === 'allowed';
                    const statusBadge = isAllowed 
                        ? `<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold uppercase">Allowed</span>`
                        : `<span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-bold uppercase">${data.status || 'Pending'}</span>`;
                    
                    const actionBtn = isAllowed
                        ? `<button onclick="window.toggleReviewStatus('${data.id}', 'unallowed', ${data.isFirebase})" class="px-3 py-1 bg-red-100 text-red-600 rounded text-xs font-bold hover:bg-red-200 transition uppercase tracking-widest">Unallow</button>`
                        : `<button onclick="window.toggleReviewStatus('${data.id}', 'allowed', ${data.isFirebase})" class="px-3 py-1 bg-[#8B4513] text-[#FFF1E0] rounded text-xs font-bold hover:bg-[#5c3a23] transition shadow-sm uppercase tracking-widest">Allow</button>`;

                    reviewsHtml += `
                        <tr class="hover:bg-[#8B4513]/5 transition-colors">
                            <td class="font-bold py-3">${data.name}</td>
                            <td class="text-yellow-500 py-3">${stars}</td>
                            <td class="text-sm opacity-80 max-w-md py-3 pr-4">${data.reviewText || '<i>No written comment</i>'}</td>
                            <td class="text-xs opacity-60 py-3">${data.date}</td>
                            <td class="py-3">${statusBadge}</td>
                            <td class="py-3 text-right">${actionBtn}</td>
                        </tr>
                    `;
                });

                document.getElementById('metricReviews').innerHTML = allReviews.length;
                document.querySelector('#reviewsTable tbody').innerHTML = reviewsHtml || `<tr><td colspan="4" class="text-center opacity-50">No reviews found.</td></tr>`;

            } catch(e) {
                console.error("Error fetching admin data:", e);
                document.getElementById('metricRevenue').innerHTML = '&#8377;0';
                document.getElementById('metricOrders').innerHTML = '0';
                document.getElementById('metricPending').innerHTML = '0';
                document.getElementById('metricReviews').innerHTML = '0';
                document.querySelector('#fullOrdersTable tbody').innerHTML = `<tr><td colspan="8" class="text-center text-red-500 font-bold">Error loading data.</td></tr>`;
                document.querySelector('#recentOrdersTable tbody').innerHTML = `<tr><td colspan="4" class="text-center text-red-500 font-bold">Error loading data.</td></tr>`;
                document.querySelector('#reviewsTable tbody').innerHTML = `<tr><td colspan="4" class="text-center text-red-500 font-bold">Error loading data.</td></tr>`;
            }
        }

        window.toggleReviewStatus = async function(id, newStatus, isFirebase) {
            try {
                if (isFirebase) {
                    await updateDoc(doc(db, "reviews", id), { status: newStatus });
                } else {
                    let localReviews = JSON.parse(localStorage.getItem('rudraAdminReviews') || '[]');
                    let r = localReviews.find(x => x.id === id);
                    if (r) {
                        r.status = newStatus;
                        localStorage.setItem('rudraAdminReviews', JSON.stringify(localReviews));
                    }
                }
                fetchDashboardData();
            } catch(e) {
                console.error("Error updating review status:", e);
                alert("Failed to update status. Please try again.");
            }
        };

        window.addEventListener('load', () => {
            fetchDashboardData();
            // Listen to real-time page_views collection
            const viewsQuery = query(collection(db, "page_views"));
            window.globalViewsData = [];
            
            onSnapshot(viewsQuery, (snapshot) => {
                let views = [];
                snapshot.forEach(docSnap => {
                    views.push(docSnap.data());
                });
                
                window.globalViewsData = views;
                console.log("View Saved");
                
                let productWise = {};
                views.forEach(v => {
                    if(!productWise[v.productId]) {
                        productWise[v.productId] = { productId: v.productId, productName: v.productName, views: 0 };
                    }
                    productWise[v.productId].views++;
                });
                console.log("Product Wise Views:", Object.values(productWise));
                
                // Fetch legacy views from products collection
                let fetchPromises = [];
                for (let i = 1; i <= 21; i++) {
                    fetchPromises.push(getDoc(doc(db, "products", String(i))));
                }
                
                Promise.all(fetchPromises).then(snaps => {
                    let productDbViews = 0;
                    snaps.forEach(snap => {
                        if (snap.exists() && snap.data().views) {
                            productDbViews += snap.data().views;
                        }
                    });
                    
                    let legacyViews = productDbViews - views.length;
                    if (legacyViews < 0) legacyViews = 0;
                    window.globalLegacyViews = legacyViews;
                    
                    window.globalActualViews = views.length + legacyViews;
                    
                    const timeframe = document.getElementById('chartTitle').innerText.includes('Weekly') ? 'weekly' : 'monthly';
                    drawViewsChart(timeframe);
                }).catch(err => {
                    window.globalLegacyViews = 0;
                    drawViewsChart('weekly');
                });
                
            }, (err) => {
                console.error("Views Chart error:", err);
                // Fallback if page_views fails
                drawViewsChart('weekly');
            });

            window.updateChartTimeframe = function(timeframe) {
                if (timeframe === 'weekly') {
                    document.getElementById('chartTitle').innerText = 'Site Views (Weekly)';
                    document.getElementById('btn-weekly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded bg-[#8B4513] text-[#FFF1E0] font-bold transition-all shadow-sm";
                    document.getElementById('btn-monthly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded text-[#8B4513] hover:bg-[#8B4513]/20 font-bold transition-all";
                } else {
                    document.getElementById('chartTitle').innerText = 'Site Views (Monthly)';
                    document.getElementById('btn-monthly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded bg-[#8B4513] text-[#FFF1E0] font-bold transition-all shadow-sm";
                    document.getElementById('btn-weekly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded text-[#8B4513] hover:bg-[#8B4513]/20 font-bold transition-all";
                }
                drawViewsChart(timeframe);
            };

            function drawViewsChart(timeframe) {
                let labels = [];
                let chartData = [];
                const views = window.globalViewsData || [];

                if (timeframe === 'weekly') {
                    labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    chartData = [0, 0, 0, 0, 0, 0, 0];
                    
                    const now = new Date();
                    const dayOfWeek = now.getDay() || 7;
                    now.setHours(0,0,0,0);
                    const monday = new Date(now.getTime() - (dayOfWeek - 1) * 86400000);
                    
                    views.forEach(v => {
                        if (!v.date) return;
                        const vDate = new Date(v.date);
                        if (vDate >= monday) {
                            let day = vDate.getDay() || 7;
                            chartData[day - 1]++;
                        }
                    });
                    
                    // Add legacy views to today
                    const todayIdx = (now.getDay() || 7) - 1;
                    chartData[todayIdx] += window.globalLegacyViews || 0;
                    
                    const weeklyDataLog = chartData.map((v, i) => ({ day: labels[i], views: v }));
                    console.log("Weekly Data:", weeklyDataLog);
                } else {
                    labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                    chartData = [0, 0, 0, 0, 0];
                    
                    const now = new Date();
                    const currentMonth = now.getMonth() + 1;
                    const currentYear = now.getFullYear();
                    
                    views.forEach(v => {
                        if (v.month === currentMonth && v.year === currentYear) {
                            const d = new Date(v.date).getDate();
                            let weekIdx = Math.ceil(d / 7) - 1;
                            if (weekIdx > 4) weekIdx = 4;
                            chartData[weekIdx]++;
                        }
                    });
                    
                    // Add legacy views to current week
                    const todayD = now.getDate();
                    let currentWeekIdx = Math.ceil(todayD / 7) - 1;
                    if (currentWeekIdx > 4) currentWeekIdx = 4;
                    chartData[currentWeekIdx] += window.globalLegacyViews || 0;
                    
                    const monthlyDataLog = chartData.map((v, i) => ({ week: labels[i], views: v }));
                    console.log("Monthly Data:", monthlyDataLog);
                }
                console.log("Chart Updated");

                const ctx = document.getElementById('viewsChart').getContext('2d');
                
                // Check if chart instance exists and destroy it so it doesn't overlap on refresh
                if (window.viewsChartInstance) {
                    window.viewsChartInstance.destroy();
                }

                let gradient = ctx.createLinearGradient(0, 0, 0, 400);
                gradient.addColorStop(0, 'rgba(139, 69, 19, 0.3)');
                gradient.addColorStop(1, 'rgba(139, 69, 19, 0.0)');

                window.viewsChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Site Views',
                            data: chartData,
                            borderColor: '#8B4513',
                            backgroundColor: gradient,
                            borderWidth: 3,
                            fill: true,
                            tension: 0.4,
                            pointBackgroundColor: '#8B4513',
                            pointBorderColor: '#FFF1E0',
                            pointBorderWidth: 2,
                            pointRadius: 6,
                            pointHoverRadius: 8
                        }]
                    },
                    options: {
                        animation: false,
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: {
                            mode: 'index',
                            intersect: false,
                        },
                        scales: {
                            x: {
                                grid: { display: false, drawBorder: false },
                                ticks: { color: '#8B4513', font: { weight: 'bold' } }
                            },
                            y: {
                                grid: { display: false, drawBorder: false },
                                beginAtZero: true,
                                ticks: {
                                    color: '#8B4513',
                                    callback: function(value) {
                                        if (value >= 1000) return (value / 1000).toFixed(1) + 'k';
                                        return value;
                                    }
                                }
                            }
                        },
                        plugins: { 
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#FFF1E0',
                                titleColor: '#8B4513',
                                bodyColor: '#8B4513',
                                borderColor: 'rgba(139, 69, 19, 0.2)',
                                borderWidth: 1,
                                padding: 12,
                                displayColors: false,
                                callbacks: {
                                    label: function(context) {
                                        let val = context.parsed.y;
                                        if (val >= 1000) return (val / 1000).toFixed(1) + 'k Views';
                                        return val + ' Views';
                                    },
                                    title: function() { return null; }
                                }
                            }
                        }
                    },
                    plugins: [{
                        id: 'clipReveal',
                        beforeDraw: (chart) => {
                            const progress = chart.revealProgress !== undefined ? chart.revealProgress : 1;
                            if (progress < 1 && chart.chartArea) {
                                const ctx = chart.ctx;
                                const chartArea = chart.chartArea;
                                ctx.save();
                                ctx.beginPath();
                                const width = chartArea.right - chartArea.left;
                                ctx.rect(chartArea.left, chartArea.top - 50, width * progress, chartArea.bottom - chartArea.top + 100);
                                ctx.clip();
                            }
                        },
                        afterDraw: (chart) => {
                            const progress = chart.revealProgress !== undefined ? chart.revealProgress : 1;
                            if (progress < 1 && chart.chartArea) {
                                chart.ctx.restore();
                            }
                        }
                    }]
                });

                // Custom buttery smooth reveal animation
                window.viewsChartInstance.revealProgress = 0;
                const startTime = performance.now();
                const duration = 2000; // 2.0s smooth duration
                
                function animate() {
                    const elapsed = performance.now() - startTime;
                    let progress = elapsed / duration;
                    if (progress > 1) progress = 1;
                    
                    // easeOutQuart
                    window.viewsChartInstance.revealProgress = 1 - Math.pow(1 - progress, 4);
                    window.viewsChartInstance.draw();
                    
                    if (progress < 1) {
                        requestAnimationFrame(animate);
                    window.globalLegacyViews = 0;
                    drawViewsChart('weekly');
                });
                
            }, (err) => {
                console.error("Views Chart error:", err);
                // Fallback if page_views fails
                drawViewsChart('weekly');
            });

            window.updateChartTimeframe = function(timeframe) {
                if (timeframe === 'weekly') {
                    document.getElementById('chartTitle').innerText = 'Site Views (Weekly)';
                    document.getElementById('btn-weekly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded bg-[#8B4513] text-[#FFF1E0] font-bold transition-all shadow-sm";
                    document.getElementById('btn-monthly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded text-[#8B4513] hover:bg-[#8B4513]/20 font-bold transition-all";
                } else {
                    document.getElementById('chartTitle').innerText = 'Site Views (Monthly)';
                    document.getElementById('btn-monthly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded bg-[#8B4513] text-[#FFF1E0] font-bold transition-all shadow-sm";
                    document.getElementById('btn-weekly').className = "text-[10px] uppercase tracking-widest px-3 py-1.5 rounded text-[#8B4513] hover:bg-[#8B4513]/20 font-bold transition-all";
                }
                drawViewsChart(timeframe);
            };

            function drawViewsChart(timeframe) {
                let labels = [];
                let chartData = [];
                const views = window.globalViewsData || [];

                if (timeframe === 'weekly') {
                    labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    chartData = [0, 0, 0, 0, 0, 0, 0];
                    
                    const now = new Date();
                    const dayOfWeek = now.getDay() || 7;
                    now.setHours(0,0,0,0);
                    const monday = new Date(now.getTime() - (dayOfWeek - 1) * 86400000);
                    
                    views.forEach(v => {
                        if (!v.date) return;
                        const vDate = new Date(v.date);
                        if (vDate >= monday) {
                            let day = vDate.getDay() || 7;
                            chartData[day - 1]++;
                        }
                    });
                    
                    // Add legacy views to today
                    const todayIdx = (now.getDay() || 7) - 1;
                    chartData[todayIdx] += window.globalLegacyViews || 0;
                    
                    const weeklyDataLog = chartData.map((v, i) => ({ day: labels[i], views: v }));
                    console.log("Weekly Data:", weeklyDataLog);
                } else {
                    labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                    chartData = [0, 0, 0, 0, 0];
                    
                    const now = new Date();
                    const currentMonth = now.getMonth() + 1;
                    const currentYear = now.getFullYear();
                    
                    views.forEach(v => {
                        if (v.month === currentMonth && v.year === currentYear) {
                            const d = new Date(v.date).getDate();
                            let weekIdx = Math.ceil(d / 7) - 1;
                            if (weekIdx > 4) weekIdx = 4;
                            chartData[weekIdx]++;
                        }
                    });
                    
                    // Add legacy views to current week
                    const todayD = now.getDate();
                    let currentWeekIdx = Math.ceil(todayD / 7) - 1;
                    if (currentWeekIdx > 4) currentWeekIdx = 4;
                    chartData[currentWeekIdx] += window.globalLegacyViews || 0;
                    
                    const monthlyDataLog = chartData.map((v, i) => ({ week: labels[i], views: v }));
                    console.log("Monthly Data:", monthlyDataLog);
                }
                console.log("Chart Updated");

                const ctx = document.getElementById('viewsChart').getContext('2d');
                
                // Check if chart instance exists and destroy it so it doesn't overlap on refresh
                if (window.viewsChartInstance) {
                    window.viewsChartInstance.destroy();
                }

                let gradient = ctx.createLinearGradient(0, 0, 0, 400);
                gradient.addColorStop(0, 'rgba(139, 69, 19, 0.3)');
                gradient.addColorStop(1, 'rgba(139, 69, 19, 0.0)');

                window.viewsChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Site Views',
                            data: chartData,
                            borderColor: '#8B4513',
                            backgroundColor: gradient,
                            borderWidth: 3,
                            fill: true,
                            tension: 0.4,
                            pointBackgroundColor: '#8B4513',
                            pointBorderColor: '#FFF1E0',
                            pointBorderWidth: 2,
                            pointRadius: 6,
                            pointHoverRadius: 8
                        }]
                    },
                    options: {
                        animation: false,
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: {
                            mode: 'index',
                            intersect: false,
                        },
                        scales: {
                            x: {
                                grid: { display: false, drawBorder: false },
                                ticks: { color: '#8B4513', font: { weight: 'bold' } }
                            },
                            y: {
                                grid: { display: false, drawBorder: false },
                                beginAtZero: true,
                                ticks: {
                                    color: '#8B4513',
                                    callback: function(value) {
                                        if (value >= 1000) return (value / 1000).toFixed(1) + 'k';
                                        return value;
                                    }
                                }
                            }
                        },
                        plugins: { 
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#FFF1E0',
                                titleColor: '#8B4513',
                                bodyColor: '#8B4513',
                                borderColor: 'rgba(139, 69, 19, 0.2)',
                                borderWidth: 1,
                                padding: 12,
                                displayColors: false,
                                callbacks: {
                                    label: function(context) {
                                        let val = context.parsed.y;
                                        if (val >= 1000) return (val / 1000).toFixed(1) + 'k Views';
                                        return val + ' Views';
                                    },
                                    title: function() { return null; }
                                }
                            }
                        }
                    },
                    plugins: [{
                        id: 'clipReveal',
                        beforeDraw: (chart) => {
                            const progress = chart.revealProgress !== undefined ? chart.revealProgress : 1;
                            if (progress < 1 && chart.chartArea) {
                                const ctx = chart.ctx;
                                const chartArea = chart.chartArea;
                                ctx.save();
                                ctx.beginPath();
                                const width = chartArea.right - chartArea.left;
                                ctx.rect(chartArea.left, chartArea.top - 50, width * progress, chartArea.bottom - chartArea.top + 100);
                                ctx.clip();
                            }
                        },
                        afterDraw: (chart) => {
                            const progress = chart.revealProgress !== undefined ? chart.revealProgress : 1;
                            if (progress < 1 && chart.chartArea) {
                                chart.ctx.restore();
                            }
                        }
                    }]
                });

                // Custom buttery smooth reveal animation
                window.viewsChartInstance.revealProgress = 0;
                const startTime = performance.now();
                const duration = 2000; // 2.0s smooth duration
                
                function animate() {
                    const elapsed = performance.now() - startTime;
                    let progress = elapsed / duration;
                    if (progress > 1) progress = 1;
                    
                    // easeOutQuart
                    window.viewsChartInstance.revealProgress = 1 - Math.pow(1 - progress, 4);
                    window.viewsChartInstance.draw();
                    
                    if (progress < 1) {
                        requestAnimationFrame(animate);
                    }
                }
                requestAnimationFrame(animate);
            }

        });

        // --- ADMIN MANAGEMENT SYSTEM ---
        const secondaryApp = initializeApp(firebaseConfig, "SecondaryApp");
        const secondaryAuth = getAuth(secondaryApp);

        async function loadAdminsList() {
            try {
                const snapshot = await getDocs(collection(db, "admins"));
                const tbody = document.getElementById("adminsList");
                if(!tbody) return;
                tbody.innerHTML = '';
                snapshot.forEach(docSnap => {
                    const data = docSnap.data();
                    const tr = document.createElement('tr');
                    tr.className = 'hover:bg-[#8B4513]/5 transition-colors';
                    tr.innerHTML = `
                        <td class="font-bold py-4 pl-2 text-[#3a200d]">${data.email}</td>
                        <td class="py-4"><span class="px-2 py-1 bg-[#8B4513]/10 text-[#8B4513] rounded-full text-[10px] font-bold uppercase tracking-widest">Administrator</span></td>
                        <td class="py-4 text-right pr-2">
                            <button onclick="removeAdmin('${docSnap.id}', '${data.email}')" class="px-3 py-1.5 bg-red-100 text-red-600 rounded text-xs font-bold hover:bg-red-200 transition uppercase tracking-widest shadow-sm">Revoke Access</button>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
            } catch(e) {
                console.error("Error loading admins:", e);
            }
        }
        window.loadAdminsList = loadAdminsList;

        window.removeAdmin = async function(docId, email) {
            if(confirm(`Are you sure you want to revoke admin access for ${email}?`)) {
                try {
                    await deleteDoc(doc(db, "admins", docId));
                    alert(`Access revoked for ${email}.`);
                    loadAdminsList();
                } catch(e) {
                    console.error("Error removing admin:", e);
                    alert("Failed to remove admin. Check permissions.");
                }
            }
        };

        const addAdminForm = document.getElementById('addAdminForm');
        if(addAdminForm) {
            addAdminForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const email = document.getElementById('newAdminEmail').value;
                const pwd = document.getElementById('newAdminPwd').value;
                const btnText = document.getElementById('addAdminBtnText');
                const loader = document.getElementById('addAdminLoader');
                
                btnText.style.display = 'none';
                loader.style.display = 'block';

                try {
                    // Create User in Auth using Secondary App so current admin isn't logged out
                    await createUserWithEmailAndPassword(secondaryAuth, email, pwd);
                    
                    // Add to admins collection
                    await addDoc(collection(db, "admins"), { email: email, addedAt: new Date() });
                    
                    alert(`Admin ${email} successfully registered!`);
                    document.getElementById('addAdminModal').style.display = 'none';
                    addAdminForm.reset();
                    loadAdminsList();
                } catch(err) {
                    console.error("Error adding admin:", err);
                    alert("Error: " + err.message);
                } finally {
                    btnText.style.display = 'block';
                    loader.style.display = 'none';
                }
            });
        }
    
