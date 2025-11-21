/**
 * SMS Service
 * TODO: Implement SMS sending logic (Twilio, AWS SNS, etc.)
 */

/**
 * Send OTP SMS
 * @param {string} phoneNumber - Recipient phone number
 * @param {string} otp - OTP code
 * @returns {Promise<void>}
 */
async function sendOtpSms(phoneNumber, otp) {
  // TODO: Implement SMS sending
  console.log(`Sending OTP ${otp} to ${phoneNumber}`);
  return Promise.resolve();
}

module.exports = {
  sendOtpSms,
};

