const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
admin.initializeApp();

const ADVANTA_API_KEY = '79092490454bd042954416315dd6dbde';
const ADVANTA_PARTNER_ID = '12570';
const ADVANTA_SENDER_ID = 'JuaMobile';
const RECIPIENT_PHONE_NUMBER = '+254705893440', '+254727056335';

const TWILIO_ACCOUNT_SID = '';
const TWILIO_AUTH_TOKEN = '';
const TWILIO_PHONE_NUMBER = '+14155238886';

exports.sendSMS = functions.https.onCall(async (data, context) => {
  const message = data.message;
  const recipient = RECIPIENT_PHONE_NUMBER;
  const url = `https://quicksms.advantasms.com/api/services/sendsms/?apikey=${ADVANTA_API_KEY}&partnerID=${ADVANTA_PARTNER_ID}&message=${encodeURIComponent(message)}&shortcode=${ADVANTA_SENDER_ID}&mobile=${recipient}`;

  try {
    const response = await axios.get(url);
    if (response.status !== 200) {
      throw new Error('Failed to send SMS');
    }
    return { success: true, message: 'SMS sent successfully' };
  } catch (error) {
    console.error('Error sending SMS:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS');
  }
});

exports.sendWhatsApp = functions.https.onCall(async (data, context) => {
  const message = data.message;
  const recipient = `whatsapp:${RECIPIENT_PHONE_NUMBER}`;
  const from = `whatsapp:${TWILIO_PHONE_NUMBER}`;
  const url = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`;

  try {
    const response = await axios.post(
      url,
      new URLSearchParams({
        From: from,
        To: recipient,
        Body: message,
      }),
      {
        auth: {
          username: TWILIO_ACCOUNT_SID,
          password: TWILIO_AUTH_TOKEN,
        },
      }
    );
    if (response.status !== 201) {
      throw new Error('Failed to send WhatsApp message');
    }
    return { success: true, message: 'WhatsApp message sent successfully' };
  } catch (error) {
    console.error('Error sending WhatsApp message:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send WhatsApp message');
  }
});
