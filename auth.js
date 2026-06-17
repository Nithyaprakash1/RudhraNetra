// auth.js - Authentication Controller

class AuthController {
    constructor() {
        this.currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;
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

        const newUser = {
            name,
            email,
            mobile,
            password, // In a real app, this would be hashed
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

        if (!user || user.password !== password) {
            throw new Error("Invalid credentials");
        }

        this.loginState(user);
        
        // Merge guest cart to user cart
        this.mergeCart(user.id);

        return user;
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
