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
import 'package:khoa_luan1/pages/thuki/edit_dia_diem.dart';
import 'package:khoa_luan1/services/send_push_massage.dart';
import '../../data/UserID.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'list_cong_viec_phong_ban.dart';
import 'list_phong_ban.dart';

class ListDiaDiemDetails extends StatefulWidget {
  ListDiaDiemDetails(this.itemId, this.isRouteGD, {Key? key})
      : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('dia_diem').doc(itemId);
    _futureData = _reference.get();
  }
  bool isRouteGD;
  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ListDiaDiemDetails> createState() => _ListDiaDiemDetailsState();
}

class _ListDiaDiemDetailsState extends State<ListDiaDiemDetails> {
  late Map data;
  String trang_thai = '';
  var _button_trang_thai = '';
  // var _email_PB = '';
  // var _app_Password = '';
  // var _ten_PB = '';
  // var _email_TK = '';
  // var _trang_thai = '';
  // var _quyen_han = '';
  // var _button_trang_thai = '';
  // var fCMtoken = '';
  // DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết địa điểm'),
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
            if (data['trang_thai'] == true) {
              trang_thai = 'Đang hoạt động';
              _button_trang_thai = 'Khóa địa điểm';
            } else {
              trang_thai = 'Đang bị khoá';
              _button_trang_thai = 'Mở khóa địa điểm';
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
                                    'Thông tin địa điểm',
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
                                    'Tên địa điểm : ' + data['ten_dia_diem'],
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  )
                                ]),
                            Wrap(children: [
                              Text(
                                'Ghi chú: ${data['ghi_chu']}',
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
                                                title: Text("Khoá địa điểm"),
                                                content: Text(
                                                    "Bạn có chắc muốn khóa địa điểm này"),
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
                                                              'dia_diem')
                                                          .doc(widget.itemId)
                                                          .update({
                                                        'trang_thai': false
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ListDiaDiemDetails(
                                                                    widget
                                                                        .itemId,
                                                                    widget
                                                                        .isRouteGD)),
                                                      );
                                                      final snackBar = SnackBar(
                                                        content: Text(
                                                            'Khoá địa điểm thành công'),
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
                                                title: Text("Mở khóa địa điểm"),
                                                content: Text(
                                                    "Bạn có chắc muốn mở khóa địa điểm này"),
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
                                                              'dia_diem')
                                                          .doc(widget.itemId)
                                                          .update({
                                                        'trang_thai': true
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ListDiaDiemDetails(
                                                                    widget
                                                                        .itemId,
                                                                    widget
                                                                        .isRouteGD)),
                                                      );
                                                      final snackBar = SnackBar(
                                                        content: Text(
                                                            'Mở khóa địa điểm thành công'),
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
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    //sua phong ban

                                    // print(documentSnapshot.id);
                                    final res = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => EditDiaDiem(
                                              diaDiemID: documentSnapshot.id)),
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
                              ],
                            ),
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
