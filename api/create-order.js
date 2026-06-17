const Razorpay = require('razorpay');

module.exports = async (req, res) => {
    // Only allow POST
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    try {
        const { amount, currency = 'INR', receipt } = req.body || {};

        if (!amount || amount < 100) {
            return res.status(400).json({ error: 'Invalid amount. Must be at least 100 paise.' });
        }

        const razorpay = new Razorpay({
            key_id: process.env.RAZORPAY_KEY_ID,
            key_secret: process.env.RAZORPAY_KEY_SECRET,
        });

        const options = {
            amount: amount,
            currency: currency,
            receipt: receipt || 'receipt_' + Date.now()
        };

        const order = await razorpay.orders.create(options);
        res.status(200).json({ ...order, key_id: process.env.RAZORPAY_KEY_ID });
    } catch (error) {
        console.error('Razorpay Error:', error);
        res.status(500).json({ error: 'Failed to create order' });
    }
};
