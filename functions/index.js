// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp(); 
// // // Create and deploy your first functions
// // // https://firebase.google.com/docs/functions/get-started
// //
// // exports.helloWorld = functions.https.onRequest((request, response) => {
// //   functions.logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });
// // const functions = require('firebase-functions');
// // const admin = require('firebase-admin');
// // admin.initializeApp();

// exports.sendNotificationOnDateChange=functions.firestore.document('cong_viec/{ngay_gio_bat_dau}').onUpdate(async(snap,context)=>{
//     const oldData = snap.before.data();
//     const newData=snap.after.data();
//     if(oldData.date!= newData.date){
//         var payload={
//             notification:{
//                 title:'Da duyet',
//                 body:'Thu ki da duyet cong viec' + newData.date,
//                 sound:'beep',
//                 channel_id:'tk_duyet_event'
//             }
//         }
//     }
// })
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.disableUserAccount = functions.https.onCall(async (data, context) => {
  try {
    const userRecord = await admin.auth().getUser(data.uid);
    await admin.auth().updateUser(data.uid, {disabled: true});
    console.log(`User account with uid ${data.uid} has been disabled`);
    return {message: `User account with uid ${data.uid} has been disabled`};
  } catch (e) {
    console.log(`Error disabling user account: ${e}`);
    return {error: `Error disabling user account: ${e}`};
  }
});