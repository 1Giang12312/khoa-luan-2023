import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/data/UserID.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/model/details_item.dart';
import 'package:khoa_luan1/pages/phongban/item_details.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);
Timestamp todayTimestamp = Timestamp.fromDate(today);
final startOfToday = DateTime(now.year, now.month, now.day);
final endOfToday = DateTime(
    startOfToday.year, startOfToday.month, startOfToday.day, 23, 59, 59);

// Timestamp.fromd
class _ToDoListState extends State<ToDoList> {
  // late Map<DateTime, List<Event>> _events;
  var _event;
  List<QueryDocumentSnapshot> listEvent = [];
  StreamController<List<DocumentSnapshot>> _listStreamController =
      StreamController<List<DocumentSnapshot>>();

  var _phong_ban_id = '';
  var selectedValue = 'Tất cả';
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getPhongBanID();
    getData();

    print(todayTimestamp);
    print(UserID.localUID);
  }

  getPhongBanID() async {
    setState(() {
      isLoading = true;
    });
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    _phong_ban_id = userDoc['phong_ban_id'];
    setState(() {
      isLoading = false;
      getData();
    });
    //getData();
  }

// Định dạng ngày tháng
  void getData() async {
    // getPhongBanID();
    if (selectedValue == 'Đã diễn ra') {
      // _event = FirebaseFirestore.instance
      //     .collection('cong_viec')
      //     //.where('phong_ban_id', isEqualTo: _phong_ban_id)
      //     .where('tk_duyet', isEqualTo: true)
      //     .where('trang_thai', isEqualTo: false)
      //     .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
      //     .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday);
      listEvent = [];
      final eventRef = await FirebaseFirestore.instance
          .collection("cong_viec")
          .where('tk_duyet', isEqualTo: true)
          .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
          .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
          .where('trang_thai', isEqualTo: false)
          .get();
      for (var doc in eventRef.docs) {
        // String cityName = doc.get("name");
        if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          print(doc['ten_cong_viec']);
        }
      }
      _listStreamController.sink.add(listEvent);
    } else if (selectedValue == 'Chưa diễn ra') {
      // _event = FirebaseFirestore.instance
      //     .collection('cong_viec')
      //     .where('phong_ban_id', isEqualTo: _phong_ban_id)
      //     .where('tk_duyet', isEqualTo: true)
      //     .where('trang_thai', isEqualTo: true)
      //     .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
      //     .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday);
      listEvent = [];
      final eventRef = await FirebaseFirestore.instance
          .collection("cong_viec")
          .where('tk_duyet', isEqualTo: true)
          .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
          .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
          .where('trang_thai', isEqualTo: true)
          .get();
      for (var doc in eventRef.docs) {
        // String cityName = doc.get("name");
        if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          print(doc['ten_cong_viec']);
        }
      }
      _listStreamController.sink.add(listEvent);
    } else {
      // _event = FirebaseFirestore.instance
      //     .collection('cong_viec')
      //     //  .where('phong_ban_id', isEqualTo: _phong_ban_id)
      //     .where('tk_duyet', isEqualTo: true)
      //     .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
      //     .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday);
      listEvent = [];
      final eventRef = await FirebaseFirestore.instance
          .collection("cong_viec")
          .where('tk_duyet', isEqualTo: true)
          .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
          .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
          .get();
      for (var doc in eventRef.docs) {
        // String cityName = doc.get("name");
        if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          print(doc['ten_cong_viec']);
        }
      }
      _listStreamController.sink.add(listEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        title: Text('Lịch trình của hôm nay',
            style: TextStyle(color: Colors.black)),
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
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('Lọc:'),
                      SizedBox(
                        width: 10,
                      ),
                      DropdownButton(
                        hint: Text('Chọn tùy chọn'),
                        value: selectedValue,
                        onChanged: (newValue) {
                          setState(() {
                            selectedValue = newValue.toString()!;
                            getData();
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text('Tất cả'),
                            value: 'Tất cả',
                          ),
                          DropdownMenuItem(
                            child: Text('Đã diễn ra'),
                            value: 'Đã diễn ra',
                          ),
                          DropdownMenuItem(
                            child: Text('Chưa diễn ra'),
                            value: 'Chưa diễn ra',
                          ),
                        ],
                      ),
                    ],
                  ),
                  StreamBuilder<List<DocumentSnapshot>>(
                    builder: (BuildContext context,
                        AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
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
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data![index];
                          //covert
                          DateTime datetime =
                              documentSnapshot['ngay_gio_bat_dau'].toDate();
                          String formattedDate =
                              DateFormat('dd/MM/yyyy').format(datetime);
                          String formattedTime =
                              DateFormat('HH:mm').format(datetime);

                          DateTime datetimeKT =
                              documentSnapshot['ngay_gio_ket_thuc'].toDate();

                          String formattedTimeKT =
                              DateFormat('HH:mm').format(datetimeKT);
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () async {
                                final res = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemDetails(documentSnapshot.id),
                                  ),
                                );
                                print(documentSnapshot.id);
                              },
                              title: Text(documentSnapshot['tieu_de']),
                              subtitle: Text(documentSnapshot['ten_cong_viec']),
                              trailing: Text('Ngày bắt đầu ' +
                                  formattedDate.toString() +
                                  '\nLúc ' +
                                  formattedTime +
                                  ' đến ' +
                                  formattedTimeKT),
                            ),
                          );
                        },
                      ));
                    },
                    stream: _listStreamController.stream,
                  )
                ],
              ),
            ),
    );
  }
}
