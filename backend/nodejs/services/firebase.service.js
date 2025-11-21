const admin = require('firebase-admin');

let firebaseInitialized = false;

/**
 * Initialize Firebase Admin SDK
 * Only initializes if credentials are provided in environment variables
 */
function initializeFirebase() {
  if (firebaseInitialized) {
    return true;
  }

  // Check if Firebase credentials are provided
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

  if (!projectId || !privateKey || !clientEmail) {
    console.log('⚠️  Firebase credentials not found in .env');
    console.log('   Firebase features will be disabled');
    console.log('   App will use mock authentication for testing');
    return false;
  }

  try {
    const serviceAccount = {
      projectId: projectId,
      privateKey: privateKey.replace(/\\n/g, '\n'), // Handle escaped newlines
      clientEmail: clientEmail,
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized');
    return true;
  } catch (error) {
    console.error('❌ Firebase initialization error:', error.message);
    return false;
  }
}

/**
 * Verify Firebase ID Token
 * @param {string} idToken - Firebase ID token from client
 * @returns {Promise<object>} Decoded token with user info
 */
async function verifyIdToken(idToken) {
  if (!firebaseInitialized) {
    throw new Error('Firebase is not initialized');
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
}

/**
 * Get user by phone number
 * @param {string} phoneNumber - User's phone number
 * @returns {Promise<object>} User record
 */
async function getUserByPhoneNumber(phoneNumber) {
  if (!firebaseInitialized) {
    throw new Error('Firebase is not initialized');
  }

  try {
    const userRecord = await admin.auth().getUserByPhoneNumber(phoneNumber);
    return userRecord;
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      return null;
    }
    throw error;
  }
}

/**
 * Get user by email
 * @param {string} email - User's email
 * @returns {Promise<object>} User record
 */
async function getUserByEmail(email) {
  if (!firebaseInitialized) {
    throw new Error('Firebase is not initialized');
  }

  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    return userRecord;
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      return null;
    }
    throw error;
  }
}

/**
 * Create custom token for user
 * @param {string} uid - User ID
 * @param {object} additionalClaims - Additional claims to include in token
 * @returns {Promise<string>} Custom token
 */
async function createCustomToken(uid, additionalClaims = {}) {
  if (!firebaseInitialized) {
    throw new Error('Firebase is not initialized');
  }

  try {
    const customToken = await admin.auth().createCustomToken(uid, additionalClaims);
    return customToken;
  } catch (error) {
    throw new Error('Failed to create custom token');
  }
}

/**
 * Check if Firebase is initialized
 * @returns {boolean}
 */
function isFirebaseEnabled() {
  return firebaseInitialized;
}

module.exports = {
  initializeFirebase,
  verifyIdToken,
  getUserByPhoneNumber,
  getUserByEmail,
  createCustomToken,
  isFirebaseEnabled,
  admin: firebaseInitialized ? admin : null,
};
