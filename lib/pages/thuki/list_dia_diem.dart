import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';

import 'package:khoa_luan1/pages/thuki/duyet_event_main.dart';
import '../../list_event.dart';
import '../../data/selectedDay.dart';
import 'duyet_event_main.dart';
import 'item_details_tk.dart';
import 'list_dia_diem_details.dart';
import 'list_phong_ban_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/UserID.dart';

class ListDiaDiem extends StatefulWidget {
  bool isRouteGD;
  bool isRoutePB;
  bool isRouteTK;
  bool isRouteTVPB;
  ListDiaDiem(
      {super.key,
      required this.isRouteGD,
      required this.isRoutePB,
      required this.isRouteTK,
      required this.isRouteTVPB});

  @override
  State<ListDiaDiem> createState() => _ListDiaDiemState();
}

// Timestamp.fromd
class _ListDiaDiemState extends State<ListDiaDiem> {
  // late Map<DateTime, List<Event>> _events;

  var _event;
  var selectedValue = 'Tất cả';
  var tenPB = '';
  @override
  void initState() {
    super.initState();
    _event = FirebaseFirestore.instance.collection('dia_diem');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Danh sách địa điểm', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                // Row(
                //   children: [
                //     SizedBox(
                //       width: 10,
                //     ),
                //     Text('Lọc:'),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     DropdownButton(
                //       hint: Text('Chọn tùy chọn'),
                //       value: selectedValue,
                //       onChanged: (newValue) {
                //         setState(() {
                //           selectedValue = newValue.toString()!;
                //           getData();
                //         });
                //       },
                //       items: [
                //         DropdownMenuItem(
                //           child: Text('Tất cả'),
                //           value: 'Tất cả',
                //         ),
                //         DropdownMenuItem(
                //           child: Text('Hoạt động'),
                //           value: 'Hoạt động',
                //         ),
                //         DropdownMenuItem(
                //           child: Text('Bị khoá'),
                //           value: 'Bị khoá',
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                SizedBox(
                  width: 10,
                ),
                Wrap(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Tìm địa điểm(theo tên)',
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
                              .collection('dia_diem')
                              .where('ten_dia_diem',
                                  isGreaterThanOrEqualTo: value)
                              .orderBy('ten_dia_diem')
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
                return ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    // DateTime ngay_toi_thieu =
                    //     documentSnapshot['ngay_toi_thieu'].toDate();
                    // String formatngay_toi_thieu =
                    //     DateFormat('dd/MM/yyyy').format(ngay_toi_thieu);
                    if (widget.isRouteGD == false &&
                        widget.isRouteTK == false) {
                      if (documentSnapshot['is_from_google_calendar'] == true)
                        return Container(
                          height: 0,
                        );
                    }
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: widget.isRoutePB || widget.isRouteTVPB
                          ? ListTile(
                              title: Text(documentSnapshot['ten_dia_diem']),
                              subtitle: Text(documentSnapshot['ghi_chu']),
                              trailing: documentSnapshot['trang_thai']
                                  ? Text('')
                                  : Text('Bị khoá'),
                            )
                          : ListTile(
                              onTap: () async {
                                final res = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListDiaDiemDetails(
                                      documentSnapshot.id,
                                      widget.isRouteGD,
                                    ),
                                  ),
                                );
                                print(documentSnapshot.id);
                                //Navigator.of(context).maybePop();
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
                              title: Text(documentSnapshot['ten_dia_diem']),
                              subtitle: Text(documentSnapshot['ghi_chu']),
                              trailing: documentSnapshot['trang_thai']
                                  ? Text('')
                                  : Text('Bị khoá'),
                              // trailing: PopupMenuButton(
                              //     icon: Icon(Icons.more_vert),
                              //     itemBuilder: (context) => [
                              //           PopupMenuItem(
                              //               child: ListTile(
                              //             leading: Icon(Icons.edit),
                              //             title: Text('Chi tiết'),
                              //             onTap: () async {
                              //               print(documentSnapshot.id);
                              //               final res = await Navigator.push<bool>(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                   builder: (_) => ItemDetailsThuKi(
                              //                       documentSnapshot.id, true, false),
                              //                 ),
                              //               );
                              //               Navigator.of(context).maybePop();
                              //             },
                              //           )),
                              //           PopupMenuItem(
                              //               child: ListTile(
                              //             leading: Icon(Icons.delete),
                              //             title: Text('Chọn'),
                              //           )),
                              //         ]),
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
