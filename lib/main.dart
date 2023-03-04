import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khoa_luan1/pages/phongban/add_event.dart';
import 'firebase_options.dart';
import 'register.dart';
import 'login.dart';
import 'pages/phongban/PB_home_page.dart';
import 'pages/thuki/TK_home_page.dart';
import 'pages/giamdoc/GD_home_page.dart';
import 'pages/thuki/duyet_event_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: PhongBanHomePage(),
    );
  }
}
