import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/data/UserID.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';
import '../../list_event.dart';
import 'add_event.dart';
import 'item_details.dart';

class ListCongViec extends StatefulWidget {
  const ListCongViec({super.key});

  @override
  State<ListCongViec> createState() => _ListCongViecState();
}

DateTime now = DateTime.now();
DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
Timestamp startOfWeekTimestamp = Timestamp.fromDate(startOfWeek);
Timestamp endOfWeekTimestamp = Timestamp.fromDate(endOfWeek);

// Timestamp.fromd
class _ListCongViecState extends State<ListCongViec> {
  // late Map<DateTime, List<Event>> _events;
  var _event;
  var selectedValue = 'Tất cả';
  @override
  void initState() {
    super.initState();
    print(UserID.localUID);
    // _event = FirebaseFirestore.instance
    //     .collection('cong_viec')
    //     .where('tai_khoan_id', isEqualTo: uid);
    getData();
  }

  void getData() {
    if (selectedValue == 'Đã duyệt') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tai_khoan_id', isEqualTo: UserID.localUID)
          .where('tk_duyet', isEqualTo: true);
    } else if (selectedValue == 'Chưa duyệt') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tai_khoan_id', isEqualTo: UserID.localUID)
          .where('tk_duyet', isEqualTo: false);
    } else if (selectedValue == 'Đã diễn ra') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tai_khoan_id', isEqualTo: UserID.localUID)
          .where('trang_thai', isEqualTo: false);
    } else if (selectedValue == 'Chưa diễn ra') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tai_khoan_id', isEqualTo: UserID.localUID)
          .where('trang_thai', isEqualTo: true);
    } else {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tai_khoan_id', isEqualTo: UserID.localUID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch trình ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.clear,
              color: Colors.red,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
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
                          child: Text('Đã duyệt'),
                          value: 'Đã duyệt',
                        ),
                        DropdownMenuItem(
                          child: Text('Chưa duyệt'),
                          value: 'Chưa duyệt',
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
                SizedBox(
                  width: 10,
                ),
                Wrap(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Tìm công việc(theo tên)',
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _event = FirebaseFirestore.instance
                              .collection('cong_viec')
                              .where('tai_khoan_id', isEqualTo: UserID.localUID)
                              .where('ten_cong_viec',
                                  isGreaterThanOrEqualTo: value)
                              .orderBy('ten_cong_viec')
                              .startAt([value]).endAt([value + '\uf8ff']);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            StreamBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                    child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    //covert
                    DateTime datetime =
                        documentSnapshot['ngay_gio_bat_dau'].toDate();
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(datetime);
                    String formattedTime = DateFormat('HH:mm').format(datetime);
                    // bool tk_duyet =  documentSnapshot['Tk_duyet']
                    DateTime datetimeEnd =
                        documentSnapshot['ngay_gio_ket_thuc'].toDate();
                    String formattedDateEnd =
                        DateFormat('dd/MM/yyyy').format(datetimeEnd);
                    String formattedTimeEnd =
                        DateFormat('HH:mm').format(datetimeEnd);
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () async {
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetails(documentSnapshot.id),
                            ),
                          );
                          print(documentSnapshot.id);
                        },
                        title: Text(documentSnapshot['tieu_de']),
                        subtitle: documentSnapshot['tk_duyet']
                            ? Text('Ngày bắt đầu ' +
                                formattedDate.toString() +
                                '\nLúc ' +
                                formattedTime +
                                ' đến ' +
                                formattedTimeEnd)
                            : Text('Chưa duyệt'),
                        trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Sửa'),
                                  )),
                                  PopupMenuItem(
                                      child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Xóa'),
                                  )),
                                ]),
                        leading: documentSnapshot['tk_duyet'] == true
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.check_box,
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                      ),
                    );
                  },
                ));
              },
              stream: _event.snapshots(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEvent(),
            ),
          );
          //if (result ?? false) {
          //  //loadFirestoreEvents();
          //}
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
