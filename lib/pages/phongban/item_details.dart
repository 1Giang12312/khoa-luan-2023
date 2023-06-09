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
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import '../../data/UserID.dart';
import '../../services/send_push_massage.dart';
import 'edit_item.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../services/pdf_viewer.dart';

class ItemDetails extends StatefulWidget {
  ItemDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  late Map data;
  var _email_PB = '';
  var _app_Password = '';
  var _ten_PB = '';
  var _email_TK = '';
  var _ngay_toi_thieu = '';
  var _rool = '';
  var _ngay_dien_ra = '';
  String? pdfFlePath;
  var _tieu_de = '';
  var _ten_cong_viec = '';
  var _thoi_gian_dien_ra = '';
  var todaynow = DateTime.now().toString();
  var _dia_diem = '';
  String reFileName = '';
  String reFileName1 = '';
  String fileName = '';
  String fileName1 = '';
  bool isfileNameExsited = false;
  bool is2file = false;
  File? file = null;
  var url1 = '';
  var url2 = '';
  final today = DateTime.now();
  var path = '';
  var _FCMtoken = '';
  var idThuKi = '';
  var uidThuKi = '';
  bool isTVPB = false;
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getName();
    // print(_email_PB);
    // print(_app_Password);
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    getFCMToken();
    kiemTraRoute();
    // print(_formattedNgaydx);
    //_selectedDate = widget.selectedDate ?? DateTime.now();
  }

  getFCMToken() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Thư ký')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idThuKi = docId!;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idThuKi)
        .limit(1)
        .get();
    _FCMtoken = querySnapshot.docs.first['FCMtoken'];
    uidThuKi = querySnapshot.docs.first.id;
    print(_FCMtoken);
  }

  getName() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final eventCollection = FirebaseFirestore.instance.collection('cong_viec');
    final eventDoc = await eventCollection.doc(widget.itemId).get();
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    final _email = userDoc['email'];
    final _app_PW = userDoc['app_password'];

    final _phong_ban_id = userDoc['phong_ban_id'];
    final phongBanCollection1 =
        FirebaseFirestore.instance.collection('phong_ban');
    final phongBanDoc1 = await phongBanCollection1.doc(_phong_ban_id).get();
    final _ten = phongBanDoc1['ten_phong_ban'];
    // final _ten = userDoc['ten'];

    final _tieu_De = eventDoc['tieu_de'];
    final _ten_cong_Viec = eventDoc['ten_cong_viec'];
    final _thoi_gian_dien_Ra = eventDoc['thoi_gian_cv'];

    final phongBanCollection =
        FirebaseFirestore.instance.collection('dia_diem');
    final phongBanDoc =
        await phongBanCollection.doc(eventDoc['dia_diem_id']).get();
    final _dia_Diem = phongBanDoc['ten_dia_diem'];

    final uu_tien = eventDoc['do_uu_tien'];

    DateTime ngay_toi_thieuDate = data['ngay_toi_thieu'].toDate();
    _ngay_toi_thieu = DateFormat('dd/MM/yyyy').format(ngay_toi_thieuDate);

    DateTime ngay_dien_raDate = data['ngay_gio_bat_dau'].toDate();
    _ngay_dien_ra = DateFormat('dd/MM/yyyy').format(ngay_dien_raDate);

    _tieu_de = _tieu_De;
    _ten_cong_viec = _ten_cong_Viec;
    _thoi_gian_dien_ra = _thoi_gian_dien_Ra;
    _dia_diem = _dia_Diem;
    _rool = uu_tien;
    _app_Password = _app_PW;
    _email_PB = _email;
    _ten_PB = _ten;

    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Thư ký')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idThuKi = docId!;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idThuKi)
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
      ..html =
          "<h1>${title}!</h1>\n<h2>-Tiêu đề: ${_tieu_de}</h2>\n<h2>-Tên(chi tiết): ${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_ra} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Ngày đề xuất : ${_ngay_toi_thieu}</h2>\n<h2>-Độ ưu tiên : ${_rool}</h2>";

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

  void kiemTraRoute() async {
    setState(() {
      isLoading = true;
    });
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    if (userDoc['quyen_han_id'] == '3LGm3Jj470vvh8M3WYEf') {
      isTVPB = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
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

                  DateTime ngay_bat_dau = data['ngay_gio_bat_dau'].toDate();
                  DateTime gio_ket_thuc;

                  DateTime ngay_post = data['ngay_post'].toDate();
                  String ngay_post_string =
                      DateFormat('dd/MM/yyyy').format(ngay_post);

                  DateTime ngay_toi_thieu = data['ngay_toi_thieu'].toDate();
                  String ngay_toi_thieuString =
                      DateFormat('dd/MM/yyyy').format(ngay_toi_thieu);

                  String formattedDay =
                      DateFormat('dd/MM/yyyy').format(ngay_bat_dau);
                  String formattedTime =
                      DateFormat('HH:mm').format(ngay_bat_dau);
                  int thoi_gian_cv = int.parse(data['thoi_gian_cv']);
                  gio_ket_thuc =
                      ngay_bat_dau.add(Duration(minutes: thoi_gian_cv));
                  // String formattedDayEnd =
                  //     DateFormat('dd/MM/yyyy').format(gio_ket_thuc);
                  String formattedTimeEnd =
                      DateFormat('HH:mm').format(gio_ket_thuc);
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
                                  Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        Text(
                                          'Tiêu đề:${data['tieu_de']}',
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
                                      'Tên công việc:${data['ten_cong_viec']}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                    )
                                  ]),
                                  Wrap(children: [
                                    Text(
                                      'Địa điểm: ' + _dia_diem,
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
                                      data['tk_duyet']
                                          ? 'Ngày bắt đầu ${formattedDay} lúc ${formattedTime} đến ${formattedTimeEnd}'
                                          : 'Ngày giờ: đang chờ duyệt..',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
                                        fontSize: 20, // kích thước của văn bản
                                      ),
                                    )
                                  ]),
                                  Wrap(children: [
                                    Text('Độ ưu tiên: ${data['do_uu_tien']}',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0,
                                              0), // màu sắc của văn bản
                                          fontSize:
                                              20, // kích thước của văn bản
                                        )),
                                  ]),
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
                                  Wrap(children: [
                                    Text(
                                      'Ngày đăng công việc: ${ngay_post_string}',
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
                                      'Thời gian dự kiến diễn ra:${data['thoi_gian_cv']} phút',
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
                                    Visibility(
                                        visible: !data['is_gd_them'],
                                        child: Text(
                                          'Ngày tối thiểu: ${ngay_toi_thieuString}',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ),
                                          textAlign: TextAlign
                                              .left, // căn chỉnh văn bản (giữa, trái, phải)
                                        ))
                                  ]),
                                  Visibility(
                                    visible: data['pb_huy'], // bool
                                    child: Wrap(children: [
                                      Text(
                                        data['pb_huy']
                                            ? 'Đã đăng kí hủy và đang chờ xét duyệt'
                                            : '',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0,
                                              0), // màu sắc của văn bản
                                          fontSize:
                                              20, // kích thước của văn bản
                                        ),
                                        textAlign: TextAlign
                                            .left, // căn chỉnh văn bản (giữa, trái, phải)
                                      )
                                    ]),
                                    // widget to show/hide
                                  ),
                                  Visibility(
                                    visible: data['is_gd_them'],
                                    child: Wrap(
                                      children: [
                                        Text(
                                          'Được thêm bởi giám đốc',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ),
                                          textAlign: TextAlign
                                              .left, // căn chỉnh văn bản (giữa, trái, phải)
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                      visible: !data['is_gd_them'],
                                      child: Wrap(children: [
                                        Text(
                                          data['tk_duyet']
                                              ? 'Thư kí đã duyệt!'
                                              : 'Đang chờ duyệt...',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0,
                                                0), // màu sắc của văn bản
                                            fontSize:
                                                20, // kích thước của văn bản
                                          ),
                                          textAlign: TextAlign
                                              .left, // căn chỉnh văn bản (giữa, trái, phải)
                                        )
                                      ])),
                                  Wrap(children: [
                                    Text(
                                      isExsitFilePDF
                                          ? 'Có tệp đính kèm'
                                          : 'Không có tệp đính kèm',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // màu sắc của văn bản
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
                                  //           // print(data['file_pdf']);
                                  //           // Navigator.push(
                                  //           //     context,
                                  //           //     MaterialPageRoute(
                                  //           //         builder: (context) => PDFScreen(
                                  //           //               url: data['file_pdf'],
                                  //           //             )));
                                  //           print(data['file_pdf']);
                                  //           Navigator.push(
                                  //               context,
                                  //               MaterialPageRoute(
                                  //                   builder: (context) =>
                                  //                       PDFViwer(
                                  //                         url: data['file_pdf'],
                                  //                       )));
                                  //         } else {
                                  //           showDialog(
                                  //             context: context,
                                  //             builder: (context) {
                                  //               return AlertDialog(
                                  //                 backgroundColor: Colors.red,
                                  //                 title: Center(
                                  //                   child: Text(
                                  //                     'Không thể xem file pdf trên web',
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
                                                    builder: (context) =>
                                                        PDFViwer(
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
                                                    builder: (context) =>
                                                        PDFViwer(
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
                                                    builder: (context) =>
                                                        PDFViwer(
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
                                  Visibility(
                                      visible: !isTVPB && !data['is_gd_them'],
                                      child: Center(
                                        child: Row(
                                          children: [
                                            MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              elevation: 5.0,
                                              height: 40,
                                              onPressed: () async {
                                                if (ngay_bat_dau
                                                        .isBefore(today) &&
                                                    data['tk_duyet'] == true) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Color.fromARGB(
                                                                255, 255, 0, 0),
                                                        title: Center(
                                                          child: Text(
                                                            'Không được huỷ công việc đã diễn ra',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            "Huỷ công việc"),
                                                        content: Text(
                                                            "Bạn có chắc chắn muốn hủy công việc này?"),
                                                        actions: <Widget>[
                                                          ElevatedButton(
                                                            child:
                                                                Text("Không"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            child: Text("Có"),
                                                            onPressed:
                                                                () async {
                                                              //thư kí duyệt rồi thì dk
                                                              data['tk_duyet']
                                                                  ? await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'cong_viec')
                                                                      .doc(widget
                                                                          .itemId)
                                                                      .update({
                                                                      'pb_huy':
                                                                          true
                                                                    })
                                                                  : //tk chưa duyệt thì xóa event
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'cong_viec')
                                                                      .doc(widget
                                                                          .itemId)
                                                                      .delete();
                                                              if (!kIsWeb) {
                                                                data['tk_duyet']
                                                                    ? sendMail(
                                                                        'đăng kí hủy công việc',
                                                                        'Phòng ban đã đăng kí hủy công việc')
                                                                    : sendMail(
                                                                        'xóa công việc',
                                                                        'Phòng ban đã xóa công việc!');
                                                              }
                                                              data['tk_duyet']
                                                                  ? SendPushMessage(
                                                                      _FCMtoken,
                                                                      'Cuộc họp: ' +
                                                                          data[
                                                                              'tieu_de'],
                                                                      _ten_PB +
                                                                          ' đã đăng kí huỷ',
                                                                      'pb_dang_ki_huy')
                                                                  : SendPushMessage(
                                                                      _FCMtoken,
                                                                      'Cuộc họp: ' +
                                                                          data[
                                                                              'tieu_de'],
                                                                      _ten_PB +
                                                                          ' đã huỷ',
                                                                      'pb_dang_ki_huy');
                                                              data['tk_duyet']
                                                                  ? addThongBao(
                                                                      _ten_PB +
                                                                          ' đã đăng kí huỷ' +
                                                                          'Cuộc họp: ' +
                                                                          data[
                                                                              'tieu_de'],
                                                                      _ten_PB +
                                                                          ' đã đăng kí huỷ',
                                                                      uidThuKi,
                                                                      todaynow)
                                                                  : addThongBao(
                                                                      _ten_PB +
                                                                          ' đã huỷ ' +
                                                                          'Cuộc họp: ' +
                                                                          data[
                                                                              'tieu_de'],
                                                                      _ten_PB +
                                                                          ' đã huỷ',
                                                                      uidThuKi,
                                                                      todaynow);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              String _thongbao =
                                                                  '';
                                                              data['tk_duyet']
                                                                  ? _thongbao =
                                                                      'Đã đăng kí hủy'
                                                                  : _thongbao =
                                                                      'Đã xóa công việc thành công';
                                                              final snackBar =
                                                                  SnackBar(
                                                                content: Text(
                                                                    _thongbao),
                                                                action:
                                                                    SnackBarAction(
                                                                  label: 'Tắt',
                                                                  onPressed:
                                                                      () {
                                                                    // Some code to undo the change.
                                                                  },
                                                                ),
                                                              );

                                                              // Find the ScaffoldMessenger in the widget tree
                                                              // and use it to show a SnackBar.
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      snackBar);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                                //hủy cv
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
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                    elevation: 5.0,
                                                    height: 40,
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    0,
                                                                    0),
                                                            title: Center(
                                                              child: Text(
                                                                'Bạn không thể sửa do thư kí đã duyệt',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .white),
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
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                    elevation: 5.0,
                                                    height: 40,
                                                    onPressed: () async {
                                                      final res =
                                                          await Navigator.push<
                                                              bool>(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              EditItem(
                                                            itemId:
                                                                documentSnapshot
                                                                    .id,
                                                          ),
                                                        ),
                                                      );
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
