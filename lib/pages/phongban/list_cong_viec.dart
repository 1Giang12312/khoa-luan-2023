import 'dart:async';
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
  bool isRoteGD;
  ListCongViec({super.key, required this.isRoteGD});

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
  List<QueryDocumentSnapshot> listEvent = [];
  StreamController<List<DocumentSnapshot>> _listStreamController =
      StreamController<List<DocumentSnapshot>>();
  bool isLoading = false;
  var _phong_ban_id = '';
  @override
  void initState() {
    super.initState();
    print(UserID.localUID);
    // _event = FirebaseFirestore.instance
    //     .collection('cong_viec')
    //     .where('tai_khoan_id', isEqualTo: uid);
    getPhongBanID();
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

  void getData() async {
    if (widget.isRoteGD == false) {
      if (selectedValue == 'Đã duyệt') {
        // _event = FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('tai_khoan_id', isEqualTo: UserID.localUID)
        //     .where('tk_duyet', isEqualTo: true);

        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('tk_duyet', isEqualTo: true)
            .get();
        for (var doc in eventRef.docs) {
          // String cityName = doc.get("name");
          if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
            listEvent.add(doc);
            //  print(doc['ten_cong_viec']);
          }
        }
        _listStreamController.sink.add(listEvent);
      } else if (selectedValue == 'Chưa duyệt') {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('tk_duyet', isEqualTo: false)
            // .where('ngay_gio_bat_dau',
            //     isGreaterThanOrEqualTo: startOfWeekTimestamp)
            // .where('ngay_gio_bat_dau', isLessThan: endOfWeekTimestamp)
            //  .where('trang_thai', isEqualTo: false)
            .get();
        for (var doc in eventRef.docs) {
          // String cityName = doc.get("name");
          if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
            listEvent.add(doc);
            //  print(doc['ten_cong_viec']);
          }
        }
        _listStreamController.sink.add(listEvent);
      } else if (selectedValue == 'Đã diễn ra') {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('trang_thai', isEqualTo: false)
            .get();
        for (var doc in eventRef.docs) {
          if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
            listEvent.add(doc);
            // print(doc['ten_cong_viec']);
          }
        }
        _listStreamController.sink.add(listEvent);
      } else if (selectedValue == 'Chưa diễn ra') {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('trang_thai', isEqualTo: true)
            .get();
        for (var doc in eventRef.docs) {
          // String cityName = doc.get("name");
          if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
            listEvent.add(doc);
            // print(doc['ten_cong_viec']);
          }
        }
        _listStreamController.sink.add(listEvent);
      } else {
        listEvent = [];
        final eventRef =
            await FirebaseFirestore.instance.collection("cong_viec").get();
        for (var doc in eventRef.docs) {
          if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
            listEvent.add(doc);
            //    print(doc['ten_cong_viec']);
          }
        }
        _listStreamController.sink.add(listEvent);
      }
    } else {
      if (selectedValue == 'Đã diễn ra') {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('tk_duyet', isEqualTo: true)
            .get();
        for (var doc in eventRef.docs) {
          //if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          // print(doc['ten_cong_viec']);
          //}
        }
        _listStreamController.sink.add(listEvent);
      } else if (selectedValue == 'Chưa diễn ra') {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('is_gd_them', isEqualTo: true)
            .where('trang_thai', isEqualTo: true)
            .get();
        for (var doc in eventRef.docs) {
          //if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          // print(doc['ten_cong_viec']);
          //}
        }
        _listStreamController.sink.add(listEvent);
      } else {
        listEvent = [];
        final eventRef = await FirebaseFirestore.instance
            .collection("cong_viec")
            .where('is_gd_them', isEqualTo: true)
            .get();
        for (var doc in eventRef.docs) {
          //if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
          listEvent.add(doc);
          // print(doc['ten_cong_viec']);
          //}
        }
        _listStreamController.sink.add(listEvent);
      }
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
                    !widget.isRoteGD
                        ? DropdownButton(
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
                          )
                        : DropdownButton(
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
                      onChanged: (value) async {
                        final eventRef = await FirebaseFirestore.instance
                            .collection('cong_viec')
                            // .where('tai_khoan_id', isEqualTo: UserID.localUID)
                            .where('tieu_de', isGreaterThanOrEqualTo: value)
                            .orderBy('tieu_de')
                            .startAt([value]).endAt([value + '\uf8ff']).get();
                        setState(() {
                          // _event = FirebaseFirestore.instance
                          //     .collection('cong_viec')
                          //     .where('tai_khoan_id', isEqualTo: UserID.localUID)
                          //     .where('ten_cong_viec',
                          //         isGreaterThanOrEqualTo: value)
                          //     .orderBy('ten_cong_viec')
                          //     .startAt([value]).endAt([value + '\uf8ff']);

                          listEvent = [];
                          for (var doc in eventRef.docs) {
                            if (doc['phong_ban_id']
                                .toString()
                                .contains(_phong_ban_id)) {
                              listEvent.add(doc);
                              // print(doc['ten_cong_viec']);
                            }
                          }
                          _listStreamController.sink.add(listEvent);
                        });
                      },
                    ),
                  ],
                )
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
              stream: _listStreamController.stream,
            )
          ],
        ),
      ),
    );
  }
}
