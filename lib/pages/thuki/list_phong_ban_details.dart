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
import 'edit_phong_ban.dart';
import 'list_cong_viec_phong_ban.dart';
import 'list_phong_ban.dart';

class ListPhongBanDetails extends StatefulWidget {
  ListPhongBanDetails(this.itemId, this.isRouteGD, {Key? key})
      : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('phong_ban').doc(itemId);
    _futureData = _reference.get();
  }
  bool isRouteGD;
  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ListPhongBanDetails> createState() => _ListPhongBanDetailsState();
}

class _ListPhongBanDetailsState extends State<ListPhongBanDetails> {
  late Map data;
  // var _email_PB = '';
  // var _app_Password = '';
  // var _ten_PB = '';
  // var _email_TK = '';
  // var _trang_thai = '';
  // var _quyen_han = '';
  // var _button_trang_thai = '';
  // var fCMtoken = '';
  // DateTime now = DateTime.now();
  late bool isLoading = false;
  var soLuongTaiKhoanTrongPhongBan = 0;
  var idTruongPhong = '';
  var idPhoPhong = '';
  var tenTruongPhong = '';
  var soDienThoaiTruongPhong = '';
  var emailTruongPhong = '';

  var tenPhoPhong = '';
  var soDienThoaiPhoPhong = '';
  var emailPhoPhong = '';
  late bool kiemTraTruongPhong = true;
  late bool kiemTraPhoPhong = true;
  @override
  void initState() {
    super.initState();
    // getName();
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
    xuLiThongTinPhongBan();
    //  setState(() {
    //   isLoading = false;
    // });
  }

  xuLiThongTinPhongBan() async {
    setState(() {
      isLoading = true;
    });
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('phong_ban_id', isEqualTo: widget.itemId)
        .get();
    final List<DocumentSnapshot> documentSnapshots = querySnapshot.docs;
    soLuongTaiKhoanTrongPhongBan = documentSnapshots.length;
    //print(soLuongTaiKhoanTrongPhongBan);
    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Trưởng phòng ban')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idTruongPhong = docId!;

    //kiểm tra xem phòng ban đó có trưởng phòng chưa
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idTruongPhong)
        .where('phong_ban_id', isEqualTo: widget.itemId)
        .get();
    if (querySnapshot1.docs.isEmpty) {
      kiemTraTruongPhong = false;
    } else {
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection('tai_khoan')
          .where('quyen_han_id', isEqualTo: idTruongPhong)
          .where('phong_ban_id', isEqualTo: widget.itemId)
          .get();
      tenTruongPhong = querySnapshot1.docs.first['ten'];
      soDienThoaiTruongPhong = querySnapshot1.docs.first['so_dien_thoai'];
      emailTruongPhong = querySnapshot1.docs.first['email'];
    }

    final snapshot1 = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Phó phòng ban')
        .limit(1)
        .get();
    final docId1 = snapshot1.docs.isNotEmpty ? snapshot1.docs.first.id : null;
    idPhoPhong = docId1!;

