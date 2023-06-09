import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:khoa_luan1/pages/phongban/add_event.dart';
import 'package:khoa_luan1/services/calendar_sheet_api.dart';
import 'firebase_options.dart';
import 'register.dart';
import 'login.dart';
import 'pages/phongban/PB_home_page.dart';
import 'pages/thuki/TK_home_page.dart';
import 'pages/giamdoc/GD_home_page.dart';
import 'pages/thuki/duyet_event_list.dart';
import 'data/FCMtoken.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:io';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('background handler ${message.messageId}');
}

// void SendPushMessage(String token, String body, String title) async {
//   try {
//     await http.post(
//       Uri.parse('http://fcm.googleapis.com/fcm/send'),
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization':
//             'key=AAAAljFhcnQ:APA91bG5G3b-EvPM945TAhKrmN7n0ifmpNDNlhynEvo1FoSBD2KLHiUub2S2g2GscO4U0V5Sn5Ull3u4Ca0G1hN6Hzw5UlOwgUCYEgcOHEOP8q3_7kbAgorA633txp_raKsYXpoX_1h_',
//       },
//       body: jsonEncode(
//         <String, dynamic>{
//           'priority': 'high',
//           'data': <String, dynamic>{
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'status': 'done',
//             'body': body,
//             'title': title
//           },
//           "notification": <String, dynamic>{
//             "title": title,
//             "body": body,
//             "android_channel_id": "gd_to_do_list_day"
//           },
//           "to": token,
//         },
//       ),
//     );
//   } catch (e) {
//     if (kDebugMode) {
//       print('error push notification');
//     }
//   }
// }
Timestamp _xet_trang_thai_ts = Timestamp.fromDate(now);
void _doi_trang_thai_cong_viec(Timestamp _datetime_now) async {
  final eventsRef = FirebaseFirestore.instance.collection('cong_viec');
  final query = eventsRef
      .where('ngay_gio_ket_thuc', isLessThanOrEqualTo: _datetime_now)
      .where('tk_duyet', isEqualTo: true);

  final snapshot = await query.get();
  final docs = snapshot.docs;

  for (final doc in docs) {
    final ref = doc.reference;
    await ref.update({'trang_thai': false});
  }
  print('doi trang thai cong viec thanh cong');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await UserSheetAPI.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  // đổi trạng thái công việc
  _doi_trang_thai_cong_viec(_xet_trang_thai_ts);
  if (!kIsWeb) {
    //khởi tạo timezone
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
