import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/dashboard.dart';
import '../../data/UserID.dart';
import '../../data/selectedDay.dart';
import '../../services/pdf_viewer.dart';
import 'duyet_event_main.dart';
import '../../services/send_push_massage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'duyet_yeu_cau_huy_pb.dart';
import 'list_phong_ban_details.dart';

class ItemDetailsThuKi extends StatefulWidget {
  ItemDetailsThuKi(this.itemId, this.isDsHuy, this.isDetail, {Key? key})
      : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }
  String itemId;
  bool isDsHuy;
  bool isDetail;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ItemDetailsThuKi> createState() => _ItemDetailsThuKiState();
}

class _ItemDetailsThuKiState extends State<ItemDetailsThuKi> {
  late DateTime _firstDay;
  late DateTime _lastDay;
  late Map data;
  late DateTime _dateTime_now = DateTime.now();

  String reFileName = '';
  String reFileName1 = '';
  String fileName = '';
  String fileName1 = '';
  bool is2file = false;
  var url1 = '';
  var url2 = '';
  var fCMToken = '';
  var tenPB = '';
  var sdtPB = '';
  var emailPB = '';
  var _app_password = '';
  var _email_TK = '';
  var _ten_tk = '';
  var _ngay_post = '';
  var _ngay_toi_thieu = '';
  var _tieu_de = '';
  var _ten_cong_viec = '';
  var _thoi_gian_dien_ra = '';
  var _dia_diem = '';
  var _rool = '';
  var _ngay_dien_ra = '';
  var _emailGD = '';
  var _tenGD = '';
  var fCMTokenGD = '';
  var idGiamDoc = '';
  var _fax = '';
  late bool isLoading = false;
  var id_phong_ban_GD_huy = '';
  var idTaiKhoanHienTai = '';
  var idGD = '';
  var todaynow = DateTime.now().toString();
  List<QueryDocumentSnapshot> listPhongBan = [];
  StreamController<List<DocumentSnapshot>> _listStreamController =
      StreamController<List<DocumentSnapshot>>();
  @override
  void initState() {
    getFCMToken();
    super.initState();
    getName();
    getIDPhongBan();
    getIDGD();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    print('Ten' + tenPB);
    print(_emailGD);
    getDataForStreamBuilder();
  }

  getIDPhongBan() async {
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');
    final orderId = widget.itemId;
    final orderDoc = await ordersCollection.doc(orderId).get();
    id_phong_ban_GD_huy = orderDoc['phong_ban_id'];
  }

  getIDGD() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    idTaiKhoanHienTai = userDoc['quyen_han_id'];

