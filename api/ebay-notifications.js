// eBay Marketplace Account Deletion Notification Endpoint
// Required for eBay API compliance

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  // eBay sends a GET challenge request to verify the endpoint
  if (req.method === 'GET') {
    const challengeCode = req.query.challenge_code;
    if (challengeCode) {
      // eBay challenge-response: hash challengeCode + verificationToken + endpoint URL
      const crypto = await import('crypto');
      const verificationToken = process.env.EBAY_VERIFICATION_TOKEN || 'tommyhq_ebay_verify_2026';
      const endpointUrl = 'https://tommy-hq.vercel.app/api/ebay-notifications';
      
      const hash = crypto.createHash('sha256')
        .update(challengeCode + verificationToken + endpointUrl)
        .digest('hex');
      
      return res.status(200).json({ challengeResponse: hash });
    }
    return res.status(200).json({ status: 'eBay notification endpoint active' });
  }

  // Handle actual deletion notifications (POST)
  if (req.method === 'POST') {
    // Log the notification (user data deletion request)
    const notification = req.body;
    console.log('eBay account deletion notification:', JSON.stringify(notification));
    // In a real app you'd delete any stored user data here
    // For our use case (listing Tommy's personal items) we don't store eBay user data
    return res.status(200).json({ acknowledged: true });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
