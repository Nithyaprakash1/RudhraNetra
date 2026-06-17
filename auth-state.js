import { initializeApp } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-app.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-auth.js";
import { getFirestore, doc, getDoc } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-firestore.js";

const firebaseConfig = {
    apiKey: "AIzaSyC8NPDb0efimxJE_WHA3-rbmFdynla6TwI",
    authDomain: "studio-6539281913-cab55.firebaseapp.com",
    projectId: "studio-6539281913-cab55",
    storageBucket: "studio-6539281913-cab55.firebasestorage.app",
    messagingSenderId: "654131616933",
    appId: "1:654131616933:web:1411cc691a6fe9a700c14c"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Wait for DOM
document.addEventListener("DOMContentLoaded", () => {
    const accountBtn = document.getElementById('account-btn');
    const accountDropdown = document.getElementById('account-dropdown');
    
    if (accountBtn && accountDropdown) {
        accountBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            accountDropdown.classList.toggle('hidden');
            accountDropdown.classList.toggle('flex');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            if (!accountBtn.contains(e.target) && !accountDropdown.contains(e.target)) {
                accountDropdown.classList.add('hidden');
                accountDropdown.classList.remove('flex');
            }
        });
    }

    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            signOut(auth).then(() => {
                window.location.href = 'index.html';
            });
        });
    }
});

// Listen to Auth State
onAuthStateChanged(auth, async (user) => {
    const accountContainer = document.getElementById('account-menu-container');
    const accountBtn = document.getElementById('account-btn');
    const accountName = document.getElementById('account-name');
    const accountEmail = document.getElementById('account-email');

    if (user && accountContainer) {
        accountContainer.classList.remove('hidden');
        
        let displayName = user.displayName || "User";
        
        // Try to fetch custom name from Firestore if displayName is empty
        if (!user.displayName) {
            try {
                const userDoc = await getDoc(doc(db, "users", user.uid));
                if (userDoc.exists() && userDoc.data().name) {
                    displayName = userDoc.data().name;
                }
            } catch (e) {
                console.warn("Could not fetch user profile details", e);
            }
        }

        if (accountBtn) accountBtn.innerText = displayName.charAt(0).toUpperCase();
        if (accountName) accountName.innerText = displayName;
        if (accountEmail) accountEmail.innerText = user.email;
    } else if (accountContainer) {
        // Hide if not logged in
        accountContainer.classList.add('hidden');
    }
});
