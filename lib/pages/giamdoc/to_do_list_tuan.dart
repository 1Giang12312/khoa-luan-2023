import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/model/details_item.dart';
import '../thuki/item_details_tk.dart';

class ToDoListTuan extends StatefulWidget {
  const ToDoListTuan({super.key});

  @override
  State<ToDoListTuan> createState() => _ToDoListTuanState();
}

DateTime now = DateTime.now();
DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
Timestamp startOfWeekTimestamp = Timestamp.fromDate(startOfWeek);
Timestamp endOfWeekTimestamp = Timestamp.fromDate(endOfWeek);

// Timestamp.fromd
class _ToDoListTuanState extends State<ToDoListTuan> {
  // late Map<DateTime, List<Event>> _events;
  var uid;
  var _event;
  var selectedValue = 'Tất cả';
  @override
  void initState() {
    super.initState();

    getData();
  }

// Định dạng ngày tháng
  void getData() {
    if (selectedValue == 'Đã diễn ra') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tk_duyet', isEqualTo: true)
          .where('trang_thai', isEqualTo: false)
          .where('ngay_gio_bat_dau',
              isGreaterThanOrEqualTo: startOfWeekTimestamp)
          .where('ngay_gio_bat_dau', isLessThan: endOfWeekTimestamp);
    } else if (selectedValue == 'Chưa diễn ra') {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tk_duyet', isEqualTo: true)
          .where('trang_thai', isEqualTo: true)
          .where('ngay_gio_bat_dau',
              isGreaterThanOrEqualTo: startOfWeekTimestamp)
          .where('ngay_gio_bat_dau', isLessThan: endOfWeekTimestamp);
    } else {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tk_duyet', isEqualTo: true)
          .where('ngay_gio_bat_dau',
              isGreaterThanOrEqualTo: startOfWeekTimestamp)
          .where('ngay_gio_bat_dau', isLessThan: endOfWeekTimestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title:
            Text('Lịch trình của tuần', style: TextStyle(color: Colors.black)),
        // leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(
        //       Icons.clear,
        //       color: Colors.red,
        //     )),
      ),
      body: SingleChildScrollView(
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
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () async {
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailsThuKi(
                                  documentSnapshot.id, false, true),
                            ),
                          );
                          print(documentSnapshot.id);
                        },
                        title: Text(documentSnapshot['tieu_de']),
                        subtitle: Text(documentSnapshot['ten_cong_viec']),
                        trailing: Text('Ngày ' +
                            formattedDate.toString() +
                            '\nLúc ' +
                            formattedTime),
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
    );
  }
}
