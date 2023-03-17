// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:timezone/timezone.dart' as tz;
// // class local_Notification_Service {
// //   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
// //       FlutterLocalNotificationsPlugin();
// //   final AndroidInitializationSettings _androidInitializationSettings =
// //       AndroidInitializationSettings('@mipmap/ic_launcher');
// //   void initaliseNotifications() async {
// //     InitializationSettings initializationSettings =
// //         InitializationSettings(android: _androidInitializationSettings);
// //     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
// //   }
// //   void sendNotificationPreDay() async {
// //     AndroidNotificationDetails androidNotificationDetails =
// //         AndroidNotificationDetails('gd_to_do_list_day', 'gd_to_do_list_day',
// //             importance: Importance.high,
// //             priority: Priority.high,
// //             playSound: true,
// //             sound: RawResourceAndroidNotificationSound('notification'));
// //     NotificationDetails notificationDetails =
// //         NotificationDetails(android: androidNotificationDetails);
// //     await _flutterLocalNotificationsPlugin.periodicallyShow(
// //         0, 'test', 'test show ngay', RepeatInterval.daily, notificationDetails);
// //   }
// //   Future<void> scheduleDailySixAMNotification() async {
// //     const androidPlatformChannelSpecifics = AndroidNotificationDetails(
// //         'repeatDailyAtSixAMChannel', 'Repeat Daily at 6 AM',
// //         importance: Importance.high,
// //         priority: Priority.high,
// //         channelShowBadge: true);
// //     const iOSPlatformChannelSpecifics = IOSNotificationDetails();
// //     const platformChannelSpecifics = NotificationDetails(
// //         android: androidPlatformChannelSpecifics,
// //         iOS: iOSPlatformChannelSpecifics);
// //     var time = Time(6, 0, 0);
// //     await _flutterLocalNotificationsPlugin.zonedSchedule(
// //         0,
// //         'Daily notification',
// //         'This notification repeats daily at 6 AM',
// //         _nextInstanceOfSixAM(),
// //         platformChannelSpecifics,
// //         androidAllowWhileIdle: true,
// //         uiLocalNotificationDateInterpretation:
// //             UILocalNotificationDateInterpretation.absoluteTime,
// //         payload: 'repeatDailyAtSixAM');
// //     print('Scheduled daily notification at ${time.toString()}');
// //   }
// //   tz.TZDateTime _nextInstanceOfSixAM() {
// //     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
// //     tz.TZDateTime scheduledDate =
// //         tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 30);
// //     if (scheduledDate.isBefore(now)) {
// //       scheduledDate = scheduledDate.add(const Duration(days: 1));
// //     }
// //     return scheduledDate;
// //   }
// // }
// import 'dart:html';
// import 'dart:js';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/subjects.dart';
// import '../data/account.dart';
// import '../login.dart';
// import '../pages/giamdoc/GD_home_page.dart';
// import '../pages/phongban/PB_home_page.dart';
// import '../pages/thuki/TK_home_page.dart';

// class NotificationApi {
//   static final _notification = FlutterLocalNotificationsPlugin();
//   static final onNotification = BehaviorSubject<String?>();

//   static Future _notificationDetails() async {
//     return NotificationDetails(
//       android: AndroidNotificationDetails(
//           'gd_to_do_list_day', 'gd_to_do_list_day',
//           importance: Importance.max),
//       iOS: IOSNotificationDetails(),
//     );
//   }

//   static Future init({bool initScheduled = false}) async {
//     final android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     final iOS = IOSInitializationSettings();
//     final settings = InitializationSettings(android: android, iOS: iOS);
//     _notification.initialize(settings,
//         onSelectNotification: (String? payload) async {
//       try {
//         if (payload != null && payload.isNotEmpty) {
//           if (account.tai_khoan == '' ||
//               account.mat_khau == '') //nếu chưa đăng nhập
//           {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (BuildContext context) {
//               return LoginPage();
//             }));
//           } else {
//             signIn(account.tai_khoan, account.mat_khau);
//           }
//         } else {}
//       } catch (e) {}
//       return;
//     });
//   }

//   void signIn(String email, String password) async {
//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final FirebaseAuth auth = FirebaseAuth.instance;
//       final User? user = auth.currentUser;
//       final uid = user?.uid;
//       account.tai_khoan = email.toString();
//       account.mat_khau = password.toString();
//       print(account.mat_khau + account.tai_khoan);
//       route();
//     } on FirebaseAuthException catch (e) {
//       print(e);
//     }
//   }

//   void route() {
//     User? user = FirebaseAuth.instance.currentUser;
//     var kk = FirebaseFirestore.instance
//         .collection('tai_khoan')
//         .doc(user!.uid)
//         .get()
//         .then((DocumentSnapshot documentSnapshot) {
//       if (documentSnapshot.exists) {
//         if (documentSnapshot.get('quyen_han') == "TK") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ThuKiHomePage(),
//             ),
//           );
//         }
//         if (documentSnapshot.get('quyen_han') == "GD") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => GiamDocHomePage(),
//             ),
//           );
//         } else if (documentSnapshot.get('quyen_han') == "PB") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PhongBanHomePage(),
//             ),
//           );
//         }
//       } else {
//         print('loi');
//       }
//     });
//   }

//   static Future showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async =>
//       _notification.show(id, title, body, await _notificationDetails(),
//           payload: payload);
// }
