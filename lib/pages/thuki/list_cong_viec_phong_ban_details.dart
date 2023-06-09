import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import '../../data/UserID.dart';
import '../../services/pdf_viewer.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ListCongViecPhongBanDetails extends StatefulWidget {
  ListCongViecPhongBanDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ListCongViecPhongBanDetails> createState() =>
      _ListCongViecPhongBanDetailsState();
}

class _ListCongViecPhongBanDetailsState
    extends State<ListCongViecPhongBanDetails> {
  late Map data;
  String reFileName = '';
  String fileName = '';
  bool isfileNameExsited = false;
  File? file = null;
  @override
  void initState() {
    super.initState();
    // print(_email_PB);
    // print(_app_Password);
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    // print(_formattedNgaydx);
    //_selectedDate = widget.selectedDate ?? DateTime.now();
  }

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

            DateTime ngay_toi_thieu = data['ngay_toi_thieu'].toDate();
            String ngay_toi_thieuString =
                DateFormat('dd/MM/yyyy').format(ngay_toi_thieu);

            String formattedDay = DateFormat('dd/MM/yyyy').format(ngay_bat_dau);
            String formattedTime = DateFormat('HH:mm').format(ngay_bat_dau);
            int thoi_gian_cv = int.parse(data['thoi_gian_cv']);
            gio_ket_thuc = ngay_bat_dau.add(Duration(minutes: thoi_gian_cv));
            // String formattedDayEnd =
            //     DateFormat('dd/MM/yyyy').format(gio_ket_thuc);
            String formattedTimeEnd = DateFormat('HH:mm').format(gio_ket_thuc);
            bool isExsitFilePDF;
            if (data['file_pdf'].toString() == '') {
              isExsitFilePDF = false;
            } else {
              isExsitFilePDF = true;
              reFileName = data['file_pdf'].split('/')[1];
              fileName = reFileName.split('_)()(_').first;
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
                              )
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
                              )
                            ]),
                            Row(children: [
                              Text('Độ ưu tiên: ${data['do_uu_tien']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  )),
                            ]),
                            Wrap(children: [
                              Text(
                                'Ngày tối thiểu: ${ngay_toi_thieuString}',
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
                            Visibility(
                              visible: isExsitFilePDF, // bool
                              child: Wrap(children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    print(data['file_pdf']);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PDFViwer(
                                                  url: data['file_pdf'],
                                                )));
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
                              visible: data['pb_huy'], // bool
                              child: Wrap(children: [
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
                                )
                              ]),
                              // widget to show/hide
                            ),
                            Wrap(
                              children: [
                                Text(
                                  data['is_gd_them']
                                      ? ' Được thêm bởi giám đốc'
                                      : '',
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
