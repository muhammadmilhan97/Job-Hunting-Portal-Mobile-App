const sgMail = require('@sendgrid/mail');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { to, subject, text, html } = req.body;
  const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;

  if (!SENDGRID_API_KEY) {
    return res.status(500).json({ error: 'SendGrid API key not set' });
  }

  sgMail.setApiKey(SENDGRID_API_KEY);

  const msg = {
    to,
    from: 'your_verified_sender@example.com', // Replace with your verified sender
    subject,
    text,
    html,
  };

  try {
    await sgMail.send(msg);
    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}; 