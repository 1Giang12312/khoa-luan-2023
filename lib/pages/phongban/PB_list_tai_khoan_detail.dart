import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/services/send_push_massage.dart';
import '../../data/UserID.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PBListTaiKhoanDetails extends StatefulWidget {
  PBListTaiKhoanDetails(this.itemId, this.isRouteGD, {Key? key})
      : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('tai_khoan').doc(itemId);
    _futureData = _reference.get();
  }
  bool isRouteGD;
  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<PBListTaiKhoanDetails> createState() => _PBListTaiKhoanDetailsState();
}

class _PBListTaiKhoanDetailsState extends State<PBListTaiKhoanDetails> {
  late Map data;
  var todaynow = DateTime.now().toString();
  // var _email_PB = '';
  // var _app_Password = '';
  // var _ten_PB = '';
  // var _email_TK = '';
  // var _trang_thai = '';
  // var _quyen_han = '';
  // var _button_trang_thai = '';
  var fCMtoken = '';
  DateTime now = DateTime.now();
  String quyenHan = '';
  String trang_thai = '';
  var _button_trang_thai = '';
  var email_tai_khoan = '';
  var ten_tai_khoan = '';
  var emailTP = '';
  var appPasswordTP = '';
  @override
  void initState() {
    super.initState();
    getName();
    // print(_email_PB);
    // print(_app_Password);
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    // print(_formattedNgaydx);
    //_selectedDate = widget.selectedDate ?? DateTime.now();

    // setState(() {
    //   isLoading = true;
    // });

    //  setState(() {
    //   isLoading = false;
    // });
  }

  getName() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(widget.itemId).get();
    final _email = userDoc['email'];
    final _ten = userDoc['ten'];
    fCMtoken = userDoc['FCMtoken'];
    email_tai_khoan = _email;
    ten_tai_khoan = _ten;

    final truongPhongCollection =
        FirebaseFirestore.instance.collection('tai_khoan');
    final userTP = await truongPhongCollection.doc(UserID.localUID).get();
    emailTP = userTP['email'];
    appPasswordTP = userTP['app_password'];

    print(emailTP);
    setState(() {});
    //print(tenPB);
  }

  void sendMail(String noi_dung) async {
    //var userEmail = _email_PB;
    final smtpServer = gmail(emailTP.toString(), appPasswordTP);
    final message = Message()
      ..from = Address(emailTP.toString(), ten_tai_khoan)
      ..recipients.add(email_tai_khoan.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Tài khoản' + ten_tai_khoan + ' đã ${noi_dung}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "Tài khoản đã bị khoá tài khoản vào ngày: " +
          now.toString() +
          ' bởi trưởng phòng ';
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
  // // Future<void> disableUserAccount(String uid) async {
  // //   final HttpsCallable callable =
  // //       FirebaseFunctions.instance.httpsCallable('disableUserAccount');
  // //   final result = await callable.call({'uid': uid});
  // //   if (result.data != null) {
  // //     print(result.data['message']);
  // //   } else if (result.data['error'] != null) {
  // //     print(result.data['error']);
  // //   }
  // // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết phòng ban'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget._futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            //Get the data
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;
            // if (data['trang_thai'] == true) {
            //   _trang_thai = 'Đang hoạt động';
            //   _button_trang_thai = 'Khóa tài khoản';
            // } else {
            //   _trang_thai = 'Đang bị khoá';
            //   _button_trang_thai = 'Mở khóa tài khoản';
            // }
            // if (data['quyen_han'] == 'PB') {
            //   _quyen_han = 'Phòng ban';
            // } else if (data['quyen_han'] == 'TK') {
            //   _quyen_han = 'Thư kí';
            // } else
            //   _quyen_han = 'Giám đốc';
            if (data['quyen_han_id'] == 'TVPB') {
              quyenHan = 'Thành viên phòng ban';
            } else if (data['quyen_han_id'] == 'PPB') {
              quyenHan = 'Phó phòng ban';
            } else {
              quyenHan = 'Trưởng phòng ban';
            }
            if (data['trang_thai'] == true) {
              trang_thai = 'Đang hoạt động';
              _button_trang_thai = 'Khóa tài khoản';
            } else {
              trang_thai = 'Đang bị khoá';
              _button_trang_thai = 'Mở khóa tài khoản';
            }
            return ListView(
                // padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.grey[100],
                      // width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height * 0.5,
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'Thông tin tài khoản',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    'Tên phòng ban : ' + data['ten'],
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  )
                                ]),
                            Wrap(children: [
                              Text(
                                'Email: ${data['email']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            Wrap(children: [
                              Text(
                                'Số điện thoại: ${data['so_dien_thoai']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            Wrap(children: [
                              Text(
                                'Quyền hạn: ' + quyenHan,
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            Wrap(children: [
                              Text(
                                'Trạng thái: ${trang_thai}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    data['trang_thai']
                                        ?
                                        //hủy cv
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Khóa tài khoản"),
                                                content: Text(
                                                    "Bạn có chắc muốn khóa tài khoản này"),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: Text("Không"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: Text("Có"),
                                                    onPressed: () async {
                                                      //thư kí duyệt rồi thì dk
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'tai_khoan')
                                                          .doc(widget.itemId)
                                                          .update({
                                                        'trang_thai': false
                                                      });
//gửi mail
                                                      if (!kIsWeb) {
                                                        sendMail(
                                                            ' bị khoá tài khoản');
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PBListTaiKhoanDetails(
                                                                    widget
                                                                        .itemId,
                                                                    widget
                                                                        .isRouteGD)),
                                                      );
                                                      final snackBar = SnackBar(
                                                        content: Text(
                                                            'Khoá tài khoản thành công'),
                                                        action: SnackBarAction(
                                                          label: 'Tắt',
                                                          onPressed: () {
                                                            // Some code to undo the change.
                                                          },
                                                        ),
                                                      );
                                                      // Find the ScaffoldMessenger in the widget tree
                                                      // and use it to show a SnackBar.
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                        : showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    Text("Mở khóa tài khoản"),
                                                content: Text(
                                                    "Bạn có chắc muốn mở khóa tài khoản này"),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: Text("Không"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: Text("Có"),
                                                    onPressed: () async {
                                                      //thư kí duyệt rồi thì dk
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'tai_khoan')
                                                          .doc(widget.itemId)
                                                          .update({
                                                        'trang_thai': true
                                                      });
                                                      SendPushMessage(
                                                          fCMtoken,
                                                          'Lúc ' +
                                                              now.toString(),
                                                          'Bạn đã được mở khoá tài khoản',
                                                          'mo_khoa_tai_khoan');
                                                      addThongBao(
                                                          'Lúc ' +
                                                              now.toString() +
                                                              ' Bạn đã được mở khoá tài khoản',
                                                          'Bạn đã được mở khoá tài khoản',
                                                          widget.itemId,
                                                          todaynow);
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PBListTaiKhoanDetails(
                                                                    widget
                                                                        .itemId,
                                                                    widget
                                                                        .isRouteGD)),
                                                      );
                                                      final snackBar = SnackBar(
                                                        content: Text(
                                                            'Mở khóa tài khoản thành công'),
                                                        action: SnackBarAction(
                                                          label: 'Tắt',
                                                          onPressed: () {
                                                            // Some code to undo the change.
                                                          },
                                                        ),
                                                      );
                                                      // Find the ScaffoldMessenger in the widget tree
                                                      // and use it to show a SnackBar.
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                  },
                                  child: Text(
                                    _button_trang_thai,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ])))
                ]);
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
