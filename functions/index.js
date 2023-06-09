const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.disableUser = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  await admin.auth().updateUser(uid, { disabled: true });
  return { success: true };
});