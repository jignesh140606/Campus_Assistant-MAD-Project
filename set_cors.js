// Script to set CORS on Firebase Storage bucket using firebase-admin
// Run: node set_cors.js
const admin = require('firebase-admin');
const serviceAccount = require('./campus-assistant-3f1a7-firebase-adminsdk-fbsvc-a1daf6540c.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'campus-assistant-3f1a7.firebasestorage.app',
});

const corsConfig = [
  {
    origin: ['*'],
    method: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'],
    responseHeader: [
      'Content-Type',
      'Authorization',
      'Content-Length',
      'User-Agent',
      'x-goog-resumable',
    ],
    maxAgeSeconds: 3600,
  },
];

async function setCors() {
  try {
    const bucket = admin.storage().bucket();
    console.log('Bucket name:', bucket.name);
    await bucket.setCorsConfiguration(corsConfig);
    console.log(`✅ CORS set successfully on bucket: ${bucket.name}`);
  } catch (err) {
    console.error('❌ Failed:', err.message);
  }
}

setCors();
