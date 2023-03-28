import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khoa_luan1/pages/thuki/list_phong_ban.dart';
import 'package:khoa_luan1/reset_password.dart';
import 'package:khoa_luan1/services/account_service.dart';

import 'account_info.dart';
import 'login.dart';
import 'data/UserID.dart';
import 'pages/thuki/list_phong_ban.dart';

class AccountProfile extends StatefulWidget {
  String routeID;
  AccountProfile({super.key, required this.routeID});

  @override
  State<AccountProfile> createState() => _AccountProfileState();
}

Future<void> logout(BuildContext context) async {
  CircularProgressIndicator();
  await FirebaseAuth.instance.signOut();
  // account.tai_khoan = '';
  // account.mat_khau = '';
  UserID.localUID = '';
  clearUserCredentials();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),
  );
}

class _AccountProfileState extends State<AccountProfile> {
  bool isRouteTK = false;
  @override
  void initState() {
    super.initState();
    if (widget.routeID == 'TK') {
      isRouteTK = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text('Cài đặt  ', style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () {
                    final result = Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AccountInfor(userIDString: UserID.localUID),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 20),
                      Expanded(child: Text('Tài khoản')),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () {
                    final result = Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResetPassword(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 20),
                      Expanded(child: Text('Đổi mật khẩu')),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isRouteTK,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      backgroundColor: Color(0xFFF5F6F9),
                    ),
                    onPressed: () {
                      final result = Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListPhongBan(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Expanded(child: Text('Danh sách phòng ban')),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Đăng xuất"),
                          content: Text("Bạn có chắc chắn muốn hủy đăng xuất?"),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text("Không"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: Text("Có"),
                              onPressed: () async {
                                logout(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 20),
                      Expanded(child: Text('Đăng xuất')),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
