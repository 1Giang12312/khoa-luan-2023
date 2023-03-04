import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutterfiredemo/edit_item.dart';
import 'package:intl/intl.dart';

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
                          children: [
                            Row(children: [
                              Text(
                                'Tiêu đề:${data['tieu_de']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              ),
                            ]),
                            Row(children: [
                              Text(
                                'Tên công việc:${data['ten_cong_viec']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                              ),
                            ]),
                            Row(children: [
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
                            Row(children: [
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
                            Row(children: [
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
                            Row(children: [
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
                            Row(children: [
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
                            Row(children: [
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
                                                  await FirebaseFirestore
                                                      .instance
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
                                      "Hủy",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    color: Colors.white,
                                  ),
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
