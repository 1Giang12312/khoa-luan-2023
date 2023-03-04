import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class DuyetYeuCauHuyDetail extends StatefulWidget {
  DuyetYeuCauHuyDetail(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<DuyetYeuCauHuyDetail> createState() => _DuyetYeuCauHuyDetailState();
}

class _DuyetYeuCauHuyDetailState extends State<DuyetYeuCauHuyDetail> {
  late Map data;
  var tenPB = '';
  var _email_TK = '';
  var _email_PB = '';
  var _email_GD = '';
  var _ten_GD = '';
  var _app_password = '';
  var _ten_TK = '';

  var _ngay_toi_thieu = '';
  var _rool = '';
  var _tieu_de = '';
  var _ten_cong_viec = '';
  var _thoi_gian_dien_ra = '';
  var _dia_diem = '';
  var _ngay_dien_ra = '';
  @override
  void initState() {
    super.initState();
    getName();
    print(tenPB);
  }

  getName() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final eventCollection = FirebaseFirestore.instance.collection('cong_viec');
    final orderId = widget.itemId;
    final orderDoc = await eventCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();
    //phòng ban
    final userName = userDoc['ten'];
    tenPB = userName;
    final _emailPB = userDoc['email'];
    _email_PB = _emailPB; //email phòng ban

    //thư kí
    final thuKiDoc = await usersCollection.doc(uid).get();
    final _emailTK = thuKiDoc['email'];
    final _tenTK = thuKiDoc['ten'];
    final _appPassword = thuKiDoc['app_password'];
    _email_TK = _emailTK;
    _ten_TK = _tenTK;
    _app_password = _appPassword;

    //chọn event
    final eventDoc = await eventCollection.doc(widget.itemId).get();
    final _tieu_De = eventDoc['tieu_de'];
    final _ten_cong_Viec = eventDoc['ten_cong_viec'];
    final _thoi_gian_dien_Ra = eventDoc['thoi_gian_cv'];
    final _dia_Diem = eventDoc['dia_diem'];
    final uu_tien = eventDoc['do_uu_tien'];
    DateTime ngay_toi_thieuDate = data['ngay_toi_thieu'].toDate();
    _ngay_toi_thieu = DateFormat('dd/MM/yyyy').format(ngay_toi_thieuDate);
    DateTime _ngay_dien_raDate = data['ngay_gio_bat_dau'].toDate();
    _ngay_dien_ra = DateFormat('dd/MM/yyyy').format(_ngay_dien_raDate);

    _tieu_de = _tieu_De;
    _ten_cong_viec = _ten_cong_Viec;
    _thoi_gian_dien_ra = _thoi_gian_dien_Ra;
    _dia_diem = _dia_Diem;
    _rool = uu_tien;

    //giám dốc
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han', isEqualTo: 'GD')
        .limit(1)
        .get();
    _email_GD = querySnapshot.docs.first['email'];
    _ten_GD = querySnapshot.docs.first['ten'];
  }

  void sendMail(String thongBao) async {
    // var userEmail = _email_PB;
    final smtpServer = gmail(_email_TK.toString(), _app_password);
    final message = Message()
      ..from = Address(_email_GD.toString(), _ten_GD)
      ..recipients.add(_email_TK.toString())
      //..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      ..bccRecipients.add(Address(_email_PB.toString()))
      ..subject =
          'Thư kí ' + _ten_TK + ' đã ' + thongBao + ' yêu cầu huỷ công việc'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc </h1>\n<h2>-Tiêu đề: ${_tieu_de}</h2>\n<h2>-Tên(chi tiết): ${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_ra} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Ngày đề xuất : ${_ngay_toi_thieu}</h2>\n<h2>-Độ ưu tiên : ${_rool}</h2>";

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
        title: Text('Chi tiết công việc hủy'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget._futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;

            DateTime ngay_bat_dau = data['ngay_gio_bat_dau'].toDate();
            DateTime gio_ket_thuc;
            DateTime ngay_post = data['ngay_post'].toDate();
            DateTime ngay_thoi_thieu = data['ngay_toi_thieu'].toDate();
            String ngay_toi_thieu_string =
                DateFormat('dd/MM/yyyy').format(ngay_thoi_thieu);
            String ngay_post_string =
                DateFormat('dd/MM/yyyy').format(ngay_post);
            String formattedDay = DateFormat('dd/MM/yyyy').format(ngay_bat_dau);
            String formattedTime = DateFormat('HH:mm').format(ngay_bat_dau);
            int thoi_gian_cv = int.parse(data['thoi_gian_cv']);
            gio_ket_thuc = ngay_bat_dau.add(Duration(minutes: thoi_gian_cv));
            // String formattedDayEnd =
            //     DateFormat('dd/MM/yyyy').format(gio_ket_thuc);
            String formattedTimeEnd = DateFormat('HH:mm').format(gio_ket_thuc);
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
                                    'Tiêu đề:${data['tieu_de']}',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  )
                                ]),
                            Wrap(children: [
                              Text(
                                'Tên công việc:${data['ten_cong_viec']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              )
                            ]),
                            Wrap(children: [
                              Text(
                                'Địa điểm: ${data['dia_diem']}',
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
                                data['tk_duyet']
                                    ? 'Ngày bắt đầu ${formattedDay} lúc ${formattedTime} đến ${formattedTimeEnd}'
                                    : 'Ngày giờ: đang chờ duyệt..',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              )
                            ]),
                            Wrap(
                              children: [
                                Text(
                                  'Ngày đăng công việc: ${ngay_post_string}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  ),
                                  textAlign: TextAlign
                                      .left, // căn chỉnh văn bản (giữa, trái, phải)
                                ),
                              ],
                            ),
                            Wrap(children: [
                              Text(
                                'Thời gian dự kiến diễn ra: ${data['thoi_gian_cv']} phút',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
                            Row(children: [
                              Text('Độ ưu tiên: ${data['do_uu_tien']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  )),
                            ]),
                            Row(children: [
                              Text('Tên phòng ban: ' + tenPB,
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  ))
                            ]),
                            Row(children: [
                              Text(
                                'Ngày tối thiểu: ' + ngay_toi_thieu_string,
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
                            Row(
                              children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  color: Colors.grey[100],
                                  height: 50,
                                  child: Text("Đồng ý hủy"),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cong_viec')
                                        .doc(widget.itemId)
                                        .update({
                                      "tk_duyet": false,
                                      "pb_huy": false
                                    });
                                    sendMail('đồng ý');
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    String _thongbao =
                                        'Duyệt yêu cầu hủy từ phòng ban thành công!';
                                    final snackBar = SnackBar(
                                      content: Text(_thongbao),
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
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  color: Colors.grey[100],
                                  height: 50,
                                  child: Text("Từ chối"),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cong_viec')
                                        .doc(widget.itemId)
                                        .update({"pb_huy": true});
                                    sendMail('từ chối');
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    String _thongbao =
                                        'Từ chối yêu cầu hủy từ phòng ban thành công!';
                                    final snackBar = SnackBar(
                                      content: Text(_thongbao),
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
                            ),
                            Row(children: [
                              Text(
                                data['gd_huy'] ? ' Đã bị hủy bởi giám đốc' : '',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
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
