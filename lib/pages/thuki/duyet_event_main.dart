import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'duyet_event_list.dart';
import '../../data/selectedDay.dart';
import 'TK_home_page.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/model/event.dart';
import '../../data/selectedDay.dart';

class DuyetEventMain extends StatefulWidget {
  @override
  final String eventID;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  const DuyetEventMain(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      this.selectedDate,
      required this.eventID})
      : super(key: key);
  _DuyetEventMainState createState() => _DuyetEventMainState();
}

class _DuyetEventMainState extends State<DuyetEventMain> {
  //late String _ten_cong_viec;
  // final _phutController = TextEditingController();
  //lấy ngày hôm nay
  // DateTime now1 = DateTime.now();
  DateTime currentDate = dataSelectedDay.selectedDay;
  //time stamp trong hom nay

  final _ngay_dien_ra =
      DateFormat('dd/MM/yyyy').format(dataSelectedDay.selectedDay);

  TimeOfDay _gio_bat_dau_tod = TimeOfDay.now();
  final _tieu_deController = TextEditingController();
  final _ten_cong_viecController = TextEditingController();
  final _thoi_gian_dien_raController = TextEditingController();
  final _thoi_gian_ket_thucController = TextEditingController();
  final _ngay_toi_thieuController = TextEditingController();
  final _phut_max = 60;
  final _gio_bat_dauController = TextEditingController();

