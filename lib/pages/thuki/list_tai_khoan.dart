import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';

import 'package:khoa_luan1/pages/thuki/duyet_event_main.dart';
import 'package:khoa_luan1/pages/thuki/list_tai_khoan_details.dart';
import '../../list_event.dart';
import '../../data/selectedDay.dart';
import 'duyet_event_main.dart';
import 'item_details_tk.dart';
import 'list_phong_ban_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/UserID.dart';

class ListTaiKhoan extends StatefulWidget {
  ListTaiKhoan({super.key});

  @override
  State<ListTaiKhoan> createState() => _ListTaiKhoanState();
}

// Timestamp.fromd
class _ListTaiKhoanState extends State<ListTaiKhoan> {
  // late Map<DateTime, List<Event>> _events;

  var _event;
  var selectedValue = 'Tất cả';
  var tenPB = '';
  @override
  void initState() {
    super.initState();
    _event = FirebaseFirestore.instance.collection('tai_khoan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Danh sách tài khoản', style: TextStyle(color: Colors.white)),
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
                        hintText: 'Tìm tài khoản(theo tên)',
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
                              .collection('tai_khoan')
                              .where('ten', isGreaterThanOrEqualTo: value)
                              .orderBy('ten')
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
                    if (documentSnapshot.id == UserID.localUID) {
                      return Container(height: 0);
                    }
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () async {
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ListTaiKhoanDetails(
                                      userIDString: documentSnapshot.id,
                                    )),
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
                        title: Text(documentSnapshot['ten']),
                        subtitle: Text(documentSnapshot['email']),
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