    final usersCollection1 = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: 'GD')
        .get();
    idGD = usersCollection1.docs.first.id;
  }

  getDataFromFirestoreAndSendPushNTGDHuy(
      var formattedTime, var formattedDay, var tieuDe) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('phong_ban_id', isEqualTo: id_phong_ban_GD_huy)
        .get();
    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('FCMtoken')) {
          String fieldValue = data['FCMtoken'].toString();
          String idDoc = doc.id;
          SendPushMessage(fieldValue, 'Lúc: $formattedTime ngày $formattedDay',
              'Huỷ công việc: $tieuDe', 'gd_huy');
          addThongBao(
              'Lúc: $formattedTime ngày $formattedDay' +
                  ' Huỷ công việc: $tieuDe',
              'Huỷ công việc: $tieuDe',
              idDoc,
              todaynow);
          //gửi FCMtoken cho từng fieldvalue
          //listFCMtoken.add(fieldValue);
          //print(fieldValue);
          // xử lý giá trị fieldValue ở đây
        } else {
          // xử lý trường hợp không tìm thấy dữ liệu hoặc không có trường fieldName
          print('Lỗi fcm');
        }
      }
    });
    //return dataList;
  }

  getDataForStreamBuilder() async {
    CollectionReference phongBanRef =
        FirebaseFirestore.instance.collection("phong_ban");
    QuerySnapshot phongBanData = await phongBanRef.get();

    final phongBanIDCollection =
        FirebaseFirestore.instance.collection('cong_viec');
    final phongBanIDDoc = await phongBanIDCollection.doc(widget.itemId).get();
    final phongBanID = phongBanIDDoc['phong_ban_id'];
    // List<String> listOfPhongBanID = phongBanID.toString().split("-");

    listPhongBan = [];
    final eventRef =
        await FirebaseFirestore.instance.collection("phong_ban").get();
    for (var doc in eventRef.docs) {
      if (phongBanID.toString().contains(doc.id)) {
        // listEvent.add(doc);
        //    print(doc['ten_cong_viec']
        print(doc['ten_phong_ban']);
        listPhongBan.add(doc);
        // final phongBanCollection =
        //     FirebaseFirestore.instance.collection('phong_ban');
        // final phongBanDoc = await phongBanCollection.doc(doc.id).get();
        // for(var tenPhongBan in phongBanDoc.)
      }
    }
    _listStreamController.sink.add(listPhongBan);
  }

  getDataFromFirestoreAndSendPushNT(
      var formattedTime, var formattedDay, var tieuDe) async {
    // List<String> dataList = [];
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.itemId;

    final orderDoc = await ordersCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();
    final id_phong_ban = userDoc['phong_ban_id'];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('phong_ban_id', isEqualTo: id_phong_ban)
        .get();

    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('FCMtoken')) {
          String fieldValue = data['FCMtoken'].toString();
          String idDoc1 = doc.id;
          SendPushMessage(fieldValue, 'Lúc: $formattedTime ngày $formattedDay',
              'Huỷ công việc: ' + tieuDe, 'tk_huy');
          addThongBao(
              'Lúc: $formattedTime ngày $formattedDay' +
                  ' Huỷ công việc: $tieuDe',
              'Huỷ công việc: $tieuDe',
              idDoc1,
              todaynow);
          //gửi FCMtoken cho từng fieldvalue
          //listFCMtoken.add(fieldValue);
          //print(fieldValue);
          // xử lý giá trị fieldValue ở đây
        } else {
          // xử lý trường hợp không tìm thấy dữ liệu hoặc không có trường fieldName
          print('Lỗi fcm');
        }
      }
    });

    //return dataList;
  }

  getDataFromFirestoreAndSendPushNT1(var tieuDe, var yeuCau) async {
    // List<String> dataList = [];
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.itemId;

    final orderDoc = await ordersCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();
    final id_phong_ban = userDoc['phong_ban_id'];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('phong_ban_id', isEqualTo: id_phong_ban)
        .get();
    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('FCMtoken')) {
          String fieldValue = data['FCMtoken'].toString();
          String idDoc2 = doc.id;
          SendPushMessage(fieldValue, 'Công việc ' + tieuDe,
              'Thư kí ${yeuCau} yêu cầu huỷ huỷ!', 'tk_yeu_cau_huy');
          addThongBao(
              'Công việc ' + tieuDe + ' Thư kí ${yeuCau} yêu cầu huỷ huỷ!',
              'Thư kí ${yeuCau} yêu cầu huỷ huỷ!',
              idDoc2,
              todaynow);
          //gửi FCMtoken cho từng fieldvalue
          //listFCMtoken.add(fieldValue);
          //print(fieldValue);
          // xử lý giá trị fieldValue ở đây
        } else {
          // xử lý trường hợp không tìm thấy dữ liệu hoặc không có trường fieldName
          print('Lỗi fcm');
        }
      }
    });

    //return dataList;
  }

  getFCMToken() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.itemId;

    final orderDoc = await ordersCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();
    final FCMToken = userDoc['FCMtoken'];
    fCMToken = FCMToken;

    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Giám đốc')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idGiamDoc = docId!;

    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idGiamDoc)
        .limit(1)
        .get();
    if (querySnapshot1.docs.isNotEmpty) {
      fCMTokenGD = querySnapshot1.docs.first['FCMtoken'];
      _emailGD = querySnapshot1.docs.first['email'];
      _tenGD = querySnapshot1.docs.first['ten'];

      print(_emailGD); // thanh cong
      setState(() {});
    }
  }

  getName() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.itemId;

    final orderDoc = await ordersCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];

    final userDoc = await usersCollection.doc(userId).get();
    //final userName = userDoc['ten'];
    final _phong_ban_id = userDoc['phong_ban_id'];
    final phongBanCollection1 =
        FirebaseFirestore.instance.collection('phong_ban');
    final phongBanDoc1 = await phongBanCollection1.doc(_phong_ban_id).get();
    final _ten = phongBanDoc1['ten_phong_ban'];

    final userPhone = phongBanDoc1['so_dien_thoai'];
    final userEmail = phongBanDoc1['email'];
    final userFax = phongBanDoc1['fax'];

    sdtPB = userPhone;
    emailPB = userEmail;
    tenPB = _ten;
    _fax = userFax;
    DateTime ngay_dien_raDate = data['ngay_gio_bat_dau'].toDate();
    _ngay_dien_ra = DateFormat('dd/MM/yyyy').format(ngay_dien_raDate);

    final thuKiDoc = await usersCollection.doc(UserID.localUID).get();
    final email_TK = thuKiDoc['email'];
    final app_Password = thuKiDoc['app_password'];
    final ten_TK = thuKiDoc['ten'];
    _email_TK = email_TK;
    _ten_tk = ten_TK;
    _app_password = app_Password;

    // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('tai_khoan')
    //     .where('quyen_han', isEqualTo: 'GD')
    //     .limit(1)
    //     .get();
    // _emailGD = querySnapshot.docs.first['email'];
    // _tenGD = querySnapshot.docs.first['ten'];
