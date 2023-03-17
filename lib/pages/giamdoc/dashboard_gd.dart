import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class dashBoard_GD extends StatefulWidget {
  const dashBoard_GD({super.key});

  @override
  State<dashBoard_GD> createState() => _dashBoard_GDState();
}

class _dashBoard_GDState extends State<dashBoard_GD> {
  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   String? title = message.notification!.title;
    //   String? body = message.notification!.body;
    //   AwesomeNotifications().createNotification(
    //       content: NotificationContent(
    //           id: 123,
    //           channelKey: "gd_to_do_list_ngay",
    //           color: Colors.white,
    //           title: title,
    //           body: body,
    //           category: NotificationCategory.Call,
    //           wakeUpScreen: true,
    //           fullScreenIntent: true,
    //           autoDismissible: false,
    //           backgroundColor: Colors.orange),
    //       actionButtons: [
    //         NotificationActionButton(
    //             key: "đóng",
    //             label: 'đóng',
    //             color: Colors.green,
    //             autoDismissible: true),
    //         NotificationActionButton(
    //             key: "đóng",
    //             label: 'đóng',
    //             color: Colors.green,
    //             autoDismissible: true),
    //       ]);
    //   AwesomeNotifications().actionStream.listen((event) {
    //     print('bấm vào ');
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
