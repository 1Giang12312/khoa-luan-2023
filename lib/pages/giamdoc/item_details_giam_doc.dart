import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ItemDetailsGiamDoc extends StatefulWidget {
  ItemDetailsGiamDoc(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ItemDetailsGiamDoc> createState() => _ItemDetailsGiamDocState();
}

class _ItemDetailsGiamDocState extends State<ItemDetailsGiamDoc> {
  var tenPB = '';
  var _email_TK = '';
  var _email_PB = '';
  var _email_GD = '';
  var _ten_GD = '';
  var _app_password = '';
  var _ten_TK = '';

  var _ngay_dien_ra = '';
  var _ngay_toi_thieu = '';
  var _rool = '';
  var _tieu_de = '';
  var _ten_cong_viec = '';
  var _thoi_gian_dien_ra = '';
  var _dia_diem = '';
  @override
  void initState() {
    super.initState();
    getName();
    //print(tenPB);
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

    //giám đốc
    final giamdocDoc = await usersCollection.doc(uid).get();
    final _emailGD = giamdocDoc['email'];
    final _tenGD = giamdocDoc['ten'];
    final _appPassword = giamdocDoc['app_password'];
    _app_password = _appPassword;
    _email_GD = _emailGD;
    _ten_GD = _tenGD;

    //chọn event
    final eventDoc = await eventCollection.doc(widget.itemId).get();
    final _tieu_De = eventDoc['tieu_de'];
    final _ten_cong_Viec = eventDoc['ten_cong_viec'];
    final _thoi_gian_dien_Ra = eventDoc['thoi_gian_cv'];
    final _dia_Diem = eventDoc['dia_diem'];
    final uu_tien = eventDoc['do_uu_tien'];
    DateTime ngay_toi_thieuDate = eventDoc['ngay_toi_thieu'].toDate();
    _ngay_toi_thieu = DateFormat('dd/MM/yyyy').format(ngay_toi_thieuDate);

    DateTime _ngay_dien_raDate = eventDoc['ngay_gio_bat_dau'].toDate();
    _ngay_dien_ra = DateFormat('dd/MM/yyyy').format(_ngay_dien_raDate);
    _tieu_de = _tieu_De;
    _ten_cong_viec = _ten_cong_Viec;
    _thoi_gian_dien_ra = _thoi_gian_dien_Ra;
    _dia_diem = _dia_Diem;
    _rool = uu_tien;
    //thư kí
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han', isEqualTo: 'TK')
        .limit(1)
        .get();
    _email_TK = querySnapshot.docs.first['email'];
    _ten_TK = querySnapshot.docs.first['ten'];
    //setState(() {});
    //print(tenPB);
  }

  void sendMail() async {
    // var userEmail = _email_PB;
    final smtpServer = gmail(_email_GD.toString(), _app_password);
    final message = Message()
      ..from = Address(_email_GD.toString(), _ten_GD)
      ..recipients.add(_email_TK.toString())
      //..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      ..bccRecipients.add(Address(_email_PB.toString()))
      ..subject = 'Giám đốc ' + _ten_GD + ' đã huỷ công việc'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Thông báo huỷ công việc</h1>\n<h2>-Tiêu đề: ${_tieu_de}</h2>\n<h2>-Tên(chi tiết): ${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_ra}</h2>\n<h2>-Ngày diễn ra diễn ra: ${_ngay_dien_ra} phút</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Ngày tối thiểu : ${_ngay_toi_thieu}</h2>\n<h2>-Độ ưu tiên : ${_rool}</h2>";

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

  late Map data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
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

            DateTime ngay_bat_dau = data['ngay_gio_bat_dau'].toDate();
            DateTime gio_ket_thuc;
            DateTime ngay_post = data['ngay_post'].toDate();
            String ngay_post_string =
                DateFormat('dd/MM/yyyy').format(ngay_post);
            String formattedDay = DateFormat('dd/MM/yyyy').format(ngay_bat_dau);
            String formattedTime = DateFormat('HH:mm').format(ngay_bat_dau);
            int thoi_gian_cv = int.parse(data['thoi_gian_cv']);
            gio_ket_thuc = ngay_bat_dau.add(Duration(minutes: thoi_gian_cv));
            // String formattedDayEnd =
            //     DateFormat('dd/MM/yyyy').format(gio_ket_thuc);
            String formattedTimeEnd = DateFormat('HH:mm').format(gio_ket_thuc);

//             // chuyển đổi timestamp thành DateTime
//             DateTime date = timestamp.toDate();
//String formattedTime = DateFormat('HH:mm').format(ngay_bat_dau);
// // định dạng ngày/tháng/năm bằng DateFormat
//             String formattedDate = DateFormat('dd/MM/yyyy').format(date);
//cộng phút vào timestamp
// Giả sử timestamp hiện tại là 2023-02-15 10:00:00
// Timestamp timestamp = Timestamp.now();

// // Chuyển đổi timestamp thành đối tượng DateTime
// DateTime dateTime = timestamp.toDate();

// // Cộng thêm 10 phút vào dateTime
// dateTime = dateTime.add(Duration(minutes: 10));

// // Chuyển đổi dateTime thành timestamp mới
// Timestamp newTimestamp = Timestamp.fromDate(dateTime);

// // Lưu trữ newTimestamp vào Firestore

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
                            Wrap(children: [
                              Text(
                                'Tiêu đề:${data['tieu_de']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              ),
                            ]),
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    'Tên công việc:${data['ten_cong_viec']}',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  ),
                                ]),
                            Wrap(children: [
                              Text('Tên phòng ban: ' + tenPB,
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  ))
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
                              ),
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
                              ),
                            ]),
                            Wrap(children: [
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
                            ]),
                            Wrap(children: [
                              Text(
                                'Thời gian dự kiến diễn ra:${data['thoi_gian_cv']} phút',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
                            Wrap(children: [
                              Text(
                                data['tk_duyet']
                                    ? 'Thư kí đã duyệt!'
                                    : 'Đang chờ duyệt...',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
                            Wrap(children: [
                              Text(
                                data['pb_huy']
                                    ? 'Đã đăng kí hủy và đang chờ xét duyệt'
                                    : '',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ]),
                            Wrap(children: [
                              Text(
                                data['gd_huy'] ? 'Đã bị hủy bởi giám đốc' : '',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
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
                                            title: Text("Xóa trường"),
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
                                                  // update tk duyệt = false
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('cong_viec')
                                                      .doc(widget.itemId)
                                                      .update(
                                                          {'tk_duyet': false});
                                                  sendMail();
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                  final snackBar = SnackBar(
                                                    content: Text(
                                                        'Từ chối công việc thành công!'),
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