  late int _gio = 0;
  late int _phut = 0;
  final _formKey = GlobalKey<FormState>();
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;
  final today = DateTime.now();
  final startOfToday = dataSelectedDay.selectedDay;
  final endOfToday = DateTime(
      dataSelectedDay.selectedDay.year,
      dataSelectedDay.selectedDay.month,
      dataSelectedDay.selectedDay.day,
      23,
      59,
      59);
  //bool flag = true;
  //int _radioValue = 0;
  late Map data;
  late List<Event> _events;
  var _tenPB = '';
  var _emailPB = '';
  var _app_password = '';
  var _email_TK = '';
  var _ten_tk = '';
  var _ngay_post = '';
  var _ngay_toi_thieu = '';
  //final daytimeSang = DateTime(now.year, now.month, now.day, 23, 59, 59);
  //Timestamp sang7h=Timestamp.fromDate(startOfToday);
  Timestamp _xet_trang_thai_ts = Timestamp.fromDate(now);
  void _selectDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime.now().add(Duration(days: 365)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        //  _selectedDate = pickedDate;
        //_ngay_de_xuat.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        _ngay_toi_thieuController.text = pickedDate.toString();
      });
    });
  }

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    super.initState();
    print(widget.eventID);
    final _reference =
        FirebaseFirestore.instance.collection('cong_viec').doc(widget.eventID);
    _futureData = _reference.get();
    _ngay_toi_thieuController.text = dataSelectedDay.selectedDay.toString();
    _gio_bat_dauController.text =
        '${_gio_bat_dau_tod.hour} giờ ${_gio_bat_dau_tod.minute} phút';
    print(_gio_bat_dauController.text);
    print(currentDate.toString());
    _loadData();
    _doi_trang_thai_cong_viec(_xet_trang_thai_ts);
    print(startOfToday.toString() + endOfToday.toString());
    print(uid);
    getName();
    //nếu công việc đã duyệt + xảy ra rồi thì không xét công việc đó(tối ưu truy vấn)
    //xảy ra rồi => datetime.now <= giờ kết thúc => update trang_thai==false

    //lấy danh sách công việc thư kí đã duyệt hôm nay đưa vào list
  }

  getName() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    final orderId = widget.eventID;

    final eventDoc = await ordersCollection.doc(orderId).get();

    final userId = eventDoc['tai_khoan_id'];
    final userDoc = await usersCollection.doc(userId).get();

    DateTime ngay_toi_thieuDate = eventDoc['ngay_toi_thieu'].toDate();
    _ngay_toi_thieu = DateFormat('dd/MM/yyyy').format(ngay_toi_thieuDate);

    DateTime ngay_postDate = eventDoc['ngay_post'].toDate();
    _ngay_post = DateFormat('dd/MM/yyyy').format(ngay_postDate);
    _tenPB = userDoc['ten'];
    _emailPB = userDoc['email'];

    final thuKiDoc = await usersCollection.doc(uid).get();
    final email_TK = thuKiDoc['email'];
    final app_Password = thuKiDoc['app_password'];
    final ten_TK = thuKiDoc['ten'];
    _email_TK = email_TK;
    _ten_tk = ten_TK;
    _app_password = app_Password;
    print(_email_TK);
    setState(() {});
    //print(tenPB);
  }

  // Future<bool> _check_cong_viec_trong_va_ngoai_khoang(
  //     Timestamp gioBd, gioKt) async {
  //   _events = [];
  //   final snap = await FirebaseFirestore.instance
  //       .collection('cong_viec')
  //       .where('tk_duyet', isEqualTo: true)
  //       .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
  //       .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
  //       .withConverter(
  //           fromFirestore: Event.fromFirestore,
  //           toFirestore: (event, options) => event.toFirestore())
  //       .get();
  //   Timestamp listGioBd;
  //   Timestamp listGioKt;
  //   for (var doc in snap.docs) {
  //     final event = doc.data();
  //     _events.add(event);
  //     listGioBd = Timestamp.fromDate(event.ngay_gio_bat_dau);
  //     listGioKt = Timestamp.fromDate(event.ngay_gio_ket_thuc);
  //     //dương là lớn hơn âm là bé hơn
  //     int bd = gioBd.compareTo(listGioBd);
  //     int bd1 = gioBd.compareTo(listGioKt);
  //     int kt = gioKt.compareTo(listGioBd);
  //     int kt1 = gioKt.compareTo(listGioKt);
  //     //nằm trong khoảng
  //     if (bd > 0 && bd1 < 0) {
  //       return false;
  //     }
  //     //công việc thêm vào nuốt công việc trong list
  //     else if (bd < 0 && kt > 0) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }
  void sendMail() async {
    var tk_email = _email_TK;
    final smtpServer = gmail(tk_email.toString(), _app_password);
    final message = Message()
      ..from = Address(tk_email.toString(), _ten_tk)
      ..recipients.add(_emailPB.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Gửi phòng ban ' + _tenPB + ' công việc đã duyệt thành công!'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc đã được duyệt!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2>\n<h2>-Ngày post : ${_ngay_post}\n<h2>-Ngày tối thiểu : ${_ngay_toi_thieu}</h2></h2>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  void _doi_trang_thai_cong_viec(Timestamp _datetime_now) async {
    final eventsRef = FirebaseFirestore.instance.collection('cong_viec');
    final query = eventsRef
        .where('ngay_gio_ket_thuc', isLessThanOrEqualTo: _datetime_now)
        .where('tk_duyet', isEqualTo: true);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    for (final doc in docs) {
      final ref = doc.reference;
      await ref.update({'trang_thai': false});
    }
    print('doi trang thai cong viec thanh cong');
  }

  void _loadData() async {
    final document = await FirebaseFirestore.instance
        .collection('cong_viec')
        .doc(widget.eventID)
        .get();
    if (document.exists) {
      final data = document.data();
      _ten_cong_viecController.text = data!['ten_cong_viec'];
      _thoi_gian_dien_raController.text = data['thoi_gian_cv'];
      _tieu_deController.text = data['tieu_de'];
    }
  }

  void tinhThoiGianKetThuc(int _phut_dien_ra) {
    // // _phut = int.parse(${_gio_bat_dau_tod}) +
    // //     int.parse(_thoi_gian_dien_raController.text);
    _gio = _gio_bat_dau_tod.hour;
    _phut = _phut_dien_ra + _gio_bat_dau_tod.minute;
    print(_phut);
    while (_phut >= 60) {
      _gio = _gio + 1;
      _phut = _phut - 60;
    }
    setState(() {});
  }

//xài list
  // void _listEvent() async {
  //   _events = [];
  //   final snap = await FirebaseFirestore.instance
  //       .collection('cong_viec')
  //       .where('tk_duyet', isEqualTo: true)
  //       .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
  //       .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
  //       .withConverter(
  //           fromFirestore: Event.fromFirestore,
  //           toFirestore: (event, options) => event.toFirestore())
  //       .get();
  //   for (var doc in snap.docs) {
  //     final event = doc.data();
  //     _events.add(event);
  //     print(event.ten_cong_viec);
  //   }
  // }

  void _showmessage(String _massage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Center(
            child: Text(
              '$_massage',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  _duyetEvent() async {
    if (_formKey.currentState!.validate()) {
      late Timestamp timestampKt;
      late Timestamp timestampBd;
      late Timestamp listGioBd;
      late Timestamp listGioKt;
      //   print('validate ok');
      Duration durationtoaddKt = Duration(hours: _gio, minutes: _phut);
      DateTime _ngay_gio_ket_thuc = currentDate.add(durationtoaddKt);
      timestampKt = Timestamp.fromDate(_ngay_gio_ket_thuc);
      //timestamp bắt đầu

      Duration durationtoaddBd = Duration(
          hours: _gio_bat_dau_tod.hour, minutes: _gio_bat_dau_tod.minute);
      DateTime _ngay_gio_bat_dau = currentDate.add(durationtoaddBd);
      timestampBd = Timestamp.fromDate(_ngay_gio_bat_dau);
      var checkbool;
      _events = [];
      final snap = await FirebaseFirestore.instance
          .collection('cong_viec')
          .where('tk_duyet', isEqualTo: true)
          .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: startOfToday)
          .where('ngay_gio_bat_dau', isLessThanOrEqualTo: endOfToday)
          .withConverter(
              fromFirestore: Event.fromFirestore,
              toFirestore: (event, options) => event.toFirestore())
          .get();
      for (var doc in snap.docs) {
        final event = doc.data();
        _events.add(event);
        listGioBd = Timestamp.fromDate(event.ngay_gio_bat_dau);
        listGioKt = Timestamp.fromDate(event.ngay_gio_ket_thuc);
        //dương là lớn hơn âm là bé hơn
        int bd = timestampBd.compareTo(listGioBd);
        int bd1 = timestampBd.compareTo(listGioKt);
        int kt = timestampKt.compareTo(listGioBd);
        int kt1 = timestampKt.compareTo(listGioKt);
        //nằm trong khoảng
        if (bd > 0 && bd1 < 0) {
          checkbool = false;
        }
        //công việc thêm vào nuốt công việc trong list
        else if (bd < 0 && kt > 0) {
          checkbool = false;
        }
      }
//kiểm tra lại
      try {
        print('validate ok');
        print(timestampBd.toDate().toString());
        print(timestampKt.toDate().toString());

        // Query query1 = FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('trang_thai', isEqualTo: true)
        //     .where('tk_duyet', isEqualTo: true)
        //     .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: timestamp_BD)
        //     .where('ngay_gio_ket_thuc', isLessThan: timestamp_BD);
        // Query query2 = FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('trang_thai', isEqualTo: true)
        //     .where('tk_duyet', isEqualTo: true)
        //     .where('ngay_gio_bat_dau', isGreaterThan: timestamp_KT)
        //     .where('ngay_gio_ket_thuc', isLessThanOrEqualTo: timestamp_KT);
        // Query query3 = FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('trang_thai', isEqualTo: true)
        //     .where('tk_duyet', isEqualTo: true)
        //     .where('ngay_gio_bat_dau', isEqualTo: timestamp_BD)
        //     .where('ngay_gio_ket_thuc', isEqualTo: timestamp_KT);
        // Query query4 = FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('trang_thai', isEqualTo: true)
        //     .where('tk_duyet', isEqualTo: true)
        //     .where('ngay_gio_bat_dau', isEqualTo: timestamp_BD);
        // QuerySnapshot querySnapshot = await query1.get();
        // QuerySnapshot querySnapshot1 = await query2.get();
        // QuerySnapshot querySnapshot2 = await query3.get();
        // QuerySnapshot querySnapshot3 = await query4.get();
        // List<DocumentSnapshot> documents1 = querySnapshot.docs;
        // List<DocumentSnapshot> documents2 = querySnapshot1.docs;
        // List<DocumentSnapshot> documents3 = querySnapshot2.docs;
        // List<DocumentSnapshot> documents4 = querySnapshot3.docs;
        // List<DocumentSnapshot> documents = [
        //   ...documents1,
        //   ...documents2,
        //   ...documents3,
        //   ...documents4
        // ];
        // for (var event in _events) {
        // list_gio_BD = Timestamp.fromDate(event.ngay_gio_bat_dau);
        // list_gio_KT = Timestamp.fromDate(event.ngay_gio_ket_thuc);
        // //dương là lớn hơn âm là bé hơn
        // int bd = timestamp_BD.compareTo(list_gio_BD);
        // int bd1 = timestamp_BD.compareTo(list_gio_KT);
        // int kt = timestamp_KT.compareTo(list_gio_BD);
        // int kt1 = timestamp_KT.compareTo(list_gio_KT);
        // // if (bd > 0 && bd1 < 0) {
        // //   flag = false;
        // //   //lớn hơn bắt đầu bé hơn kết thúc (nằm trong công việc khác)
        // //   return _showmessage('Giờ bắt đầu nằm trong công việc khác');
        // // }
        // // if (kt > 0 && kt1 < 0) {
        // //   flag = false;
        // //   return _showmessage('Giờ kết thúc nằm trong công việc khác');
        // // }
        // // if (bd == 0 && kt1 == 0) {
        // //   flag = false;
        // //   return _showmessage('Giờ bắt đầu và kết thúc trùng công việc khác');
        // // }
        // // if (bd > 0 && kt1 < 0) {
        // //   flag = false;
        // //   return _showmessage(
        // //       'Giờ bắt đầu và kết thúc nằm trong công việc khác');
        // // }
        // // if (bd == 0 || kt1 == 0) {
        // //   flag = false;
        // //   return _showmessage(
        // //       'Giờ bắt đầu hoặc kết thúc trùng công việc khác');
        // // }
        // // if (bd < 0 && kt1 > 0) {
        // //   flag = false;
        // //   return _showmessage(
        // //       'Có một công việc khác nằm trong công việc này');
        // // }
        // // print('test');
        // if (bd < 0 && kt < 0 || kt == 0) {
        //   // await FirebaseFirestore.instance
        //   //     // .collection('tai_khoan')
        //   //     // .doc(uid)
        //   //     .collection('cong_viec')
        //   //     .doc(widget.eventID)
        //   //     .update({
        //   //   "tk_duyet": true,
        //   //   "ngay_gio_ket_thuc": timestamp_KT,
        //   //   "ngay_gio_bat_dau": timestamp_BD
        //   // });
        //   // Navigator.pop(context);
        //   print('test');
        // } else if (bd1 > 0 || bd1 == 0 && kt1 > 0) {
        //   // await FirebaseFirestore.instance
        //   //     // .collection('tai_khoan')
        //   //     // .doc(uid)
        //   //     .collection('cong_viec')
        //   //     .doc(widget.eventID)
        //   //     .update({
        //   //   "tk_duyet": true,
        //   //   "ngay_gio_ket_thuc": timestamp_KT,
        //   //   "ngay_gio_bat_dau": timestamp_BD
        //   // });
        //   // Navigator.pop(context);
        //   print('test');
        // } else {
        //   _showmessage('Trùng lịch');
        // }
        // }
        // if (flag == true) {
        //   print('test');
        // }
        // if (documents.isEmpty) {
        //   await FirebaseFirestore.instance
        //       // .collection('tai_khoan')
        //       // .doc(uid)
        //       .collection('cong_viec')
        //       .doc(widget.eventID)
        //       .update({
        //     "tk_duyet": true,
        //     "ngay_gio_ket_thuc": timestamp_KT,
        //     "ngay_gio_bat_dau": timestamp_BD
        //   });
        //   if (mounted) {
        //     Navigator.pop<bool>(context, true);
        //     //           //PhongBanHomePage();
        //     //         }
        //   } else {
        //     showDialog(
        //       context: context,
        //       builder: (context) {
        //         return AlertDialog(
        //           backgroundColor: Color.fromARGB(255, 255, 0, 0),
        //           title: Center(
        //             child: Text(
        //               'Trùng lịch!',
        //               style: const TextStyle(color: Colors.white),
        //             ),
        //           ),
        //         );
        //       },
        //     );
        //   }
        // }
        //lấy dự liệu timestamp trong database ra nếu có tình trả về showdialog nếu ko thì thực hiện update
        //_gio và _phut là ngày giờ kết thúc
        //chọn giờ bắt đầu và kết thúc của thư kí đã duyệt và có ngày giờ kết thúc
        //   //LỖI
        //   QuerySnapshot querySnapshot10 = await FirebaseFirestore.instance
        //       .collection('cong_viec')
        //       .where('trang_thai', isEqualTo: true)
        //       .where('tk_duyet', isEqualTo: true)
        //       .where('ngay_gio_bat_dau', isGreaterThan: timestamp_BD)
        //       .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: timestamp_KT)
        //       .get();
        //   QuerySnapshot querySnapshot11 = await FirebaseFirestore.instance
        //       .collection('cong_viec')
        //       .where('trang_thai', isEqualTo: true)
        //       .where('tk_duyet', isEqualTo: true)
        //       .where('ngay_gio_ket_thuc', isLessThanOrEqualTo: timestamp_BD)
        //       .where('ngay_gio_ket_thuc', isLessThan: timestamp_KT)
        //       .get();
        //   if (querySnapshot10.docs.isEmpty) {
        //     if (querySnapshot11.docs.isEmpty) {
        //       print('thêm');
        //     }
        //   } else {
        //     _showmessage('khong6 them');
        //   }
        // } catch (e) {
        //   print(e);
        // }
        //LỖI
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('cong_viec')
            .where('trang_thai', isEqualTo: true)
            .where('tk_duyet', isEqualTo: true)
            .where('ngay_gio_bat_dau', isGreaterThan: timestampBd)
            .where('ngay_gio_bat_dau', isLessThan: timestampKt) //
            .get();
        QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
            .collection('cong_viec')
            .where('trang_thai', isEqualTo: true)
            .where('tk_duyet', isEqualTo: true)
            .where('ngay_gio_ket_thuc', isLessThan: timestampKt)
            .where('ngay_gio_ket_thuc', isGreaterThan: timestampBd)
            .get();
        // QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        //     .collection('cong_viec')
        //     .where('trang_thai', isEqualTo: true)
        //     .where('tk_duyet', isEqualTo: true)
        //     .where('ngay_gio_bat_dau', isLessThanOrEqualTo: timestamp_BD)
        //     .where('ngay_gio_ket_thuc', isGreaterThanOrEqualTo: timestamp_KT)
        //     .get();
        QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
            .collection('cong_viec')
            .where('trang_thai', isEqualTo: true)
            .where('tk_duyet', isEqualTo: true)
            .where('ngay_gio_bat_dau', isEqualTo: timestampBd)
            .get();

        if (querySnapshot.docs.isEmpty == true &&
            querySnapshot1.docs.isEmpty == true &&
            querySnapshot3.docs.isEmpty == true &&
            checkbool != false) {
          await FirebaseFirestore.instance
              .collection('cong_viec')
              .doc(widget.eventID)
              .update({
            "tk_duyet": true,
            "ngay_gio_ket_thuc": timestampKt,
            "ngay_gio_bat_dau": timestampBd
          });
          print('thêm');
          if (mounted) {
            sendMail();
            Navigator.pop<bool>(context, true);
            //PhongBanHomePage();
          }
        } else {
          _showmessage('Giờ bắt đầu trùng');
        }
      } catch (e) {
        print(e);
      }
      //lấy dự liệu timestamp trong database ra nếu có tình trả về showdialog nếu ko thì thực hiện update
      //_gio và _phut là ngày giờ kết thúc
      //chọn giờ bắt đầu và kết thúc của thư kí đã duyệt và có ngày giờ kết thúc
      //LỖI
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('cong_viec')
      //     .where('trang_thai', isEqualTo: true)
      //     .where('tk_duyet', isEqualTo: true)
      //     .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: timestamp_BD)
      //     .where('ngay_gio_ket_thuc', isLessThan: timestamp_BD)
      //     .get();
      // if (querySnapshot.docs
      //     .isEmpty) //ngày giờ bắt đầu trong database không trùng ngày giờ bắt đầu thêm vô
      // {
      //   QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
      //       .collection('cong_viec')
      //       .where('trang_thai', isEqualTo: true)
      //       .where('tk_duyet', isEqualTo: true)
      //       .where('ngay_gio_bat_dau', isGreaterThan: timestamp_KT)
      //       .where('ngay_gio_ket_thuc', isLessThanOrEqualTo: timestamp_KT)
      //       .get();
      //   if (querySnapshot1.docs.isEmpty) //khong có dữ liệu tiến hành update
      //   {
      //     QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
      //         .collection('cong_viec')
      //         .where('trang_thai', isEqualTo: true)
      //         .where('tk_duyet', isEqualTo: true)
      //         .where('ngay_gio_bat_dau', isEqualTo: timestamp_BD)
      //         .where('ngay_gio_ket_thuc', isEqualTo: timestamp_KT)
      //         .get();
      //     if (querySnapshot2.docs.isEmpty) {
      //       QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
      //           .collection('cong_viec')
      //           .where('trang_thai', isEqualTo: true)
      //           .where('tk_duyet', isEqualTo: true)
      //           .where('ngay_gio_bat_dau', isEqualTo: timestamp_BD)
      //           .get();
      //       if (querySnapshot3.docs.isEmpty) {
      //         await FirebaseFirestore.instance
      //             // .collection('tai_khoan')
      //             // .doc(uid)
      //             .collection('cong_viec')
      //             .doc(widget.eventID)
      //             .update({
      //           "tk_duyet": true,
      //           "ngay_gio_ket_thuc": timestamp_KT,
      //           "ngay_gio_bat_dau": timestamp_BD
      //         });
      //         if (mounted) {
      //           Navigator.pop<bool>(context, true);
      //           //PhongBanHomePage();
      //         }
      //       } else {
      //         showDialog(
      //           context: context,
      //           builder: (context) {
      //             return AlertDialog(
      //               backgroundColor: Color.fromARGB(255, 255, 0, 0),
      //               title: Center(
      //                 child: Text(
      //                   'Giờ bắt đầu trùng',
      //                   style: const TextStyle(color: Colors.white),
      //                 ),
      //               ),
      //             );
      //           },
      //         );
      //       }
      //     } else {
      //       showDialog(
      //         context: context,
      //         builder: (context) {
      //           return AlertDialog(
      //             backgroundColor: Color.fromARGB(255, 255, 0, 0),
      //             title: Center(
      //               child: Text(
      //                 'Giờ bắt đầu hoặc kết thúc trùng',
      //                 style: const TextStyle(color: Colors.white),
      //               ),
      //             ),
      //           );
      //         },
      //       );
      //     }
      //   } else {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           backgroundColor: Color.fromARGB(255, 255, 0, 0),
      //           title: Center(
      //             child: Text(
      //               'Giờ kết thúc trùng với một công việc khác',
      //               style: const TextStyle(color: Colors.white),
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   }
      // } else {
      //   showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         backgroundColor: Color.fromARGB(255, 255, 0, 0),
      //         title: Center(
      //           child: Text(
      //             'Giờ bắt đầu trùng với một công việc khác',
      //             style: const TextStyle(color: Colors.white),
      //           ),
      //         ),
      //       );
      //     },
      //   );
      // }
      //nếu công việc thêm vào nằm ngoài công việc trong list thì thêm vào
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('cong_viec')
      //     .where('tk_duyet', isEqualTo: true)
      //     .where('ngay_gio_bat_dau', isLessThanOrEqualTo: timestamp_BD)
      //     .where('ngay_gio_ket_thuc', isGreaterThanOrEqualTo: timestamp_BD)
      //     .get();
      // if (querySnapshot.docs.isEmpty) {
      //   QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
      //       .collection('cong_viec')
      //       .where('tk_duyet', isEqualTo: true)
      //       .where('ngay_gio_bat_dau', isLessThanOrEqualTo: timestamp_KT)
      //       .where('ngay_gio_ket_thuc', isGreaterThanOrEqualTo: timestamp_KT)
      //       .get();
      //   if (querySnapshot1.docs.isEmpty) {
      //     await FirebaseFirestore.instance
      //         // .collection('tai_khoan')
      //         // .doc(uid)
      //         .collection('cong_viec')
      //         .doc(widget.eventID)
      //         .update({
      //       "tk_duyet": true,
      //       "ngay_gio_ket_thuc": timestamp_KT,
      //       "ngay_gio_bat_dau": timestamp_BD
      //     });
      //     if (mounted) {
      //       Navigator.pop<bool>(context, true);
      //       //PhongBanHomePage();
      //     }
      //   }
      // }
      print(timestampBd.toDate().toString());
      print(_gio_bat_dau_tod.hour.toString() +
          _gio_bat_dau_tod.minute.toString());

      // if (mounted) {
      //   Navigator.pop<bool>(context, true);
      //   //PhongBanHomePage();
      // }
      // } catch (e) {
      //   print(e);
      // }
      // }
    }
  }

  // _duyetEvent() async {
  //   _checkDuyetEvent();
  //   if (flag == true) {
  //     // await FirebaseFirestore.instance
  //     //     // .collection('tai_khoan')
  //     //     // .doc(uid)
  //     //     .collection('cong_viec')
  //     //     .doc(widget.eventID)
  //     //     .update({
  //     //   "tk_duyet": true,
  //     //   "ngay_gio_ket_thuc": timestamp_KT,
  //     //   "ngay_gio_bat_dau": timestamp_BD
  //     // });
  //     // if (mounted) {
  //     //   Navigator.pop<bool>(context, true);
  //     //   //PhongBanHomePage();
  //     // }
  //     print('test');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ThuKiHomePage()),
                  (route) => false,
                );
              },
              icon: Icon(
                Icons.clear,
                color: Colors.red,
              )),
        ),
        backgroundColor: Colors.grey[100],
        body: ListView(padding: const EdgeInsets.all(16.0), children: [
          Container(
              margin: EdgeInsets.all(4),
              color: Colors.grey[100],
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                  child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 7,
                          child: Container(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _tieu_deController,
                                  onTap: () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DuyetEventList(),
                                      ),
                                    );
                                    //if (result ?? false) {
                                    //  //loadFirestoreEvents();
                                    //}
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Tiêu đề',
                                    fillColor: Colors.white,
                                    hintText: 'Tiêu đề',
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Tên công việc không được để trống";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    _tieu_deController.text = value!;
                                  },
                                ),
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: _ten_cong_viecController,
                                  onTap: () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DuyetEventList(),
                                      ),
                                    );
                                    //if (result ?? false) {
                                    //  //loadFirestoreEvents();
                                    //}
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Tên công việc',
                                    fillColor: Colors.white,
                                    hintText: 'Tên công việc',
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Tên công việc không được để trống";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    _ten_cong_viecController.text = value!;
                                  },
                                ),
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: _gio_bat_dauController,
                                  onTap: () async {
                                    TimeOfDay? newTime = await showTimePicker(
                                        context: context,
                                        initialTime: _gio_bat_dau_tod);
                                    if (newTime == null) return;
                                    setState(() {
                                      _gio_bat_dau_tod = newTime;
                                      _gio_bat_dauController.text =
                                          '${_gio_bat_dau_tod.hour} giờ ${_gio_bat_dau_tod.minute} phút';
                                      tinhThoiGianKetThuc(int.parse(
                                          _thoi_gian_dien_raController.text));
                                      _thoi_gian_ket_thucController.text =
                                          _gio.toString() +
                                              ' giờ' +
                                              _phut.toString() +
                                              ' phút';
                                    });
                                  },
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Thời gian dự kiến không được để trống";
                                    }
                                    if (_gio_bat_dau_tod.hour == 11 &&
                                            _gio_bat_dau_tod.minute == 0 ||
                                        _gio_bat_dau_tod.hour == 17 &&
                                            _gio_bat_dau_tod.minute == 0) {
                                      return null;
                                    }
                                    if (_gio_bat_dau_tod.hour >= 7 &&
                                            _gio_bat_dau_tod.hour < 11 ||
                                        _gio_bat_dau_tod.hour >= 13 &&
                                            _gio_bat_dau_tod.hour < 17) {
                                      return null;
                                    } else {
                                      return "Thời gian bắt đầu ko hợp lệ";
                                    }
                                  },
                                  style: TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Thời gian dự kiến',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      //tính timestamp thời gian bắt đầu - kết thúc

                                      _gio_bat_dauController.text = value;
                                    });
                                  },
                                  //decoration: InputDecoration(),

                                  onSaved: (value) {
                                    _gio_bat_dauController.text = value!;
                                  },
                                ),
                                //   ],
                                // ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: _thoi_gian_dien_raController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Thời gian dự kiến',
                                    fillColor: Colors.white,
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Thời gian dự kiến không được để trống";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    _thoi_gian_dien_raController.text = value!;
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: _thoi_gian_ket_thucController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Thời gian dự kiến kết thúc',
                                    fillColor: Colors.white,
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Thời gian dự kiến kết thúc không được để trống";
                                    }
                                    if (_gio == 11 && _phut == 0 ||
                                        _gio == 17 && _phut == 0) {
                                      return null;
                                    }
                                    if (_gio >= 7 && _gio < 11 ||
                                        _gio >= 13 && _gio < 17) {
                                      return null;
                                    } else {
                                      return "Thời gian kết thúc ko hợp lệ";
                                    }
                                  },
                                  onSaved: (value) {
                                    _thoi_gian_ket_thucController.text = value!;
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Thời gian dự kiến bắt đầu',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 15.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.white),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  onTap: _selectDatePicker,
                                  controller: _ngay_toi_thieuController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Tên công việc không được để trống!";
                                    }
                                    if (value.length > 24) {
                                      return ("Ngày không hợp lệ!");
                                    }
                                    //thời gian bắt đầu bé hơn datetime.now thì lỗi
                                    if (DateTime.parse(value).isBefore(today)) {
                                      return ("Không được chọn ngày trong quá khứ!");
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    _ngay_toi_thieuController.text = value!;
                                  },
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () {
                                    _duyetEvent();
                                  },
                                  child: Text(
                                    "Lưu",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 3,
                          child: Container(
                              child: Column(children: [
                            SizedBox(
                              height: 5,
                            ),
                          ])))
                    ],
                  ),
                ),
              )))
        ]));
  }
}
