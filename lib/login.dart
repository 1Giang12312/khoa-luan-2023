import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'pages/giamdoc/GD_home_page.dart';
import 'pages/thuki/TK_home_page.dart';
import 'pages/phongban/PB_home_page.dart';
import 'register.dart';
import 'data/FCMtoken.dart';
import 'pages/giamdoc/dashboard_gd.dart';
import 'pages/phongban/PB_home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'account_info.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();
  String? FCMtoken = '';
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _auth = FirebaseAuth.instance;
  final onNotification = BehaviorSubject<String?>();
  // local_Notification_Service notificationsServices =
  //     local_Notification_Service();
  bool _rememberMe = true;
  late SharedPreferences _prefs;
  bool isThuKi = true;
  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    isLoggedIn().then((value) {
      if (value == true) {
        print('login tu dong');
        LoginAutomatic();
      } else {
        flutterLocalNotificationsPlugin.cancelAll();
        print('đã tắt tất cả thông báo hẹn lịch');
      }
    });
  }

  Future<void> LoginAutomatic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null || password != null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username!,
          password: password!,
        );
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        final uid = user?.uid;
        saveUserCredentials(username, password);
        route();
        SaveorUpdateFCMToken(uid!);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showErrorMessage('Email không tồn tại');
        } else if (e.code == 'wrong-password') {
          showErrorMessage('Sai mật khẩu');
        }
      }
    }
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if ((username != null && password != null)) {
      return true;
    } else
      return false;
  }

  // void listenNotifications() {
  //   onNotification.stream.listen(onClickedNotification);
  // }
  // void onClickedNotification(String? payload) {
  //   if (account.tai_khoan == '' || account.mat_khau == '') //nếu chưa đăng nhập
  //   {
  //     Navigator.of(context)
  //         .push(MaterialPageRoute(builder: (context) => LoginPage()));
  //     return;
  //   } else {
  //     signIn(account.tai_khoan, account.mat_khau);
  //   }
  //   // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
  //   //   return AccountInfor(
  //   //     userIDString: '7u9eGNSVYDejmxky9Qon9WOm2xC2',
  //   //   );
  //   // }));
  // }
  // // Future<String> checkRoute() async {
  //   final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
  //   final orderDoc = await usersCollection.doc().get();
  //   if (orderDoc['quyen_han'] == 'GD') {
  //     return 'GD';
  //   } else if (orderDoc['quyen_han'] == 'PB') {
  //     return 'PB';
  //   } else
  //     return 'TK';
  // }
  // void listenNotification() {
  //   NotificationApi.onNotification.stream.listen(onClickedNotification);
  // }
  // void onClickedNotification(String? payload) {
  //   if (account.tai_khoan == '' || account.mat_khau == '') {
  //     print('chưa đăng nhập');
  //   } else {
  //     if (checkRoute() == 'GD') {
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (context) => dashBoard_GD()));
  //     } else if (checkRoute() == 'PB') {
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (context) => PhongBanHomePage()));
  //     }
  //   }
  // }
  // Future<void> autoLoginByFCMToken(String FCMToken) async {
  //   var _getFCMToken = FirebaseFirestore.instance
  //       .collection('tai_khoan')
  //       .where('FCMtoken', isEqualTo: FCMToken);
  //   if (_getFCMToken == null) {
  //     //hiện trang đăng nhập
  //     return;
  //   } else {
  //      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('tai_khoan')
  //       .where('FCMtoken', isEqualTo: FCMToken)
  //       .limit(1)
  //       .get();
  //     String taiKhoan = querySnapshot.docs.first['email'];
  //   }
  // }
  Future<void> saveUserCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        FCMtoken = value;
        print('token is ' + FCMtoken!);
      });
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else {
      print('user declined');
    }
  }

  Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'gd_to_do_list_day',
        'gd_to_do_list_day',
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails(),
    );
  }
  //when app close

  Future init({bool initScheduled = false}) async {
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(details.payload);
      return;
    }
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(settings,
        onSelectNotification: (payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return LoginPage();
          }));
        }
      } catch (e) {
        print(e);
      }
      return;
      // onNotification.add(payload);
    });
    if (initScheduled) {
      final String timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }
  }

  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      flutterLocalNotificationsPlugin.show(
          id, title, body, await _notificationDetails(),
          payload: payload);

  tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }

  tz.TZDateTime _scheduleWeekly(Time time, {required List<int> day}) {
    tz.TZDateTime scheduledDate = _scheduleDaily(time);
    while (!day.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          _scheduleWeekly(Time(6), day: [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday
          ]), //thong bao luc 6h sang thu 2 -> thu 7
          await _notificationDetails(),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              // color: Colors.grey[100],
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.70,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Email',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Email không được để trống";
                            }
                            if (!RegExp("^[a-zA-Z0-9+_.-]+@agu.edu.vn")
                                .hasMatch(value)) {
                              return ("Hãy nhập mail agu");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure3,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure3
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure3 = !_isObscure3;
                                  });
                                }),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Mật khẩu',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Mật khẩu không được để trống!";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Mật khẩu phải dài hơn 6 kí tự!");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          elevation: 5.0,
                          height: 40,
                          onPressed: () {
                            showScheduledNotification(
                                id: 0,
                                title: 'testtest',
                                body: 'test',
                                payload: 'thong bao',
                                scheduledDate:
                                    DateTime.now().add(Duration(seconds: 5)));

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Sửa công việc thành công'),
                              action: SnackBarAction(
                                label: 'Hủy',
                                onPressed: () {},
                              ),
                            ));
                          },
                          child: Text(
                            "Thông tin cá nhân",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          elevation: 5.0,
                          height: 40,
                          onPressed: () {
                            setState(() {
                              visible = true;
                            });
                            signIn(
                                emailController.text, passwordController.text);
                          },
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          elevation: 5.0,
                          height: 40,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                          color: Colors.blue[900],
                          child: Text(
                            "Đăng kí",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        // Visibility(
                        //     maintainSize: true,
                        //     maintainAnimation: true,
                        //     maintainState: true,
                        //     visible: visible,
                        //     child: Container(
                        //         child: CircularProgressIndicator(
                        //       color: Colors.white,
                        //     ))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    //lấy dữ liệu số lượng công việc mỗi ngày theo uid
    var kk = FirebaseFirestore.instance
        .collection('tai_khoan')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('quyen_han') == "TK") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThuKiHomePage(),
            ),
          );
        }
        if (documentSnapshot.get('quyen_han') == "GD") {
          init();
          showScheduledNotification(
              id: 0,
              title: 'Công việc hôm nay',
              body: 'Xem danh sách công việc hôm nay',
              payload: 'thong bao',
              scheduledDate: DateTime.now().add(Duration(seconds: 5)));
          print('đã bật hẹn lịch');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GiamDocHomePage(),
            ),
          );
        } else if (documentSnapshot.get('quyen_han') == "PB") {
          init();
          showScheduledNotification(
              id: 0,
              title: 'Công việc hôm nay',
              body: 'Xem danh sách công việc hôm nay',
              payload: 'thong bao',
              scheduledDate: DateTime.now().add(Duration(seconds: 5)));
          print('đã bật hẹn lịch');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhongBanHomePage(),
            ),
          );
        }
      } else {
        print('loi');
      }
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void SaveorUpdateFCMToken(String uid) async {
    await FirebaseFirestore.instance.collection('tai_khoan').doc(uid).update({
      'FCMtoken': FCMtoken,
    });
    FCMtokenData.token = FCMtoken!;
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        final uid = user?.uid;

        saveUserCredentials(email, password);
        route();
        SaveorUpdateFCMToken(uid!);
        //bật tự động thông báo
        //không bật lịch cho thư kí
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showErrorMessage('Email không tồn tại');
        } else if (e.code == 'wrong-password') {
          showErrorMessage('Sai mật khẩu');
        }
      }
    }
  }
}
