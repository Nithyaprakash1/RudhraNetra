const crypto = require('crypto');

module.exports = async (req, res) => {
    // Only allow POST
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body || {};

        if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
            return res.status(400).json({ error: 'Missing required payment fields' });
        }

        // HMAC-SHA256 signature verification
        const text = razorpay_order_id + "|" + razorpay_payment_id;
        const expectedSignature = crypto
            .createHmac('sha256', 'rY325HeuM82FbHqcShGmBa1s')
            .update(text.toString())
            .digest('hex');

        if (expectedSignature === razorpay_signature) {
            return res.status(200).json({ success: true, message: 'Payment verified successfully' });
        } else {
            return res.status(400).json({ success: false, error: 'Invalid signature' });
        }
    } catch (error) {
        console.error('Verification Error:', error);
        res.status(500).json({ error: 'Server error during verification' });
    }
};