//get Event
    final eventCollection = FirebaseFirestore.instance.collection('cong_viec');
    final eventDoc = await eventCollection.doc(widget.itemId).get();
    final _tieu_De = eventDoc['tieu_de'];
    final _ten_cong_Viec = eventDoc['ten_cong_viec'];
    final _thoi_gian_dien_Ra = eventDoc['thoi_gian_cv'];
    // setState(() {
    //   isLoading = true;
    // });

    final phongBanCollection =
        FirebaseFirestore.instance.collection('dia_diem');
    final phongBanDoc =
        await phongBanCollection.doc(eventDoc['dia_diem_id']).get();
    final ten_dia_diem = phongBanDoc['ten_dia_diem'];

    final uu_tien = eventDoc['do_uu_tien'];
    _tieu_de = _tieu_De;
    _ten_cong_viec = _ten_cong_Viec;
    _thoi_gian_dien_ra = _thoi_gian_dien_Ra;

    _dia_diem = ten_dia_diem;

    _rool = uu_tien;
    // setState(() {
    //   isLoading = false;
    // });
    setState(() {});
    print(userEmail);
  }

  void sendMail() async {
    var tk_email = _email_TK;
    final smtpServer = gmail(tk_email.toString(), _app_password);
    final message = Message()
      ..from = Address(tk_email.toString(), _ten_tk)
      ..recipients.add(emailPB.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      //..bccRecipients.add(Address(_emailGD.toString()))
      ..subject = 'Gửi phòng ban ' + tenPB + ' công việc đã bị huỷ!'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc bị huỷ!</h1>\n<h2>-Tiêu đề: ${_tieu_de}</h2>\n<h2>-Tên(chi tiết): ${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_ra} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Độ ưu tiên : ${_rool}</h2>";

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

  void sendMailGD() async {
    var tk_email = _email_TK;
    final smtpServer = gmail(tk_email.toString(), _app_password);
    final message = Message()
      ..from = Address(tk_email.toString(), _ten_tk)
      ..recipients.add(_emailGD.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      //..bccRecipients.add(Address(_emailGD.toString()))
      ..subject = 'Gửi giám đốc ' + _tenGD + ' công việc đã bị huỷ!'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc bị huỷ!</h1>\n<h2>-Tiêu đề: ${_tieu_de}</h2>\n<h2>-Tên(chi tiết): ${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_ra} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Độ ưu tiên : ${_rool}</h2>";

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

  void sendMailDsHuy(String thongBao) async {
    var tk_email = _email_TK;
    // var userEmail = _email_PB;
    final smtpServer = gmail(_email_TK.toString(), _app_password);
    final message = Message()
      ..from = Address(tk_email.toString(), _ten_tk)
      ..recipients.add(emailPB.toString())
      //..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      ..bccRecipients.add(Address(_emailGD.toString()))
      ..subject =
          'Thư kí ' + _ten_tk + ' đã ' + thongBao + ' yêu cầu huỷ công việc'
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
      appBar: widget.isDsHuy
          ? AppBar(
              title: Text('Chi tiết công việc huỷ'),
              leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white,
                  )),
            )
          : AppBar(
              title: Text('Chi tiết công việc lịch trình'),
            ),
      body:
          //isLoading
          //     ? Center(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             CircularProgressIndicator(),
          //             Text(
          //               "Đang tải",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.black,
          //                 fontSize: 20,
          //               ),
          //             ),
          //           ],
          //         ),
          //       )
          //     :
          FutureBuilder<DocumentSnapshot>(
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
            // bool isExsitFilePDF = false;
            // if (data['file_pdf'].toString() == '') {
            //   isExsitFilePDF = false;
            // } else {
            //   isExsitFilePDF = true;
            //   reFileName = data['file_pdf'].split('/')[1];
            //   fileName = reFileName.split('_)()(_').first;
            // }
// bool isExsitFilePDF;
            bool isExsitFilePDF;
            if (data['file_pdf'].toString() == '') {
              isExsitFilePDF = false;
            } else {
              isExsitFilePDF = true;
              if (data['file_pdf'].toString().contains('_=)()(=_')) {
                is2file = true;
                reFileName = data['file_pdf'].split('/')[2];

                fileName = reFileName.split('_)()(_').first;

                reFileName1 = data['file_pdf'].split('/')[1];
                fileName1 = reFileName1.split('_)()(_').first;
              } else {
                reFileName = data['file_pdf'].split('/')[1];

                fileName = reFileName.split('_)()(_').first;
              }
            }
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
                            // !data['is_gd_them']
                            //     ? Wrap(
                            //         children: [
                            //           Row(
                            //             children: [
                            //               Expanded(
                            //                 flex: 3,
                            //                 child: Divider(
                            //                   color: Colors.grey,
                            //                   height: 1,
                            //                 ),
                            //               ),
                            //               Padding(
                            //                 padding: const EdgeInsets.symmetric(
                            //                     horizontal: 10),
                            //                 child: Text(
                            //                   'Thông tin phòng ban',
                            //                   style: TextStyle(
                            //                     color: Colors.grey,
                            //                     fontSize: 16,
                            //                   ),
                            //                 ),
                            //               ),
                            //               Expanded(
                            //                 flex: 7,
                            //                 child: Divider(
                            //                   color: Colors.grey,
                            //                   height: 1,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //           Wrap(children: [
                            //             Text('Phòng ban: ' + tenPB,
                            //                 style: TextStyle(
                            //                   color: Color.fromARGB(255, 0, 0,
                            //                       0), // màu sắc của văn bản
                            //                   fontSize:
                            //                       20, // kích thước của văn bản
                            //                 ))
                            //           ]),
                            //           Wrap(children: [
                            //             Text('Số điện thoại: ' + sdtPB,
                            //                 style: TextStyle(
                            //                   color: Color.fromARGB(255, 0, 0,
                            //                       0), // màu sắc của văn bản
                            //                   fontSize:
                            //                       20, // kích thước của văn bản
                            //                 ))
                            //           ]),
                            //           Wrap(children: [
                            //             Text('Email: ' + emailPB,
                            //                 style: TextStyle(
                            //                   color: Color.fromARGB(255, 0, 0,
                            //                       0), // màu sắc của văn bản
                            //                   fontSize:
                            //                       20, // kích thước của văn bản
                            //                 ))
                            //           ]),
                            //           Wrap(children: [
                            //             Text('Fax: ' + _fax,
                            //                 style: TextStyle(
                            //                   color: Color.fromARGB(255, 0, 0,
                            //                       0), // màu sắc của văn bản
                            //                   fontSize:
                            //                       20, // kích thước của văn bản
                            //                 ))
                            //           ]),
                            //         ],
                            //       )
                            //     :
                            Wrap(
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
                                        'Danh sách phòng ban tham gia',
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
                                StreamBuilder<List<DocumentSnapshot>>(
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<DocumentSnapshot>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return SingleChildScrollView(
                                        child: ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final DocumentSnapshot
                                            documentSnapshot =
                                            snapshot.data![index];
                                        //covert
                                        return Card(
                                          margin: const EdgeInsets.all(10),
                                          child: ListTile(
                                            onTap: () async {
                                              final res =
                                                  await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ListPhongBanDetails(
                                                          documentSnapshot.id,
                                                          true),
                                                ),
                                              );
                                              print(documentSnapshot.id);
                                            },
                                            title: Text(documentSnapshot[
                                                'ten_phong_ban']),
                                          ),
                                        );
                                      },
                                    ));
                                  },
                                  stream: _listStreamController.stream,
                                )
                              ],
                            ),
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
                                    'Thông tin công việc',
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
                            Visibility(
                              visible: data['is_from_google_calendar'],
                              child: Wrap(
                                children: [
                                  Text(
                                    textAlign: TextAlign.left,
                                    'Được thêm từ Google Calendar',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Wrap(
                              children: [
                                Text(
                                  textAlign: TextAlign.left,
                                  'Tiêu đề: ${data['tieu_de']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    'Tên công việc: ${data['ten_cong_viec']}',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  ),
                                ]),
                            Wrap(children: [
                              Text(
                                'Địa điểm: ' + _dia_diem,
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
                                    ? 'Ngày bắt đầu: ${formattedDay} lúc ${formattedTime} đến ${formattedTimeEnd}'
                                    : 'Ngày giờ: đang chờ duyệt..',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              )
                            ]),
                            Wrap(children: [
                              Text(
                                isExsitFilePDF
                                    ? 'Có tệp đính kèm'
                                    : 'Không có tệp đính kèm',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                            // Visibility(
                            //   visible: isExsitFilePDF, // bool
                            //   child: Wrap(children: [
                            //     MaterialButton(
                            //       shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.all(
                            //               Radius.circular(20.0))),
                            //       elevation: 5.0,
                            //       height: 40,
                            //       onPressed: () async {
                            //         if (!kIsWeb) {
                            //           print(data['file_pdf']);
                            //           Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                   builder: (context) => PDFViwer(
                            //                         url: data['file_pdf'],
                            //                       )));
                            //         } else {
                            //           showDialog(
                            //             context: context,
                            //             builder: (context) {
                            //               return AlertDialog(
                            //                 backgroundColor:
                            //                     Color.fromARGB(255, 255, 0, 0),
                            //                 title: Center(
                            //                   child: Text(
                            //                     'Không thể xem file pdf trên trang web',
                            //                     style: const TextStyle(
                            //                         color: Colors.white),
                            //                   ),
                            //                 ),
                            //               );
                            //             },
                            //           );
                            //         }
                            //       },
                            //       child: Text(
                            //         fileName,
                            //         style: TextStyle(
                            //           fontSize: 20,
                            //         ),
                            //       ),
                            //       color: Colors.white,
                            //     )
                            //   ]),
                            // ),
                            Visibility(
                              visible: isExsitFilePDF && !is2file, // bool
                              child: Wrap(children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    if (!kIsWeb) {
                                      // print(data['file_pdf']);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => PDFScreen(
                                      //               url: data['file_pdf'],
                                      //             )));
                                      print(data['file_pdf']);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PDFViwer(
                                                    url: data['file_pdf'],
                                                  )));
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.red,
                                            title: Center(
                                              child: Text(
                                                'Không thể xem file pdf trên web',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
                                )
                              ]),
                            ),
                            Visibility(
                              visible: isExsitFilePDF && is2file, // bool
                              child: Wrap(children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    if (!kIsWeb) {
                                      // print(data['file_pdf']);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => PDFScreen(
                                      //               url: data['file_pdf'],
                                      //             )));
                                      print(data['file_pdf']);
                                      url1 = data['file_pdf']
                                          .toString()
                                          .split('_=)()(=_')[1];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PDFViwer(
                                                    url: url1,
                                                  )));
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.red,
                                            title: Center(
                                              child: Text(
                                                'Không thể xem file pdf trên web',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    fileName,
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
                                    if (!kIsWeb) {
                                      // print(data['file_pdf']);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => PDFScreen(
                                      //               url: data['file_pdf'],
                                      //             )));
                                      print(data['file_pdf']);
                                      url2 = data['file_pdf']
                                          .toString()
                                          .split('_=)()(=_')[0];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PDFViwer(
                                                    url: url2,
                                                  )));
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.red,
                                            title: Center(
                                              child: Text(
                                                'Không thể xem file pdf trên web',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    fileName1,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
                                )
                              ]),
                            ),

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
                                    'Chi tiết',
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
                            Wrap(children: [
                              Text('Độ ưu tiên: ${data['do_uu_tien']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  )),
                            ]),
                            Wrap(children: [
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
                            Visibility(
                              visible: data['is_from_google_calendar'],
                              child: Wrap(
                                children: [
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    elevation: 5.0,
                                    height: 40,
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Xoá công việc!"),
                                            content: Text(
                                                "Xoá công việc được đồng bộ từ Google Calendar này?"),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                child: Text("Không"),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              ElevatedButton(
                                                child: Text("Có"),
                                                onPressed: () async {
                                                  //logout(context);
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('cong_viec')
                                                      .doc(widget.itemId)
                                                      .delete();
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Xoá công việc',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),

                            Visibility(
                                visible: !data['is_from_google_calendar'],
                                child: Wrap(children: [
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
                                  )
                                ])),

                            Visibility(
                              visible: data['is_gd_them'],
                              child: Text(
                                ' Được thêm bởi giám đốc',

                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              ),
                            ),
                            Visibility(
                              visible: widget.isDetail &&
                                  !data['is_from_google_calendar'],
                              child: data['tk_duyet']
                                  ? Row(
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
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      child: Text("Có"),
                                                      onPressed: () async {
                                                        // getDataFromFirestoreAndSendPushNT(
                                                        //     formattedTime,
                                                        //     formattedDay,
                                                        //     data['tieu_de']);
                                                        getDataFromFirestoreAndSendPushNTGDHuy(
                                                            formattedTime,
                                                            formattedDay,
                                                            data['tieu_de']);
                                                        if (ngay_bat_dau.isAfter(
                                                            _dateTime_now)) {
                                                          if (data[
                                                                  'is_gd_them'] ==
                                                              true) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'cong_viec')
                                                                .doc(widget
                                                                    .itemId)
                                                                .delete();
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'cong_viec')
                                                                .doc(widget
                                                                    .itemId)
                                                                .update({
                                                              'tk_duyet': false
                                                            });
                                                          }

                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          final snackBar =
                                                              SnackBar(
                                                            content: Text(
                                                                'Đã hủy xếp công việc!'),
                                                            action:
                                                                SnackBarAction(
                                                              label: 'Tắt',
                                                              onPressed: () {},
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                          if (!kIsWeb) {
                                                            sendMail();
                                                            if (idTaiKhoanHienTai !=
                                                                'GD') {
                                                              sendMailGD();
                                                            }
                                                          }
                                                          // SendPushMessage(
                                                          //     fCMToken,
                                                          //     'Lúc: $formattedTime ngày $formattedDay',
                                                          //     'Huỷ công việc: ${data['tieu_de']}',
                                                          //     'tk_huy');
//nếu quyền hạn !=giám đốc thì gửi
                                                          if (idTaiKhoanHienTai !=
                                                              'GD') {
                                                            SendPushMessage(
                                                                fCMTokenGD,
                                                                'Lúc: $formattedTime ngày $formattedDay',
                                                                'Huỷ công việc: ${data['tieu_de']}',
                                                                'tk_huy_gui_GD');
                                                            addThongBao(
                                                                'Lúc: $formattedTime ngày $formattedDay' +
                                                                    ' Huỷ công việc: ${data['tieu_de']}',
                                                                'Huỷ công việc: ${data['tieu_de']}',
                                                                idGD,
                                                                todaynow);
                                                          }
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            0,
                                                                            0),
                                                                title: Center(
                                                                  child: Text(
                                                                    'Không thể huỷ công việc đã diễn ra!! ',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            "Huỷ công việc",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        MaterialButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0))),
                                          elevation: 5.0,
                                          height: 40,
                                          onPressed: () async {
                                            //hủy cv
                                            final res = await Navigator.push<
                                                    bool>(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        DuyetEventMain(
                                                          eventID:
                                                              documentSnapshot
                                                                  .id,
                                                          firstDate: _firstDay,
                                                          lastDate: _lastDay,
                                                          selectedDate:
                                                              dataSelectedDay
                                                                  .selectedDay,
                                                        )));
                                          },
                                          child: Text(
                                            "Chọn",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                            Visibility(
                              visible: widget.isDsHuy,
                              child: Row(
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
                                      if (!kIsWeb) {
                                        sendMailDsHuy('đồng ý');
                                      }
                                      // SendPushMessage(
                                      //     fCMToken,
                                      //     'Công việc ' + data['tieu_de'],
                                      //     'Thư kí đồng ý yêu cầu huỷ huỷ!',
                                      //     'tk_yeu_cau_huy');
                                      getDataFromFirestoreAndSendPushNT1(
                                          data['tieu_de'], 'đồng ý');
                                      SendPushMessage(
                                          fCMTokenGD,
                                          'Công việc ' + data['tieu_de'],
                                          'Thư kí đồng ý huỷ!',
                                          'tk_yeu_cau_huy_gui_GD');
                                      addThongBao(
                                          'Công việc ' +
                                              data['tieu_de'] +
                                              ' bị huỷ' +
                                              ' Huỷ công việc: ${data['tieu_de']}',
                                          'Thư kí đồng ý huỷ!',
                                          idGD,
                                          todaynow);
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
                                          .update({"pb_huy": false});
                                      if (!kIsWeb) {
                                        sendMailDsHuy('từ chối');
                                      }
                                      // SendPushMessage(
                                      //     fCMToken,
                                      //     'Công việc ' + data['tieu_de'],
                                      //     'Thư kí từ chối yêu cầu huỷ!',
                                      //     'tk_yeu_cau_huy');
                                      getDataFromFirestoreAndSendPushNT1(
                                          data['tieu_de'], 'từ chối');
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
