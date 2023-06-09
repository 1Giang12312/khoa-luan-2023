import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khoa_luan1/pages/giamdoc/GD_list_cong_viec.dart';
import 'package:khoa_luan1/pages/phongban/PB_list_tai_khoan.dart';
import 'package:khoa_luan1/pages/phongban/PB_them_tai_khoan.dart';
import 'package:khoa_luan1/pages/phongban/list_cong_viec.dart';
import 'package:khoa_luan1/pages/thuki/list_tai_khoan.dart';
import 'package:khoa_luan1/pages/thuki/list_dia_diem.dart';
import 'package:khoa_luan1/pages/thuki/list_phong_ban.dart';
import 'package:khoa_luan1/pages/thuki/them_dia_diem.dart';
import 'package:khoa_luan1/pages/thuki/them_phong_ban.dart';
import 'package:khoa_luan1/register.dart';
import 'package:khoa_luan1/reset_password.dart';
import 'package:khoa_luan1/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_info.dart';
import 'delete_account_login.dart';
import 'login.dart';
import 'data/UserID.dart';
import 'pages/thuki/list_phong_ban.dart';

class AccountProfile extends StatefulWidget {
  String routeID;
  AccountProfile({super.key, required this.routeID});

  @override
  State<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  final _xac_nhanController = TextEditingController();
  bool isRouteTK = false;
  bool isRoutePB = false;
  bool isRouteGD = false;
  bool isRouteTVPB = false;
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.routeID == 'TK') {
      isRouteTK = true;
    } else if (widget.routeID == 'PB') {
      isRoutePB = true;
    } else if (widget.routeID == 'GD') {
      isRouteGD = true;
    } else if (widget.routeID == 'TVPB') {
      isRouteTVPB = true;
    }
    print(widget.routeID);
  }

  Future<void> EmptyFCMtoken(String uid) async {
    await FirebaseFirestore.instance.collection('tai_khoan').doc(uid).update({
      'FCMtoken': '',
    });
  }

  Future<void> logout(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    UserID.localUID = '';
    clearUserCredentials();
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[100],
          title: Text('Cài đặt  ', style: TextStyle(color: Colors.black)),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      "Đang xử lí!",
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
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                            Icon(Icons.password_outlined),
                            SizedBox(width: 20),
                            Expanded(child: Text('Đổi mật khẩu')),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !isRoutePB && !isRouteTVPB,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => ListPhongBan(
                                  isRouteGD: isRouteGD,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.list_alt_outlined),
                              SizedBox(width: 20),
                              Expanded(child: Text('Danh sách phòng ban')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRouteTK,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => Register(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add_box_outlined),
                              SizedBox(width: 20),
                              Expanded(child: Text('Thêm tài khoản')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRouteTK,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => ThemPhongBan(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add_box),
                              SizedBox(width: 20),
                              Expanded(child: Text('Thêm phòng ban')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRouteTK,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => ThemDiaDiem(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add_card_sharp),
                              SizedBox(width: 20),
                              Expanded(child: Text('Thêm địa điểm')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                              builder: (_) => ListDiaDiem(
                                isRouteGD: isRouteGD,
                                isRoutePB: isRoutePB,
                                isRouteTK: isRouteTK,
                                isRouteTVPB: isRouteTVPB,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.local_activity),
                            SizedBox(width: 20),
                            Expanded(child: Text('Danh sách địa điểm')),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRoutePB,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => ListCongViec(
                                  isRoteGD: false,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.list_outlined),
                              SizedBox(width: 20),
                              Expanded(child: Text('Danh sách công việc')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRouteGD,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => GDListCongviec(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.list_outlined),
                              SizedBox(width: 20),
                              Expanded(child: Text('Danh sách công việc')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRoutePB,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => PBThemTaiKhoan(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add_sharp),
                              SizedBox(width: 20),
                              Expanded(child: Text('Thêm tài khoản')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRoutePB,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => PBListTaiKhoan(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.list_alt_outlined),
                              SizedBox(width: 20),
                              Expanded(child: Text('Danh sách tài khoản')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isRouteTK,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                builder: (_) => ListTaiKhoan(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.list_sharp),
                              SizedBox(width: 20),
                              Expanded(child: Text('Danh sách tài khoản')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !isRouteGD && !isRouteTK,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.red[300],
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
                                  title: Text("Xoá tài khoản"),
                                  content: Text(
                                      "Bạn có chắc muốn xoá tài khoản này"),
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
                                          Navigator.of(context).pop();
                                          // FirebaseAuth auth = FirebaseAuth.instance;
                                          // User? user = auth.currentUser;
                                          // if (user != null) {
                                          //   AuthCredential credential =
                                          //       EmailAuthProvider.credential(
                                          //     email: username!,
                                          //     password: password!,
                                          //   );
                                          //   try {
                                          //     await user.reauthenticateWithCredential(
                                          //         credential);
                                          //     await user.delete();
                                          //     xoaCongViecLienQuan();
                                          //     logout(context);
                                          //     print(
                                          //         'User account deleted successfully!');
                                          //   } catch (e) {
                                          //     print(
                                          //         'Error deleting user account: $e');
                                          //   }
                                          // }
                                          // print('Xoá');
                                          final res =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DeleteAccountLogin(),
                                            ),
                                          );
                                        }),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 20),
                              Expanded(child: Text('Xoá tài khoản')),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                content:
                                    Text("Bạn có chắc chắn muốn đăng xuất?"),
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
                                      EmptyFCMtoken(UserID.localUID)
                                          .then((_) => logout(context));
                                      //logout(context);
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