    //kiểm tra xem phòng ban đó có trưởng phòng chưa
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idPhoPhong)
        .where('phong_ban_id', isEqualTo: widget.itemId)
        .get();
    if (querySnapshot2.docs.isEmpty) {
      kiemTraPhoPhong = false;
    } else {
      QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
          .collection('tai_khoan')
          .where('quyen_han_id', isEqualTo: idPhoPhong)
          .where('phong_ban_id', isEqualTo: widget.itemId)
          .limit(1)
          .get();
      tenPhoPhong = querySnapshot3.docs.first['ten'];
      soDienThoaiPhoPhong = querySnapshot3.docs.first['so_dien_thoai'];
      emailPhoPhong = querySnapshot3.docs.first['email'];
    }
    setState(() {
      isLoading = false;
    });
  }

  demTaiKhoanTrongPhongBan(String maPhongBan) async {}

  //lấy thông tin trưởng phòng + phó phòng
  void layThongTinTruongPhong() async {
    //lấy id trưởng phòng
  }

  void layThongTinPhoPhong() async {
    setState(() {
      isLoading = true;
    });
    //lấy id trưởng phòng
  }

  // getName() async {
  //   final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
  //   final userDoc = await usersCollection.doc(widget.itemId).get();
  //   final _email = userDoc['email'];
  //   final _ten = userDoc['ten'];
  //   fCMtoken = userDoc['FCMtoken'];
  //   _email_PB = _email;
  //   _ten_PB = _ten;
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('tai_khoan')
  //       .where('quyen_han', isEqualTo: 'TK')
  //       .limit(1)
  //       .get();
  //   _email_TK = querySnapshot.docs.first['email'];
  //   _app_Password = querySnapshot.docs.first['app_password'];
  //   ;
  //   print(_email_TK);
  //   setState(() {});
  //   //print(tenPB);
  // }
  // void sendMail(String noi_dung) async {
  //   //var userEmail = _email_PB;
  //   final smtpServer = gmail(_email_TK.toString(), _app_Password);
  //   final message = Message()
  //     ..from = Address(_email_TK.toString(), _ten_PB)
  //     ..recipients.add(_email_PB.toString())
  //     // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
  //     // ..bccRecipients.add(Address('bccAddress@example.com'))
  //     ..subject = 'Phòng ban ' + _ten_PB + ' đã ${noi_dung}'
  //     ..text = 'This is the plain text.\nThis is line 2 of the text part.'
  //     ..html = "Phòng ban đã bị khoá tài khoản vào ngày: " + now.toString();
  //   try {
  //     final sendReport = await send(message, smtpServer);
  //     print('Message sent: ' + sendReport.toString());
  //   } on MailerException catch (e) {
  //     print('Message not sent.');
  //     for (var p in e.problems) {
  //       print('Problem: ${p.code}: ${p.msg}');
  //     }
  //   }
  // }
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
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Đang tải!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: widget._futureData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Some error occurred ${snapshot.error}'));
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
                                          'Thông tin phòng ban',
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        Text(
                                          'Tên phòng ban : ' +
                                              data['ten_phong_ban'],
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ),
                                        )
                                      ]),
                                  Wrap(children: [
                                    Text(
                                      'Email: ${data['email']}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                      textAlign: TextAlign
                                          .left, // căn chỉnh văn bản (giữa, trái, phải)
                                    )
                                  ]),
                                  Wrap(children: [
                                    Text(
                                      'Số fax: ${data['fax']}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                    )
                                  ]),
                                  Wrap(children: [
                                    Text(
                                      'Số điện thoại: ${data['so_dien_thoai']}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                      textAlign: TextAlign
                                          .left, // căn chỉnh văn bản (giữa, trái, phải)
                                    )
                                  ]),
                                  // Wrap(children: [
                                  //   Text(
                                  //     'Số fax: ${data['fax']}',
                                  //     style: TextStyle(
                                  //       color: Color.fromARGB(
                                  //           255, 0, 0, 0), // màu sắc của văn bản
                                  //       fontSize: 20, // kích thước của văn bản
                                  //     ),
                                  //     textAlign: TextAlign
                                  //         .left, // căn chỉnh văn bản (giữa, trái, phải)
                                  //   )
                                  // ]),
//                             Wrap(children: [
//                               Text(
//                                 'Trạng thái: ${_trang_thai}',
//                                 style: TextStyle(
//                                   color: Color.fromARGB(
//                                       255, 0, 0, 0), // màu sắc của văn bản
//                                   fontSize: 20, // kích thước của văn bản
//                                 ),
//                                 textAlign: TextAlign
//                                     .left, // căn chỉnh văn bản (giữa, trái, phải)
//                               )
//                             ]),
//                             Visibility(
//                                 visible: !widget.isRouteGD,
//                                 child: Wrap(
//                                   crossAxisAlignment: WrapCrossAlignment.start,
//                                   children: [
//                                     MaterialButton(
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(20.0))),
//                                       elevation: 5.0,
//                                       height: 40,
//                                       onPressed: () async {
//                                         data['trang_thai']
//                                             ?
//                                             //hủy cv
//                                             showDialog(
//                                                 context: context,
//                                                 builder:
//                                                     (BuildContext context) {
//                                                   return AlertDialog(
//                                                     title:
//                                                         Text("Khóa tài khoản"),
//                                                     content: Text(
//                                                         "Bạn có chắc muốn khóa tài khoản này"),
//                                                     actions: <Widget>[
//                                                       ElevatedButton(
//                                                         child: Text("Không"),
//                                                         onPressed: () {
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                         },
//                                                       ),
//                                                       ElevatedButton(
//                                                         child: Text("Có"),
//                                                         onPressed: () async {
//                                                           //thư kí duyệt rồi thì dk
//                                                           await FirebaseFirestore
//                                                               .instance
//                                                               .collection(
//                                                                   'tai_khoan')
//                                                               .doc(
//                                                                   widget.itemId)
//                                                               .update({
//                                                             'trang_thai': false
//                                                           });
// //gửi mail
//                                                           if (!kIsWeb) {
//                                                             sendMail(
//                                                                 ' bị khoá tài khoản');
//                                                           }
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                           Navigator
//                                                               .pushReplacement(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                                 builder: (context) =>
//                                                                     ListPhongBanDetails(
//                                                                         widget
//                                                                             .itemId,
//                                                                         widget
//                                                                             .isRouteGD)),
//                                                           );
//                                                           final snackBar =
//                                                               SnackBar(
//                                                             content: Text(
//                                                                 'Khoá tài khoản thành công'),
//                                                             action:
//                                                                 SnackBarAction(
//                                                               label: 'Tắt',
//                                                               onPressed: () {
//                                                                 // Some code to undo the change.
//                                                               },
//                                                             ),
//                                                           );
//                                                           // Find the ScaffoldMessenger in the widget tree
//                                                           // and use it to show a SnackBar.
//                                                           ScaffoldMessenger.of(
//                                                                   context)
//                                                               .showSnackBar(
//                                                                   snackBar);
//                                                         },
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               )
//                                             : showDialog(
//                                                 context: context,
//                                                 builder:
//                                                     (BuildContext context) {
//                                                   return AlertDialog(
//                                                     title: Text(
//                                                         "Mở khóa tài khoản"),
//                                                     content: Text(
//                                                         "Bạn có chắc muốn mở khóa tài khoản này"),
//                                                     actions: <Widget>[
//                                                       ElevatedButton(
//                                                         child: Text("Không"),
//                                                         onPressed: () {
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                         },
//                                                       ),
//                                                       ElevatedButton(
//                                                         child: Text("Có"),
//                                                         onPressed: () async {
//                                                           //thư kí duyệt rồi thì dk
//                                                           await FirebaseFirestore
//                                                               .instance
//                                                               .collection(
//                                                                   'tai_khoan')
//                                                               .doc(
//                                                                   widget.itemId)
//                                                               .update({
//                                                             'trang_thai': true
//                                                           });
//                                                           SendPushMessage(
//                                                               fCMtoken,
//                                                               'Lúc ' +
//                                                                   now.toString(),
//                                                               'Bạn đã được mở khoá tài khoản',
//                                                               'mo_khoa_tai_khoan');
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                           Navigator
//                                                               .pushReplacement(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                                 builder: (context) =>
//                                                                     ListPhongBanDetails(
//                                                                         widget
//                                                                             .itemId,
//                                                                         widget
//                                                                             .isRouteGD)),
//                                                           );
//                                                           final snackBar =
//                                                               SnackBar(
//                                                             content: Text(
//                                                                 'Mở khóa tài khoản thành công'),
//                                                             action:
//                                                                 SnackBarAction(
//                                                               label: 'Tắt',
//                                                               onPressed: () {
//                                                                 // Some code to undo the change.
//                                                               },
//                                                             ),
//                                                           );
//                                                           // Find the ScaffoldMessenger in the widget tree
//                                                           // and use it to show a SnackBar.
//                                                           ScaffoldMessenger.of(
//                                                                   context)
//                                                               .showSnackBar(
//                                                                   snackBar);
//                                                         },
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               );
//                                       },
//                                       child: Text(
//                                         _button_trang_thai,
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                         ),
//                                       ),
//                                       color: Colors.white,
//                                     ),
//                                     MaterialButton(
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(20.0))),
//                                       elevation: 5.0,
//                                       height: 40,
//                                       onPressed: () async {
//                                         // final res =
//                                         //     await Navigator.push<bool>(
//                                         //   context,
//                                         //   MaterialPageRoute(
//                                         //     builder: (_) => EditItem(
//                                         //       itemId: documentSnapshot.id,
//                                         //     ),
//                                         //   ),
//                                         // );
//                                         // if (res ?? false) {
//                                         //   _loadFirestoreEvents();
//                                         // }
//                                         final res = await Navigator.push<bool>(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 ListCongViecPhongBan(
//                                               itemId: documentSnapshot.id,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       color: Colors.blue[900],
//                                       child: Text(
//                                         "Xem công việc",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
                                  Wrap(children: [
                                    Text(
                                      'Gồm : ' +
                                          soLuongTaiKhoanTrongPhongBan
                                              .toString() +
                                          ' thành viên',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                      textAlign: TextAlign
                                          .left, // căn chỉnh văn bản (giữa, trái, phải)
                                    )
                                  ]),
                                  Visibility(
                                    visible: kiemTraTruongPhong,
                                    child: Row(
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
                                            'Thông tin trưởng phòng',
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
                                  ),
                                  Visibility(
                                    visible: kiemTraTruongPhong,
                                    child: Wrap(children: [
                                      Text('Tên: ' + tenTruongPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                    visible: kiemTraTruongPhong,
                                    child: Wrap(children: [
                                      Text(
                                          'Số điện thoại: ' +
                                              soDienThoaiTruongPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                    visible: kiemTraTruongPhong,
                                    child: Wrap(children: [
                                      Text('Email: ' + emailTruongPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                    visible: kiemTraPhoPhong,
                                    child: Row(
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
                                            'Thông tin phó phòng',
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
                                  ),
                                  Visibility(
                                    visible: kiemTraPhoPhong,
                                    child: Wrap(children: [
                                      Text('Tên: ' + tenPhoPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                    visible: kiemTraPhoPhong,
                                    child: Wrap(children: [
                                      Text(
                                          'Số điện thoại: ' +
                                              soDienThoaiPhoPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                    visible: kiemTraPhoPhong,
                                    child: Wrap(children: [
                                      Text('Email: ' + emailPhoPhong,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ))
                                    ]),
                                  ),
                                  Visibility(
                                      visible: !widget.isRouteGD,
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        elevation: 5.0,
                                        height: 40,
                                        onPressed: () async {
                                          //sua phong ban

                                          // print(documentSnapshot.id);
                                          final res =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => EditPhongBan(
                                                    phongBanID:
                                                        documentSnapshot.id)),
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
                                      ))
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
