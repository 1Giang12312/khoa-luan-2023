import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import '../../data/UserID.dart';
import '../../services/view_file_pdf.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'list_phong_ban.dart';

class ListPhongBanDetails extends StatefulWidget {
  ListPhongBanDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('tai_khoan').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ListPhongBanDetails> createState() => _ListPhongBanDetailsState();
}

class _ListPhongBanDetailsState extends State<ListPhongBanDetails> {
  late Map data;
  var _email_PB = '';
  var _app_Password = '';
  var _ten_PB = '';
  var _email_TK = '';
  var _trang_thai = '';
  var _quyen_han = '';
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
  }

  getName() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(widget.itemId).get();
    final _email = userDoc['email'];
    final _app_PW = userDoc['app_password'];
    final _ten = userDoc['ten'];

    _app_Password = _app_PW;
    _email_PB = _email;
    _ten_PB = _ten;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han', isEqualTo: 'TK')
        .limit(1)
        .get();

    _email_TK = querySnapshot.docs.first['email'];
    print(_email_TK);
    setState(() {});
    //print(tenPB);
  }

  void sendMail(String noi_dung, title) async {
    //var userEmail = _email_PB;
    final smtpServer = gmail(_email_PB.toString(), _app_Password);
    final message = Message()
      ..from = Address(_email_PB.toString(), _ten_PB)
      ..recipients.add(_email_TK.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Phòng ban ' + _ten_PB + ' đã ${noi_dung}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "sadf";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
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
            if (data['trang_thai'] == true) {
              _trang_thai = 'Đang hoạt động';
            } else {
              _trang_thai = 'Đang bị khoá';
            }
            if (data['quyen_han'] == 'PB') {
              _quyen_han = 'Phòng ban';
            } else
              _quyen_han = 'Giám đốc';
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
                                'Quyền hạn: ${_quyen_han}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
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
                                'Trạng thái: ${_trang_thai}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            Center(
                              child: Row(
                                children: [
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    elevation: 5.0,
                                    height: 40,
                                    onPressed: () async {
                                      //hủy cv
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Hủy công việc"),
                                            content: Text(
                                                "Bạn có chắc chắn muốn hủy công việc này?"),
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
                                                  //thư kí duyệt rồi thì dk

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
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Hủy",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    color: Colors.white,
                                  ),
                                  data['tk_duyet'] == true
                                      ? MaterialButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0))),
                                          elevation: 5.0,
                                          height: 40,
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 255, 0, 0),
                                                  title: Center(
                                                    child: Text(
                                                      'Bạn không thể sửa do thư kí đã duyệt',
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          color: Colors.blue[900],
                                          child: Text(
                                            "Sửa",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        )
                                      : MaterialButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0))),
                                          elevation: 5.0,
                                          height: 40,
                                          onPressed: () async {
                                            // final res =
                                            //     await Navigator.push<bool>(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) => EditItem(
                                            //       itemId: documentSnapshot.id,
                                            //     ),
                                            //   ),
                                            // );
                                            // if (res ?? false) {
                                            //   _loadFirestoreEvents();
                                            // }
                                          },
                                          color: Colors.blue[900],
                                          child: Text(
                                            "Sửa",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                ]);
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
