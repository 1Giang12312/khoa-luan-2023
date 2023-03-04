import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/model/details_item.dart';
import 'item_details_giam_doc.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);
final startOfToday = DateTime(now.year, now.month, now.day);
final endOfToday = DateTime(
    startOfToday.year, startOfToday.month, startOfToday.day, 23, 59, 59);

// Timestamp.fromd
class _ToDoListState extends State<ToDoList> {
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
        .where('tk_duyet', isEqualTo: true)
        .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
        .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday);
    print(uid);
  }

// Định dạng ngày tháng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text('Lịch trình của hôm nay',
            style: TextStyle(color: Colors.black)),
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
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () async {
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ItemDetailsGiamDoc(documentSnapshot.id),
                            ),
                          );
                          print(documentSnapshot.id);
                        },
                        title: Text(documentSnapshot['tieu_de']),
                        subtitle: Text(documentSnapshot['dia_diem']),
                        trailing: Text('Ngày ' +
                            formattedDate.toString() +
                            '\nLúc ' +
                            formattedTime),
                        leading: Icon(
                          Icons.check_box,
                          color: Colors.green,
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
    );
  }
}