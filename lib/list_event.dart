import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ListEvent extends StatefulWidget {
  final Event event;
  //final Function() onDelete;
  final Function()? onTap;
  ListEvent({
    Key? key,
    required this.event,
    // required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  State<ListEvent> createState() => _ListEventState();
}

class _ListEventState extends State<ListEvent> {
  var diaDiem = '';
  late bool isLoading = false;
  void initState() {
    // layDiaDiem();
  }

  @override
  Widget build(BuildContext context) {
    DateTime datetime_BD = widget.event.ngay_gio_bat_dau;
    DateTime datetime_kt = widget.event.ngay_gio_ket_thuc;
    String formattedTime_BD = DateFormat('HH:mm').format(datetime_BD);
    // bool _isBuoiSang = false;
    String formattedTime_KT = DateFormat('HH:mm').format(datetime_kt);
    return
        //  isLoading
        //     ? Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: [
        //             CircularProgressIndicator(),
        //             Text(
        //               "Đang tải",
        //               style: TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 color: Colors.black,
        //                 fontSize: 20,
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     :
        ListTile(
      title: Text(
        widget.event.tieu_de,
      ),
      subtitle: widget.event.is_from_google_calendar
          ? Text('Từ google Calendar')
          : Text(''),
      trailing: Text('Lúc ' + formattedTime_BD + '\nđến ' + formattedTime_KT),
      onTap: widget.onTap,
//onLongPress: print(event.dia_diem),
      // trailing: IconButton(
      //   icon: const Icon(Icons.delete),
      //   onPressed: onDelete,
      // ),
    );
  }

  // void layDiaDiem() async {
  //   final eventCollection = FirebaseFirestore.instance.collection('cong_viec');
  //   final eventDoc = await eventCollection.doc(widget.event.id).get();
  //   final phongBanCollection =
  //       FirebaseFirestore.instance.collection('dia_diem');
  //   final phongBanDoc =
  //       await phongBanCollection.doc(eventDoc['dia_diem_id']).get();
  //   final ten_dia_diem = phongBanDoc['ten_dia_diem'];
  //   diaDiem = ten_dia_diem;
  //   //setState(() {});
  // }
}
