import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';

import 'package:khoa_luan1/pages/thuki/duyet_event_main.dart';
import '../../list_event.dart';
import 'duyet_event_detail.dart';
import '../../data/selectedDay.dart';
import 'duyet_event_main.dart';

class DuyetEventList extends StatefulWidget {
  const DuyetEventList({super.key});

  @override
  State<DuyetEventList> createState() => _DuyetEventListState();
}

late DateTime _firstDay;
late DateTime _lastDay;
DateTime now = DateTime.now();
DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
Timestamp startOfWeekTimestamp = Timestamp.fromDate(startOfWeek);
Timestamp endOfWeekTimestamp = Timestamp.fromDate(endOfWeek);

// Timestamp.fromd
class _DuyetEventListState extends State<DuyetEventList> {
  // late Map<DateTime, List<Event>> _events;
  var uid;
  var _event;
  String selectedValue = 'Tất cả';
  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    print(uid);
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    print(dataSelectedDay.selectedDay.toString());
    getData();
  }

  void getData() {
    var _reevent = FirebaseFirestore.instance
        .collection('cong_viec')
        .where('tk_duyet', isEqualTo: false);
    if (_reevent == null) {
      _event = _reevent;
    } else {
      _event = FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tk_duyet', isEqualTo: false)
          .where('do_uu_tien',
              isEqualTo: selectedValue != 'Tất cả' ? selectedValue : null);
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
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('Lọc theo độ ưu tiên'),
                SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  hint: Text('Chọn tùy chọn'),
                  value: selectedValue,
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue!;
                      getData();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('Tất cả'),
                      value: 'Tất cả',
                    ),
                    DropdownMenuItem(
                      child: Text('Cao'),
                      value: 'Cao',
                    ),
                    DropdownMenuItem(
                      child: Text('Vừa'),
                      value: 'Vừa',
                    ),
                    DropdownMenuItem(
                      child: Text('Thấp'),
                      value: 'Thấp',
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
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    DateTime ngay_toi_thieu =
                        documentSnapshot['ngay_toi_thieu'].toDate();
                    String formatngay_toi_thieu =
                        DateFormat('dd/MM/yyyy').format(ngay_toi_thieu);
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () async {
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DuyetEventMain(
                                eventID: documentSnapshot.id,
                                firstDate: _firstDay,
                                lastDate: _lastDay,
                                selectedDate: dataSelectedDay.selectedDay,
                              ),
                            ),
                          );
                        },
                        title: Text(documentSnapshot['tieu_de']),
                        subtitle: Text('Ngày tối thiểu: ' +
                            formatngay_toi_thieu.toString()),
                        trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Chi tiết'),
                                    onTap: () async {
                                      print(documentSnapshot.id);
                                      final res = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DuyetEventDetail(
                                              documentSnapshot.id),
                                        ),
                                      );
                                      Navigator.of(context).maybePop();
                                    },
                                  )),
                                  PopupMenuItem(
                                      child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Chọn'),
                                  )),
                                ]),
                      ),
                    );
                  },
                );
              },
              stream: _event.snapshots(),
            )
          ],
        ),
      ),
    );
  }
}
