// auth.js - Authentication Controller

class AuthController {
    constructor() {
        this.currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;
    }

    async getFirebaseAuth() {
        await DB.initPromise;
        const { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, sendPasswordResetEmail } = await import("https://www.gstatic.com/firebasejs/10.9.0/firebase-auth.js");
        const auth = getAuth(DB.app);
        return { auth, createUserWithEmailAndPassword, signInWithEmailAndPassword, sendPasswordResetEmail };
    }

    // Register a new user
    async register(name, email, mobile, password, avatarBase64 = null) {
        // Validate duplicates
        const existingEmail = await DB.findOne('Users', { email });
        if (existingEmail) {
            throw new Error("Email already registered");
        }
        
        const existingMobile = await DB.findOne('Users', { mobile });
        if (existingMobile) {
            throw new Error("Mobile number already registered");
        }

        // 1. Create in Firebase Auth
        const { auth, createUserWithEmailAndPassword } = await this.getFirebaseAuth();
        try {
            await createUserWithEmailAndPassword(auth, email, password);
        } catch (error) {
            throw new Error(error.message);
        }

        const newUser = {
            name,
            email,
            mobile,
            password,
            avatar: avatarBase64
        };

        const user = await DB.insert('Users', newUser);
        this.loginState(user);
        return user;
    }

    // Login user
    async login(emailOrMobile, password) {
        let user = await DB.findOne('Users', { email: emailOrMobile });
        if (!user) {
            user = await DB.findOne('Users', { mobile: emailOrMobile });
        }

        if (!user) {
            throw new Error("Invalid credentials");
        }

        // 2. Authenticate with Firebase Auth using their true email
        const { auth, signInWithEmailAndPassword, createUserWithEmailAndPassword } = await this.getFirebaseAuth();
        try {
            await signInWithEmailAndPassword(auth, user.email, password);
        } catch (error) {
            // Lazy migration for legacy users
            if ((error.code === 'auth/user-not-found' || error.code === 'auth/invalid-credential') && user.password === password) {
                try {
                    await createUserWithEmailAndPassword(auth, user.email, password);
                } catch (migrationError) {
                    throw new Error("Invalid credentials");
                }
            } else {
                throw new Error("Invalid credentials");
            }
        }

        this.loginState(user);
        
        // Merge guest cart to user cart
        this.mergeCart(user.id);

        return user;
    }

    // Reset Password
    async resetPassword(email) {
        const user = await DB.findOne('Users', { email });
        if (!user) {
            throw new Error("We couldn't find an account with that email.");
        }
        
        const { auth, sendPasswordResetEmail, createUserWithEmailAndPassword } = await this.getFirebaseAuth();
        try {
            await sendPasswordResetEmail(auth, email);
        } catch (error) {
            // Lazy migration if they try to reset before ever logging in
            if (error.code === 'auth/user-not-found') {
                try {
                    await createUserWithEmailAndPassword(auth, user.email, user.password);
                    await sendPasswordResetEmail(auth, email);
                } catch (migrationError) {
                    throw new Error("An error occurred while sending the reset link.");
                }
            } else {
                throw new Error(error.message);
            }
        }
    }

    // Handle session state
    loginState(user) {
        // remove password from session
        const sessionUser = { ...user };
        delete sessionUser.password;
        
        this.currentUser = sessionUser;
        localStorage.setItem('currentUser', JSON.stringify(sessionUser));
        
        // Dispatch event for UI updates
        window.dispatchEvent(new Event('authStateChanged'));
    }

    logout() {
        this.currentUser = null;
        localStorage.removeItem('currentUser');
        window.dispatchEvent(new Event('authStateChanged'));
        window.location.href = 'index.html';
    }

    isLoggedIn() {
        return this.currentUser !== null;
    }

    getUser() {
        return this.currentUser;
    }

    requireAuth(redirectUrl = window.location.href) {
        if (!this.isLoggedIn()) {
            // Save where we wanted to go
            localStorage.setItem('authRedirect', redirectUrl);
            window.location.href = 'login.html';
            return false;
        }
        return true;
    }

    // Cart Management functions
    async mergeCart(userId) {
        // Merge guest cart logic
        const guestCart = JSON.parse(localStorage.getItem('guestCart')) || [];
        if (guestCart.length > 0) {
            let userCart = await DB.findOne('Cart', { userId });
            if (!userCart) {
                userCart = await DB.insert('Cart', { userId, products: [] });
            }
            
            // simple merge, appending
            userCart.products = [...userCart.products, ...guestCart];
            await DB.update('Cart', userCart.id, { products: userCart.products });
            
            // clear guest cart
            localStorage.removeItem('guestCart');
        }
    }
}

const Auth = new AuthController();
