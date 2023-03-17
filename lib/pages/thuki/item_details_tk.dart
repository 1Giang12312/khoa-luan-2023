import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';
import '../../data/selectedDay.dart';
import '../../services/view_file_pdf.dart';
import 'duyet_event_main.dart';

class ItemDetailsThuKi extends StatefulWidget {
  ItemDetailsThuKi(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('cong_viec').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ItemDetailsThuKi> createState() => _ItemDetailsThuKiState();
}

class _ItemDetailsThuKiState extends State<ItemDetailsThuKi> {
  late DateTime _firstDay;
  late DateTime _lastDay;
  late Map data;
  var tenPB = '';
  String reFileName = '';
  @override
  void initState() {
    super.initState();
    getName();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    print(tenPB);
  }

  getName() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.itemId;

    final orderDoc = await ordersCollection.doc(orderId).get();
    final userId = orderDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();
    final userName = userDoc['ten'];
    tenPB = userName;
    setState(() {});
    //print(tenPB);
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
            bool isExsitFilePDF = false;
            if (data['file_pdf'] != '') {
              isExsitFilePDF = true;
            }
            reFileName = data['file_pdf'].split('/')[1];
            String fileName =
                reFileName.split('_)()(_').first; // String formattedDayEnd =
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
                                    'Tên công việc:${data['ten_cong_viec']}',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  ),
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
                            Wrap(children: [
                              Text('Độ ưu tiên: ${data['do_uu_tien']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 0, 0), // màu sắc của văn bản
                                    fontSize: 20, // kích thước của văn bản
                                  )),
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
                                            builder: (context) => PDFScreen(
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
                            Row(
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
                                                await FirebaseFirestore.instance
                                                    .collection('cong_viec')
                                                    .doc(widget.itemId)
                                                    .update(
                                                        {'tk_duyet': false});
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                      'Đã hủy xếp công việc!'),
                                                  action: SnackBarAction(
                                                    label: 'Tắt',
                                                    onPressed: () {},
                                                  ),
                                                );
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
                                    "Hủy công việc",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
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
