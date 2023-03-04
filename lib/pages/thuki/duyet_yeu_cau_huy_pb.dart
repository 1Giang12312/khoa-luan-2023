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
import 'detail_duyet_yeu_cau_huy_pb.dart';

class DuyetYeuCauHuy extends StatefulWidget {
  const DuyetYeuCauHuy({super.key});

  @override
  State<DuyetYeuCauHuy> createState() => _DuyetYeuCauHuyState();
}

late DateTime _firstDay;
late DateTime _lastDay;

// Timestamp.fromd
class _DuyetYeuCauHuyState extends State<DuyetYeuCauHuy> {
  // late Map<DateTime, List<Event>> _events;
  var _event;
  @override
  void initState() {
    super.initState();
    _event = FirebaseFirestore.instance
        .collection('cong_viec')
        .where('pb_huy', isEqualTo: true);
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sác yêu cầu hủy ',
            style: TextStyle(color: Colors.black)),
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
                              builder: (_) =>
                                  DuyetYeuCauHuyDetail(documentSnapshot.id),
                            ),
                          );
                          print(documentSnapshot.id);
                          Navigator.of(context).maybePop();
                          // final res = await Navigator.push<bool>(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => DuyetEventMain(
                          //       eventID: documentSnapshot.id,
                          //       firstDate: _firstDay,
                          //       lastDate: _lastDay,
                          //       selectedDate: dataSelectedDay.selectedDay,
                          //     ),
                          //   ),
                          // );
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
                                          builder: (_) => DuyetYeuCauHuyDetail(
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
