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

class ListThongBaoDetails extends StatefulWidget {
  ListThongBaoDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('thong_bao').doc(itemId);
    _futureData = _reference.get();
  }
  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ListThongBaoDetails> createState() => _ListThongBaoDetailsState();
}

class _ListThongBaoDetailsState extends State<ListThongBaoDetails> {
  late Map data;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết thông báo'),
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
            return ListView(
                // padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.grey[100],
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    'Tiêu đề: ' + data['tieu_de'],
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0), // màu sắc của văn bản
                                      fontSize: 20, // kích thước của văn bản
                                    ),
                                  )
                                ]),
                            Wrap(children: [
                              Text(
                                'Chi tiết: ${data['noi_dung']}',
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
                                'Ngày gửi thông báo: ${data['ngay_gio']}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // màu sắc của văn bản
                                  fontSize: 20, // kích thước của văn bản
                                ),
                                textAlign: TextAlign
                                    .left, // căn chỉnh văn bản (giữa, trái, phải)
                              )
                            ]),
                          ])))
                ]);
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
