import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khoa_luan1/dashboard.dart';
import 'package:khoa_luan1/reset_password.dart';
import 'package:rxdart/rxdart.dart';
import 'pages/giamdoc/GD_home_page.dart';
import 'pages/thuki/TK_home_page.dart';
import 'pages/phongban/PB_home_page.dart';
import 'register.dart';
import 'data/FCMtoken.dart';
import 'pages/phongban/PB_home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'account_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local_notifications;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/UserID.dart';

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
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
    isLoggedIn().then((value) {
      if (value == true) {
        print('login tu dong');
        LoginAutomatic();
      } else {
        if (!kIsWeb) {
          flutterLocalNotificationsPlugin.cancelAll();
          print('đã tắt tất cả thông báo hẹn lịch');
        }
      }
    });
  }

  initInfo() async {
    //local_notifications
    final android = local_notifications.AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    final iOS = local_notifications.IOSInitializationSettings();
    final settings =
        local_notifications.InitializationSettings(android: android, iOS: iOS);
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('--onMessasge--');
      print(
          'on message: ${message.notification?.title}/${message.notification?.body}');
      local_notifications.BigTextStyleInformation bigTextStyleInformation =
          local_notifications.BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      local_notifications.AndroidNotificationDetails
          andoroidPlatformChannelSpecifics =
          local_notifications.AndroidNotificationDetails(
        'tk_duyet', 'tk_duyet',
        importance: local_notifications.Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: local_notifications.Priority.high,
        // playSound: true,
        // sound: local_notifications.RawResourceAndroidNotificationSound(
        //     'notification'
        //     )
      );
      local_notifications.NotificationDetails platformChannelSpecifics =
          local_notifications.NotificationDetails(
              android: andoroidPlatformChannelSpecifics,
              iOS: const local_notifications.IOSNotificationDetails());
      await flutterLocalNotificationsPlugin.show(1, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['title']);
    });
  }

  Future<void> LoginAutomatic() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null || password != null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username!.trim(),
          password: password!.trim(),
        );
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        final uid = user?.uid;
        final usersCollection =
            FirebaseFirestore.instance.collection('tai_khoan');
        final userDoc = await usersCollection.doc(uid).get();
        final _trang_thai = userDoc['trang_thai'];
        if (_trang_thai == true) {
          saveUserCredentials(username, password);
          route();
          SaveorUpdateFCMToken(uid!);
        } else {
          showErrorMessage('Tài khoản bị khóa');
          setState(() {
            isLoading = false;
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showErrorMessage('Email không tồn tại');
        } else if (e.code == 'wrong-password') {
          showErrorMessage('Sai mật khẩu');
        }
      }
      setState(() {
        isLoading = false;
      });
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

  Future<void> saveUserCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  void getToken() async {
    if (!kIsWeb) {
      await FirebaseMessaging.instance.getToken().then((value) {
        setState(() {
          FCMtoken = value;
          print('token is ' + FCMtoken!);
        });
      });
    }
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
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Đang đăng nhập!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return "Email không được để trống";
                                  }
                                  // if (!RegExp("^[a-zA-Z0-9+_.-]+@agu.edu.vn")
                                  //     .hasMatch(value)) {
                                  //   return ("Hãy nhập mail agu");
                                  // }
                                  else {
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
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
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
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // MaterialButton(
                              //   shape: RoundedRectangleBorder(
                              //       borderRadius:
                              //           BorderRadius.all(Radius.circular(20.0))),
                              //   elevation: 5.0,
                              //   height: 40,
                              //   onPressed: () {
                              //     showScheduledNotification(
                              //         id: 0,
                              //         title: 'testtest',
                              //         body: 'test',
                              //         payload: 'thong bao',
                              //         scheduledDate:
                              //             DateTime.now().add(Duration(seconds: 5)));
                              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //       content: const Text('Sửa công việc thành công'),
                              //       action: SnackBarAction(
                              //         label: 'Hủy',
                              //         onPressed: () {},
                              //       ),
                              //     ));
                              //   },
                              //   child: Text(
                              //     "Thông tin cá nhân",
                              //     style: TextStyle(
                              //       fontSize: 20,
                              //     ),
                              //   ),
                              //   color: Colors.white,
                              // ),
                              //
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 5.0,
                                height: 40,
                                onPressed: () {
                                  signIn(emailController.text,
                                      passwordController.text);
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
                                onPressed: () async {
                                  final res = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ResetPassword(),
                                    ),
                                  );
                                },
                                color: Colors.blue[900],
                                child: Text(
                                  "Quên mật khẩu",
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

  void route() async {
    User? user = FirebaseAuth.instance.currentUser; //gán uid cho file local
    final uid = user?.uid;
    UserID.localUID = uid!;
    final quyenhanCollection =
        FirebaseFirestore.instance.collection('quyen_han');
    final taikhoanCollection =
        FirebaseFirestore.instance.collection('tai_khoan');

    final userID = UserID.localUID;

    final userDoc = await taikhoanCollection.doc(userID).get();
    final quyenHanID = userDoc['quyen_han_id'];
    final quyenHanDoc = await quyenhanCollection.doc(quyenHanID).get();
    final ten_quyen_han = quyenHanDoc['ten_quyen_han'];
    //lấy dữ liệu số lượng công việc mỗi ngày theo uid
    if (ten_quyen_han == 'Thư ký') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard('TK'),
        ),
      );
    } else if (ten_quyen_han == "Giám đốc") {
      if (!kIsWeb) {
        init();
        showScheduledNotification(
            id: 0,
            title: 'Công việc hôm nay',
            body: 'Xem danh sách công việc hôm nay',
            payload: 'thong bao',
            scheduledDate: DateTime.now().add(Duration(seconds: 5)));
      }
      print('đã bật hẹn lịch');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard('GD'),
        ),
      );
    } else if (ten_quyen_han == "Trưởng phòng ban") {
      if (!kIsWeb) {
        init();
        showScheduledNotification(
            id: 0,
            title: 'Công việc hôm nay',
            body: 'Xem danh sách công việc hôm nay',
            payload: 'thong bao',
            scheduledDate: DateTime.now().add(Duration(seconds: 5)));
      }
      print('đã bật hẹn lịch');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard('PB'),
        ),
      );
    } else if (ten_quyen_han == "Phó phòng ban") {
      if (!kIsWeb) {
        init();
        showScheduledNotification(
            id: 0,
            title: 'Công việc hôm nay',
            body: 'Xem danh sách công việc hôm nay',
            payload: 'thong bao',
            scheduledDate: DateTime.now().add(Duration(seconds: 5)));
      }
      print('đã bật hẹn lịch');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard('PB'),
        ),
      );
    } else if (ten_quyen_han == "Thành viên phòng ban") {
      if (!kIsWeb) {
        init();
        showScheduledNotification(
            id: 0,
            title: 'Công việc hôm nay',
            body: 'Xem danh sách công việc hôm nay',
            payload: 'thong bao',
            scheduledDate: DateTime.now().add(Duration(seconds: 5)));
      }
      print('đã bật hẹn lịch');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard('TVPB'),
        ),
      );
    } else {
      print('loi');
    }
    print(ten_quyen_han);
    // var kk = FirebaseFirestore.instance
    //     .collection('tai_khoan')
    //     .doc(user!.uid)
    //     .get()
    //     .then((DocumentSnapshot documentSnapshot) {
    //   if (documentSnapshot.exists) {
    //     if (documentSnapshot.get('quyen_han') == "TK") {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => DashBoard('TK'),
    //         ),
    //       );
    //     }
    //     if (documentSnapshot.get('quyen_han') == "GD") {
    //       if (!kIsWeb) {
    //         init();
    //         showScheduledNotification(
    //             id: 0,
    //             title: 'Công việc hôm nay',
    //             body: 'Xem danh sách công việc hôm nay',
    //             payload: 'thong bao',
    //             scheduledDate: DateTime.now().add(Duration(seconds: 5)));
    //       }
    //       print('đã bật hẹn lịch');
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => DashBoard('GD'),
    //         ),
    //       );
    //     } else if (documentSnapshot.get('quyen_han') == "PB") {
    //       if (!kIsWeb) {
    //         init();
    //         showScheduledNotification(
    //             id: 0,
    //             title: 'Công việc hôm nay',
    //             body: 'Xem danh sách công việc hôm nay',
    //             payload: 'thong bao',
    //             scheduledDate: DateTime.now().add(Duration(seconds: 5)));
    //       }

    //       print('đã bật hẹn lịch');
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => DashBoard('PB'),
    //         ),
    //       );
    //     }
    //   } else {
    //     print('loi');
    //   }
    //});
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
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection('tai_khoan').doc(uid).update({
      'FCMtoken': FCMtoken,
    });
    FCMtokenData.token = FCMtoken!;
    setState(() {
      isLoading = false;
    });
  }

  void signIn(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        final uid = user?.uid;
        final usersCollection =
            FirebaseFirestore.instance.collection('tai_khoan');
        final userDoc = await usersCollection.doc(uid).get();
        final _trang_thai = userDoc['trang_thai'];
        if (_trang_thai == true) {
          saveUserCredentials(email, password);
          route();
          SaveorUpdateFCMToken(uid!);
        } else {
          showErrorMessage('Tài khoản bị khóa');
          setState(() {
            isLoading = false;
          });
        }
        //bật tự động thông báo
        //không bật lịch cho thư kí
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showErrorMessage('Email không tồn tại');
        } else if (e.code == 'wrong-password') {
          showErrorMessage('Sai mật khẩu');
        } else if (e.code == 'user-disabled') {
          showErrorMessage('Tài khoản đã bị khoá');
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
