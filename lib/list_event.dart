import 'package:flutter/material.dart';
import 'package:khoa_luan1/model/event.dart';
import 'package:intl/intl.dart';

class ListEvent extends StatelessWidget {
  final Event event;
  //final Function() onDelete;
  final Function()? onTap;
  const ListEvent({
    Key? key,
    required this.event,
    // required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime datetime_BD = event.ngay_gio_bat_dau;
    DateTime datetime_kt = event.ngay_gio_ket_thuc;
    String formattedTime_BD = DateFormat('HH:mm').format(datetime_BD);
    String formattedTime_KT = DateFormat('HH:mm').format(datetime_kt);
    return ListTile(
      title: Text(
        event.tieu_de,
      ),
      subtitle: Text(
        event.dia_diem,
      ),
      trailing: Text('Lúc ' + formattedTime_BD + '\nđến ' + formattedTime_KT),
      onTap: onTap,
//onLongPress: print(event.dia_diem),
      // trailing: IconButton(
      //   icon: const Icon(Icons.delete),
      //   onPressed: onDelete,
      // ),
    );
  }
}
