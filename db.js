// db.js - Firebase Firestore Database Adapter
/*
### Database Structure

Users
* id
* name
* email
* mobile
* avatar
* password
* createdAt

Addresses
* id
* userId
* addressName
* receiverName
* receiverPhone
* fullAddress
* city
* state
* pincode

Cart
* id
* userId
* products
* quantity

Orders
* id
* userId
* orderNumber
* addressId
* status
* totalAmount

Wishlist
* id
* userId
* productId
*/

class FirebaseDB {
    constructor() {
        this.db = null;
        this.fs = null;
        this.initPromise = this.initFirebase();
    }

    async initFirebase() {
        const { initializeApp, getApps, getApp } = await import("https://www.gstatic.com/firebasejs/10.9.0/firebase-app.js");
        const { getFirestore, collection, addDoc, getDocs, getDoc, updateDoc, deleteDoc, doc, query, where } = await import("https://www.gstatic.com/firebasejs/10.9.0/firebase-firestore.js");
        
        const firebaseConfig = {
            apiKey: "AIzaSyC8NPDb0efimxJE_WHA3-rbmFdynla6TwI",
            authDomain: "studio-6539281913-cab55.firebaseapp.com",
            projectId: "studio-6539281913-cab55",
            storageBucket: "studio-6539281913-cab55.firebasestorage.app",
            messagingSenderId: "654131616933",
            appId: "1:654131616933:web:1411cc691a6fe9a700c14c"
        };

        // Prevent double initialization if checkout.html or another script already initialized Firebase
        const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();
        this.app = app;
        this.db = getFirestore(app);
        this.fs = { collection, addDoc, getDocs, getDoc, updateDoc, deleteDoc, doc, query, where };
    }

    // Insert a new record
    async insert(collectionName, data) {
        await this.initPromise;
        const newRecord = { ...data, createdAt: new Date().toISOString() };
        const docRef = await this.fs.addDoc(this.fs.collection(this.db, collectionName), newRecord);
        return { ...newRecord, id: docRef.id };
    }

    // Find matching records
    async find(collectionName, queryObj = {}) {
        await this.initPromise;
        const colRef = this.fs.collection(this.db, collectionName);
        let q = colRef;
        
        if (Object.keys(queryObj).length > 0) {
            const constraints = Object.keys(queryObj).map(key => this.fs.where(key, "==", queryObj[key]));
            q = this.fs.query(colRef, ...constraints);
        }
        
        const snapshot = await this.fs.getDocs(q);
        const results = [];
        snapshot.forEach(docSnap => {
            results.push({ ...docSnap.data(), id: docSnap.id });
        });
        return results;
    }

    // Find one matching record
    async findOne(collectionName, queryObj = {}) {
        const results = await this.find(collectionName, queryObj);
        return results.length > 0 ? results[0] : null;
    }

    // Update a record
    async update(collectionName, id, updateData) {
        await this.initPromise;
        const docRef = this.fs.doc(this.db, collectionName, id);
        const updated = { ...updateData, updatedAt: new Date().toISOString() };
        await this.fs.updateDoc(docRef, updated);
        
        // Fetch and return the complete updated document
        const snap = await this.fs.getDoc(docRef);
        return { ...snap.data(), id: snap.id };
    }

    // Delete a record
    async delete(collectionName, id) {
        await this.initPromise;
        const docRef = this.fs.doc(this.db, collectionName, id);
        await this.fs.deleteDoc(docRef);
        return true;
    }
}

// Export globally
window.DB = new FirebaseDB();
