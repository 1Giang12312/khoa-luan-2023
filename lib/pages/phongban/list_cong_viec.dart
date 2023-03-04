import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
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
  var uid;
  var _event;
  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    _event = FirebaseFirestore.instance
        .collection('cong_viec')
        .where('tai_khoan_id', isEqualTo: uid)
        .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfWeekTimestamp)
        .where('ngay_gio_bat_dau', isLessThan: endOfWeekTimestamp);
    print(uid);
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
