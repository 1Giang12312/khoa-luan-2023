import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khoa_luan1/pages/phongban/list_thong_bao_details.dart';

import '../../data/UserID.dart';
import 'PB_list_tai_khoan_detail.dart';

class ListThongBao extends StatefulWidget {
  String taiKhoanID;
  ListThongBao({super.key, required this.taiKhoanID});

  @override
  State<ListThongBao> createState() => _ListThongBaoState();
}

// Timestamp.fromd
class _ListThongBaoState extends State<ListThongBao> {
  // late Map<DateTime, List<Event>> _events;

  var _thong_bao;
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _thong_bao = FirebaseFirestore.instance
        .collection('thong_bao')
        .where('tai_khoan_id', isEqualTo: widget.taiKhoanID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Danh sách thông báo', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Đang xử lí!",
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
                  Column(
                    children: [
                      SizedBox(
                        width: 10,
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
                                    builder: (_) => ListThongBaoDetails(
                                        documentSnapshot.id),
                                  ),
                                );
                                print(documentSnapshot.id);
                                if (documentSnapshot['trang_thai_xem'] !=
                                    true) {
                                  await FirebaseFirestore.instance
                                      .collection('thong_bao')
                                      .doc(documentSnapshot.id)
                                      .update({'trang_thai_xem': true});
                                  try {} catch (e) {
                                    print(e);
                                  }
                                }
                              },
                              title: Text(documentSnapshot['tieu_de']),
                              leading:
                                  documentSnapshot['trang_thai_xem'] == true
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.close,
                                          color: Color.fromARGB(255, 255, 0, 0),
                                        ),
                            ),
                          );
                        },
                      );
                    },
                    stream: _thong_bao.snapshots(),
                  )
                ],
              ),
            ),
    );
  }
}
