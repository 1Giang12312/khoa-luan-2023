import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:http/http.dart';
import 'package:khoa_luan1/data/FCMtoken.dart';
import 'package:khoa_luan1/pages/thuki/TK_home_page.dart';
import 'package:khoa_luan1/pages/thuki/list_phong_ban.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../dashboard.dart';
import '../../login.dart';
import '../../data/selectedDay.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/model/event.dart';
import '../../data/selectedDay.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path1;
import '../../services/send_push_massage.dart';
import '../../data/UserID.dart';
import '../../login.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class GDAddEvent extends StatefulWidget {
  @override
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  const GDAddEvent(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      this.selectedDate})
      : super(key: key);
  _GDAddEventState createState() => _GDAddEventState();
}

class _GDAddEventState extends State<GDAddEvent> {
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
  final _dia_diemController = TextEditingController();
  final _ten_phong_banController = TextEditingController();
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

  var todaynow = DateTime.now().toString();

  late Map data;
  late List<Event> _events;

  String fileName = '';
  bool isfileNameExsited = false;
  File? file = null;
  var ranDomTenFilePDF = '';
  String fileName1 = '';
  bool isfileNameExsited1 = false;
  File? file1 = null;
  var ranDomTenFilePDF1 = '';

  var _tenPB = '';
  var _emailPB = '';

  var _tenPB1 = '';
  var _emailPB1 = '';

  var _tenPB2 = '';
  var _emailPB2 = '';

  var _tenPB3 = '';
  var _emailPB3 = '';

  var _tenPB4 = '';
  var _emailPB4 = '';

  var _app_password = '';

  var _email_GD = '';
  var _ten_GD = '';
  var _ngay_post = '';
  var tenFilePDF = '';
  var _ngay_toi_thieu = '';
  var fCMToken = '';
  var options = ['Cao', 'Vừa', 'Thấp'];
  var rool = "Vừa";
  var _currentItemSelected = "Vừa";
  late bool isLoading = false;
  List<DropdownMenuItem<String>> _categoriesList = [];
  String selectedPB = '0';
  int count = 0;
  String selectedPB1 = '0';
  bool isVisibleselectedPB1 = false;
  String selectedPB2 = '0';
  bool isVisibleselectedPB2 = false;
  String selectedPB3 = '0';
  bool isVisibleselectedPB3 = false;
  String selectedPB4 = '0';
  bool isVisibleselectedPB4 = false;
  String selectedDD = '0';
  String allSelectedPB = '';
  bool isLoadingGoogleCalendar = false;
  late Timestamp timestampBDGoolgeSheet;
  late Timestamp timestampKTGoolgeSheet;

  //final daytimeSang = DateTime(now.year, now.month, now.day, 23, 59, 59);
  //Timestamp sang7h=Timestamp.fromDate(startOfToday);
  //Timestamp _xet_trang_thai_ts = Timestamp.fromDate(now);
  bool _isChecked = false;
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

  String getRandString(int len, String uid, String tenFile) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    var base64UrlEncodeString = base64UrlEncode(values);
    return uid + '/' + tenFile + '_)()(_' + base64UrlEncodeString;
  }

//   getFCMToken() async {
//     if (selectedPB != '0') {
//       final usersCollection =
//           FirebaseFirestore.instance.collection('tai_khoan');
//       final userDoc = await usersCollection.doc(selectedPB).get();
//       fCMToken = userDoc['FCMtoken'];
//       print(fCMToken);
//     }
//      if (selectedPB1 != '0') {
//       final usersCollection =
//           FirebaseFirestore.instance.collection('tai_khoan');
//       final userDoc = await usersCollection.doc(selectedPB).get();
//       fCMToken = userDoc['FCMtoken'];
//       print(fCMToken);
//     }
//      if (selectedPB2 != '0') {
//       final usersCollection =
//           FirebaseFirestore.instance.collection('tai_khoan');
//       final userDoc = await usersCollection.doc(selectedPB).get();
//       fCMToken = userDoc['FCMtoken'];
//       print(fCMToken);
//     }
//      if (selectedPB3 != '0') {
//       final usersCollection =
//           FirebaseFirestore.instance.collection('tai_khoan');
//       final userDoc = await usersCollection.doc(selectedPB).get();
//       fCMToken = userDoc['FCMtoken'];
//       print(fCMToken);
//     } if (selectedPB4 != '0') {
//       final usersCollection =
//           FirebaseFirestore.instance.collection('tai_khoan');
//       final userDoc = await usersCollection.doc(selectedPB).get();
//       fCMToken = userDoc['FCMtoken'];
//       print(fCMToken);
//     }
// // thanh cong
//   }

  @override
  void initState() {
    //getFCMToken();
    super.initState();
    //print(widget.eventID);
    // final _reference =
    //     FirebaseFirestore.instance.collection('cong_viec').doc(widget.eventID);
    // _futureData = _reference.get();
    _ngay_toi_thieuController.text = dataSelectedDay.selectedDay.toString();
    _gio_bat_dauController.text =
        '${_gio_bat_dau_tod.hour} giờ ${_gio_bat_dau_tod.minute} phút';
    print(_gio_bat_dauController.text);
    print(currentDate.toString());
    // _doi_trang_thai_cong_viec(_xet_trang_thai_ts);
    print(startOfToday.toString() + endOfToday.toString());

    //getName();
  }

  getName() async {
    if (selectedDD != '0') {
      if (selectedPB != '0') {
        final usersCollection =
            FirebaseFirestore.instance.collection('phong_ban');
        final userDoc = await usersCollection.doc(selectedPB).get();

        _tenPB = userDoc['ten_phong_ban'];
        // _ten_phong_banController.text = _tenPB;
        _emailPB = userDoc['email'];

        print(_emailPB);
      }
      if (selectedPB1 != '0') {
        final usersCollection =
            FirebaseFirestore.instance.collection('phong_ban');
        final userDoc = await usersCollection.doc(selectedPB1).get();

        _tenPB1 = userDoc['ten_phong_ban'];
        // _ten_phong_banController.text = _tenPB;
        _emailPB1 = userDoc['email'];
        print(_emailPB1);
      }
      if (selectedPB2 != '0') {
        final usersCollection =
            FirebaseFirestore.instance.collection('phong_ban');
        final userDoc = await usersCollection.doc(selectedPB2).get();

        _tenPB2 = userDoc['ten_phong_ban'];
        // _ten_phong_banController.text = _tenPB;
        _emailPB2 = userDoc['email'];

        print(_emailPB2);
      }
      if (selectedPB3 != '0') {
        final usersCollection =
            FirebaseFirestore.instance.collection('phong_ban');
        final userDoc = await usersCollection.doc(selectedPB3).get();

        _tenPB3 = userDoc['ten_phong_ban'];
        // _ten_phong_banController.text = _tenPB;
        _emailPB3 = userDoc['email'];

        print(_emailPB3);
      }
      if (selectedPB4 != '0') {
        final usersCollection =
            FirebaseFirestore.instance.collection('phong_ban');
        final userDoc = await usersCollection.doc(selectedPB4).get();

        _tenPB4 = userDoc['ten_phong_ban'];
        // _ten_phong_banController.text = _tenPB;
        _emailPB4 = userDoc['email'];

        print(_emailPB4);
      }
      final usersCollection1 =
          FirebaseFirestore.instance.collection('tai_khoan');
      final giamdocDoc = await usersCollection1.doc(UserID.localUID).get();

      _email_GD = giamdocDoc['email'];
      _ten_GD = giamdocDoc['ten'];
      _app_password = giamdocDoc['app_password'];
      print(_email_GD);
    }
    //setState(() {});
    //print(tenPB);
  }

  void sendMail() async {
    getName();
    if (selectedPB != '0') {
      final smtpServer = gmail(_email_GD.toString(), _app_password);
      final message = Message()
        ..from = Address(_email_GD.toString(), _ten_GD)
        ..recipients.add(_emailPB.toString())
        // ..ccRecipients.addAll([_emailPB1, _emailPB2, _emailPB3, _emailPB4])
        // ..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Gửi phòng ban ' +
            _tenPB +
            ' công việc mới được thêm bởi giám đốc: ' +
            _ten_GD
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2></h2>";

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
    if (selectedPB1 != '0') {
      final smtpServer = gmail(_email_GD.toString(), _app_password);
      final message = Message()
        ..from = Address(_email_GD.toString(), _ten_GD)
        ..recipients.add(_emailPB1.toString())
        // ..ccRecipients.addAll([_emailPB1, _emailPB2, _emailPB3, _emailPB4])
        // ..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Gửi phòng ban ' +
            _tenPB1 +
            ' công việc mới được thêm bởi giám đốc: ' +
            _ten_GD
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2></h2>";

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
    if (selectedPB2 != '0') {
      final smtpServer = gmail(_email_GD.toString(), _app_password);
      final message = Message()
        ..from = Address(_email_GD.toString(), _ten_GD)
        ..recipients.add(_emailPB2.toString())
        // ..ccRecipients.addAll([_emailPB1, _emailPB2, _emailPB3, _emailPB4])
        // ..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Gửi phòng ban ' +
            _tenPB2 +
            ' công việc mới được thêm bởi giám đốc: ' +
            _ten_GD
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2></h2>";

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
    if (selectedPB3 != '0') {
      final smtpServer = gmail(_email_GD.toString(), _app_password);
      final message = Message()
        ..from = Address(_email_GD.toString(), _ten_GD)
        ..recipients.add(_emailPB3.toString())
        // ..ccRecipients.addAll([_emailPB1, _emailPB2, _emailPB3, _emailPB4])
        // ..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Gửi phòng ban ' +
            _tenPB3 +
            ' công việc mới được thêm bởi giám đốc: ' +
            _ten_GD
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2></h2>";

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
    if (selectedPB4 != '0') {
      final smtpServer = gmail(_email_GD.toString(), _app_password);
      final message = Message()
        ..from = Address(_email_GD.toString(), _ten_GD)
        ..recipients.add(_emailPB4.toString())
        // ..ccRecipients.addAll([_emailPB1, _emailPB2, _emailPB3, _emailPB4])
        // ..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Gửi phòng ban ' +
            _tenPB4 +
            ' công việc mới được thêm bởi giám đốc: ' +
            _ten_GD
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_dien_raController.text} phút</h2>\n<h2>-Ngày diễn ra: ${_ngay_dien_ra}</h2>\n<h2>-Thời gian bắt đầu: ${_gio_bat_dauController.text}</h2>\n<h2>-Thời gian kết thúc : ${_thoi_gian_ket_thucController.text}</h2></h2>";

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
  }

  void tinhThoiGianKetThuc(int _phut_dien_ra) {
    if (_thoi_gian_dien_raController.text.length == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
                'Hãy nhập thời gian dự kiến diễn ra(phút)',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    } else {
      _gio = _gio_bat_dau_tod.hour;
      _phut = _phut_dien_ra + _gio_bat_dau_tod.minute;
      print(_phut);
      while (_phut >= 60) {
        _gio = _gio + 1;
        _phut = _phut - 60;
      }
      setState(() {});
    }
  }

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

  Future<firebase_storage.UploadTask?> uploadFile(
      File file, String tenFile) async {
    //var luuTenFilePDF = tenFilePDF;
    if (file == null || tenFilePDF == fileName + '_' + UserID.localUID + '_') {
      print('no picked file');
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('pdf_files')
        .child('/${tenFile}');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'file/pdf',
        customMetadata: {'picked-file-path': file.path});
    print("Uploading..!");

    uploadTask = ref.putData(await file.readAsBytes(), metadata);

    print("done..!");
    return Future.value(uploadTask);
  }

  Timestamp _convertToTimeStamp(String date) {
    DateTime dateTime = DateTime.parse(date);

// Chuyển đổi đối tượng DateTime thành UTC
    DateTime dateTimeUtc = dateTime.toUtc();

// Chuyển đổi đối tượng DateTime thành Timestamp
    Timestamp timestamp = Timestamp.fromDate(dateTimeUtc);
    return timestamp;
  }

  _duyetEvent() async {
    setState(() {
      isLoading = true;
    });
    if (fileName == '' && fileName1 == '') {
      tenFilePDF = '';
    } else if (fileName != '' && fileName1 == '') {
      tenFilePDF = ranDomTenFilePDF;
    } else if (fileName == '' && fileName1 != '') {
      tenFilePDF = ranDomTenFilePDF1;
    } else {
      tenFilePDF = ranDomTenFilePDF + '_=)()(=_' + ranDomTenFilePDF1;
    }
    if (selectedPB == '0' &&
        selectedPB1 == '0' &&
        selectedPB2 == '0' &&
        selectedPB3 == '0' &&
        selectedPB4 == '0') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            title: Center(
              child: Text(
                'Hãy chọn phòng ban',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    } else {
      if (_formKey.currentState!.validate()) {
        allSelectedPB = selectedPB +
            ' - ' +
            selectedPB1 +
            ' - ' +
            selectedPB2 +
            ' - ' +
            selectedPB3 +
            ' - ' +
            selectedPB4;
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
        if (_isChecked == true) {
          setState(() {
            isLoadingGoogleCalendar = true;
          });
          Response data = await http.get(
            Uri.parse(
                "https://script.google.com/macros/s/AKfycbyIfPgAyrMj-WugsVPacwogu1K-hWDFlhPWjxekdAukbk500yZM-nyslKYSdHd-dFZLCA/exec"),
          );
          if (data.statusCode == 200) {
            dynamic jsonAppData = convert.jsonDecode(data.body);
            //final List<Event> appointmentData = [];
            for (dynamic data in jsonAppData) {
              final ten = data['subject'];
              print(ten);
              timestampBDGoolgeSheet = _convertToTimeStamp(data['starttime']);
              timestampKTGoolgeSheet = _convertToTimeStamp(data['endtime']);

              // so sánh thời gian trong googlecalendar với thời gian của công việc vừa thêm vào
              int ssbatDauvsKt = timestampBDGoolgeSheet.compareTo(timestampKt);
              int ssketThucvsBd = timestampKTGoolgeSheet.compareTo(timestampBd);
              if (ssbatDauvsKt >= 0 || ssketThucvsBd <= 0) {
                print('kiểm tra gg calendar ok');
              } else {
                checkbool = false;
              }
            }
          }
          setState(() {
            isLoadingGoogleCalendar = true;
          });
        }
        try {
          print('validate ok');
          print(timestampBd.toDate().toString());
          print(timestampKt.toDate().toString());
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
          QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
              .collection('cong_viec')
              .where('trang_thai', isEqualTo: true)
              .where('tk_duyet', isEqualTo: true)
              .where('ngay_gio_bat_dau', isEqualTo: timestampBd)
              .get();

          if (_isChecked != true) {
            if (querySnapshot.docs.isEmpty == true &&
                querySnapshot1.docs.isEmpty == true &&
                querySnapshot3.docs.isEmpty == true &&
                checkbool != false) {
              await FirebaseFirestore.instance.collection('cong_viec').add({
                "is_gd_them": true,
                "ngay_gio_bat_dau": timestampBd,
                "ngay_post": Timestamp.fromDate(DateTime.now()),
                "ten_cong_viec": _ten_cong_viecController.text,
                "thoi_gian_cv": _thoi_gian_dien_raController.text,
                "tieu_de": _tieu_deController.text,
                //thu ki duyet
                "tk_duyet": true,
                "trang_thai": true,
                "do_uu_tien": 'Cao',
                "tai_khoan_id": UserID.localUID,
                "phong_ban_id": allSelectedPB,
                // lỗi
                "pb_huy": false,
                "ngay_toi_thieu": Timestamp.fromDate(
                    DateTime.parse(DateTime.now().toString())),
                "ngay_gio_ket_thuc": timestampKt,
                "dia_diem_id": selectedDD,
                "file_pdf": tenFilePDF,
                "is_from_google_calendar": false
              });

              if (mounted) {
                getDataFromFirestoreAndSendPushNT();
                print('thêm vào google sheet');
                if (file != null) {
                  firebase_storage.UploadTask? task =
                      await uploadFile(file!, ranDomTenFilePDF);
                }
                if (file1 != null) {
                  firebase_storage.UploadTask? task =
                      await uploadFile(file1!, ranDomTenFilePDF1);
                }

                if (!kIsWeb) {
                  getName().then((_) => sendMail());
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoard('GD')),
                  (route) => false,
                );
              }
            } else {
              _showmessage('Giờ bắt đầu trùng');
              setState(() {
                isLoading = false;
              });
            }
          } else {
            if (querySnapshot.docs.isEmpty == true &&
                querySnapshot1.docs.isEmpty == true &&
                querySnapshot3.docs.isEmpty == true &&
                checkbool != false) {
              await FirebaseFirestore.instance.collection('cong_viec').add({
                "is_gd_them": true,
                "ngay_gio_bat_dau": timestampBd,
                "ngay_post": Timestamp.fromDate(DateTime.now()),
                "ten_cong_viec": _ten_cong_viecController.text,
                "thoi_gian_cv": _thoi_gian_dien_raController.text,
                "tieu_de": _tieu_deController.text,
                //thu ki duyet
                "tk_duyet": true,
                "trang_thai": true,
                "do_uu_tien": 'Cao',
                "tai_khoan_id": UserID.localUID,
                "phong_ban_id": allSelectedPB,
                // lỗi
                "pb_huy": false,
                "ngay_toi_thieu": Timestamp.fromDate(
                    DateTime.parse(DateTime.now().toString())),
                "ngay_gio_ket_thuc": timestampKt,
                "dia_diem_id": selectedDD,
                "file_pdf": tenFilePDF,
                "is_from_google_calendar": false
              });
              print('thêm vào database');
              if (mounted) {
                getDataFromFirestoreAndSendPushNT();
                print('thêm vào datbase');
                if (file != null) {
                  firebase_storage.UploadTask? task =
                      await uploadFile(file!, ranDomTenFilePDF);
                }
                if (file1 != null) {
                  firebase_storage.UploadTask? task =
                      await uploadFile(file1!, ranDomTenFilePDF1);
                }
                if (!kIsWeb) {
                  getName().then((_) => sendMail());
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoard('GD')),
                  (route) => false,
                );
                //Navigator.pop<bool>(context, true);
                //PhongBanHomePage();
              }
            } else {
              _showmessage(
                  'Giờ bắt đầu trùng với lịch nội bộ hoặc lịch Google Calendar');
              setState(() {
                isLoading = false;
              });
            }
          }
        } catch (e) {
          print(e);
        }
        print(timestampBd.toDate().toString());
        print(_gio_bat_dau_tod.hour.toString() +
            _gio_bat_dau_tod.minute.toString());
        // setState(() {
        //   isLoading = false;
        // });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  getDataFromFirestoreAndSendPushNT() async {
    // List<String> dataList = [];
    // final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    // final ordersCollection = FirebaseFirestore.instance.collection('cong_viec');

    // final orderId = widget.eventID;

    // final orderDoc = await ordersCollection.doc(orderId).get();
    // final userId = orderDoc['tai_khoan_id'];
    // final userDoc = await usersCollection.doc(userId).get();
    //final id_phong_ban = selectedPB;

    if (selectedPB != '0' ||
        selectedPB1 != '0' ||
        selectedPB2 != '0' ||
        selectedPB3 != '0' ||
        selectedPB4 != '0') {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tai_khoan')
          // .where('phong_ban_id', isEqualTo: selectedPB)
          .get();
      snapshot.docs.forEach((doc) {
        if (doc.exists) {
          if (doc['phong_ban_id'].toString() == selectedPB ||
              doc['phong_ban_id'] == selectedPB1 ||
              doc['phong_ban_id'] == selectedPB2 ||
              doc['phong_ban_id'] == selectedPB3 ||
              doc['phong_ban_id'] == selectedPB4) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            if (data != null && data.containsKey('FCMtoken')) {
              String fieldValue = data['FCMtoken'].toString();
              String taiKhoanid = doc.id;
              print(data['ten']);
              print(data['FCMtoken']);
              SendPushMessage(
                  fieldValue,
                  'Bắt đầu lúc: ' + _gio_bat_dauController.text,
                  'Giám đốc đề xuất: ' + _ten_cong_viecController.text,
                  'gd_de_xuat');

              addThongBao(
                  'Giám đốc đề xuất công việc: ' +
                      _ten_cong_viecController.text +
                      '   Bắt đầu lúc: ' +
                      _gio_bat_dauController.text +
                      ' Kết thúc lúc:' +
                      _thoi_gian_ket_thucController.text,
                  'Giám đốc đề xuất công việc',
                  taiKhoanid,
                  todaynow);
              //gửi FCMtoken cho từng fieldvalue
              //listFCMtoken.add(fieldValue);
              //print(fieldValue);
              // xử lý giá trị fieldValue ở đây
            } else {
              // xử lý trường hợp không tìm thấy dữ liệu hoặc không có trường fieldName
              print('Lỗi fcm');
            }
          }
        }
      });
    }

    //return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !isLoading
            ? AppBar(
                title: Text('Yêu cầu công việc',
                    style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.grey[100],
                leading: IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashBoard('GD')),
                        (route) => false,
                      );
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.red,
                    )),
              )
            : AppBar(
                backgroundColor: Colors.grey[100],
              ),
        backgroundColor: Colors.grey[100],
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    !isLoadingGoogleCalendar
                        ? Text(
                            "Đang xử lí!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          )
                        : Text(
                            "Đang kết nối tới Google Calendar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                  ],
                ),
              )
            : ListView(padding: const EdgeInsets.all(16.0), children: [
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
                                child: Container(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _tieu_deController,
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
                                        return "Tiêu đề công việc không được để trống";
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      _tieu_deController.text = value!;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _ten_cong_viecController,
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
                                  SizedBox(
                                    height: 20,
                                  ),

                                  // TextFormField(
                                  //   onTap: () async {
                                  //     final result = await Navigator.push<bool>(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (_) => GDListPhongBan(
                                  //           isRouteGD: true,
                                  //         ),
                                  //       ),
                                  //     );
                                  //     if (result ?? false) {
                                  //       //loadFirestoreEvents();
                                  //     }
                                  //     getName();
                                  //   },
                                  //   readOnly: true,
                                  //   controller: _ten_phong_banController,
                                  //   decoration: InputDecoration(
                                  //     filled: true,
                                  //     labelText: 'Tên phòng ban*',
                                  //     fillColor: Colors.white,
                                  //     hintText: 'Tên phòng ban',
                                  //     enabled: true,
                                  //     contentPadding: const EdgeInsets.only(
                                  //         left: 14.0, bottom: 8.0, top: 8.0),
                                  //     focusedBorder: OutlineInputBorder(
                                  //       borderSide:
                                  //           new BorderSide(color: Colors.white),
                                  //       borderRadius:
                                  //           new BorderRadius.circular(10),
                                  //     ),
                                  //     enabledBorder: UnderlineInputBorder(
                                  //       borderSide:
                                  //           new BorderSide(color: Colors.white),
                                  //       borderRadius:
                                  //           new BorderRadius.circular(10),
                                  //     ),
                                  //   ),
                                  //   validator: (value) {
                                  //     if (value!.length == 0) {
                                  //       return "Tên phòng ban không được để trống";
                                  //     } else {
                                  //       return null;
                                  //     }
                                  //   },
                                  //   onSaved: (value) {
                                  //     _ten_phong_banController.text = value!;
                                  //   },
                                  // ),
                                  Wrap(
                                    children: [
                                      StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('dia_diem')
                                              .where('trang_thai',
                                                  isEqualTo: true)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            List<DropdownMenuItem> tenPBItems =
                                                [];
                                            if (!snapshot.hasData) {
                                              const CircularProgressIndicator();
                                            } else {
                                              final dsTenPB = snapshot
                                                  .data?.docs.reversed
                                                  .toList();
                                              tenPBItems.add(DropdownMenuItem(
                                                  value: '0',
                                                  child:
                                                      Text('Chọn địa điểm')));
                                              for (var tenPhongBan
                                                  in dsTenPB!) {
                                                // tenDiaDiem = tenPhongBan['ten_dia_diem'];
                                                tenPBItems.add(
                                                  DropdownMenuItem(
                                                    value: tenPhongBan.id,
                                                    child: Text(
                                                      tenPhongBan[
                                                          'ten_dia_diem'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                            return DropdownButton(
                                              items: tenPBItems,
                                              onChanged: (tenPBNewValue) {
                                                print(tenPBNewValue);
                                                setState(() {
                                                  selectedDD = tenPBNewValue;
                                                });
                                              },
                                              value: selectedDD,
                                              isExpanded: true,
                                            );
                                          }),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          'Danh sách phòng ban',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Wrap(
                                    children: [
                                      StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('phong_ban')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            List<DropdownMenuItem> tenPBItems =
                                                [];
                                            if (!snapshot.hasData) {
                                              const CircularProgressIndicator();
                                            } else {
                                              final dsTenPB = snapshot
                                                  .data?.docs.reversed
                                                  .toList();
                                              tenPBItems.add(DropdownMenuItem(
                                                  value: '0',
                                                  child:
                                                      Text('Chọn phòng ban')));
                                              for (var tenPhongBan
                                                  in dsTenPB!) {
                                                tenPBItems.add(
                                                  DropdownMenuItem(
                                                    value: tenPhongBan.id,
                                                    child: Text(
                                                      tenPhongBan[
                                                          'ten_phong_ban'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                            return DropdownButton(
                                              items: tenPBItems,
                                              onChanged: (tenPBNewValue) {
                                                print(tenPBNewValue);
                                                setState(() {
                                                  selectedPB = tenPBNewValue;
                                                });
                                              },
                                              value: selectedPB,
                                              isExpanded: true,
                                            );
                                          }),
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      Visibility(
                                        visible: isVisibleselectedPB1,
                                        child: Wrap(
                                          children: [
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('phong_ban')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  List<DropdownMenuItem>
                                                      tenPBItems = [];
                                                  if (!snapshot.hasData) {
                                                    const CircularProgressIndicator();
                                                  } else {
                                                    final dsTenPB = snapshot
                                                        .data?.docs.reversed
                                                        .toList();
                                                    tenPBItems.add(DropdownMenuItem(
                                                        value: '0',
                                                        child: Text(
                                                            'Chọn phòng ban')));
                                                    for (var tenPhongBan
                                                        in dsTenPB!) {
                                                      tenPBItems.add(
                                                        DropdownMenuItem(
                                                          value: tenPhongBan.id,
                                                          child: Text(
                                                            tenPhongBan[
                                                                'ten_phong_ban'],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  return DropdownButton(
                                                    items: tenPBItems,
                                                    onChanged: (tenPBNewValue) {
                                                      print(tenPBNewValue);
                                                      setState(() {
                                                        selectedPB1 =
                                                            tenPBNewValue;
                                                      });
                                                    },
                                                    value: selectedPB1,
                                                    isExpanded: true,
                                                  );
                                                }),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      Visibility(
                                        visible: isVisibleselectedPB2,
                                        child: Wrap(
                                          children: [
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('phong_ban')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  List<DropdownMenuItem>
                                                      tenPBItems = [];
                                                  if (!snapshot.hasData) {
                                                    const CircularProgressIndicator();
                                                  } else {
                                                    final dsTenPB = snapshot
                                                        .data?.docs.reversed
                                                        .toList();
                                                    tenPBItems.add(DropdownMenuItem(
                                                        value: '0',
                                                        child: Text(
                                                            'Chọn phòng ban')));
                                                    for (var tenPhongBan
                                                        in dsTenPB!) {
                                                      tenPBItems.add(
                                                        DropdownMenuItem(
                                                          value: tenPhongBan.id,
                                                          child: Text(
                                                            tenPhongBan[
                                                                'ten_phong_ban'],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  return DropdownButton(
                                                    items: tenPBItems,
                                                    onChanged: (tenPBNewValue) {
                                                      print(tenPBNewValue);
                                                      setState(() {
                                                        selectedPB2 =
                                                            tenPBNewValue;
                                                      });
                                                    },
                                                    value: selectedPB2,
                                                    isExpanded: true,
                                                  );
                                                }),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      Visibility(
                                        visible: isVisibleselectedPB3,
                                        child: Wrap(
                                          children: [
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('phong_ban')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  List<DropdownMenuItem>
                                                      tenPBItems = [];
                                                  if (!snapshot.hasData) {
                                                    const CircularProgressIndicator();
                                                  } else {
                                                    final dsTenPB = snapshot
                                                        .data?.docs.reversed
                                                        .toList();
                                                    tenPBItems.add(DropdownMenuItem(
                                                        value: '0',
                                                        child: Text(
                                                            'Chọn phòng ban')));
                                                    for (var tenPhongBan
                                                        in dsTenPB!) {
                                                      tenPBItems.add(
                                                        DropdownMenuItem(
                                                          value: tenPhongBan.id,
                                                          child: Text(
                                                            tenPhongBan[
                                                                'ten_phong_ban'],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  return DropdownButton(
                                                    items: tenPBItems,
                                                    onChanged: (tenPBNewValue) {
                                                      print(tenPBNewValue);
                                                      setState(() {
                                                        selectedPB3 =
                                                            tenPBNewValue;
                                                      });
                                                    },
                                                    value: selectedPB3,
                                                    isExpanded: true,
                                                  );
                                                }),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      Visibility(
                                        visible: isVisibleselectedPB4,
                                        child: Wrap(
                                          children: [
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('phong_ban')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  List<DropdownMenuItem>
                                                      tenPBItems = [];
                                                  if (!snapshot.hasData) {
                                                    const CircularProgressIndicator();
                                                  } else {
                                                    final dsTenPB = snapshot
                                                        .data?.docs.reversed
                                                        .toList();
                                                    tenPBItems.add(DropdownMenuItem(
                                                        value: '0',
                                                        child: Text(
                                                            'Chọn phòng ban')));
                                                    for (var tenPhongBan
                                                        in dsTenPB!) {
                                                      tenPBItems.add(
                                                        DropdownMenuItem(
                                                          value: tenPhongBan.id,
                                                          child: Text(
                                                            tenPhongBan[
                                                                'ten_phong_ban'],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  return DropdownButton(
                                                    items: tenPBItems,
                                                    onChanged: (tenPBNewValue) {
                                                      print(tenPBNewValue);
                                                      setState(() {
                                                        selectedPB4 =
                                                            tenPBNewValue;
                                                      });
                                                    },
                                                    value: selectedPB4,
                                                    isExpanded: true,
                                                  );
                                                }),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        elevation: 5.0,
                                        height: 40,
                                        onPressed: () {
                                          count = count + 1;
                                          if (count == 1) {
                                            setState(() {
                                              isVisibleselectedPB1 = true;
                                            });
                                          } else if (count == 2) {
                                            setState(() {
                                              isVisibleselectedPB2 = true;
                                            });
                                          } else if (count == 3) {
                                            setState(() {
                                              isVisibleselectedPB3 = true;
                                            });
                                          } else if (count == 4) {
                                            setState(() {
                                              isVisibleselectedPB4 = true;
                                            });
                                          } else {
                                            print(count);
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 255, 0, 0),
                                                  title: Center(
                                                    child: Text(
                                                      "Tối đa 5 phòng ban",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Text(
                                          "Thêm phòng ban",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                        color: Colors.blue[900],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _thoi_gian_dien_raController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      labelText: 'Thời gian dự kiến(phút)',
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
                                    onChanged: (newValueSelected) {
                                      if (newValueSelected.length != 0) {
                                        setState(() {
                                          tinhThoiGianKetThuc(
                                              int.parse(newValueSelected));
                                          _thoi_gian_ket_thucController.text =
                                              _gio.toString() +
                                                  ' giờ ' +
                                                  _phut.toString() +
                                                  ' phút';
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value!.length == 0) {
                                        return "Thời gian dự kiến không được để trống";
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      _thoi_gian_dien_raController.text =
                                          value!;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    readOnly: true,
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
                                        if (_thoi_gian_dien_raController
                                                .text.length ==
                                            0) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Color.fromARGB(
                                                    255, 255, 0, 0),
                                                title: Center(
                                                  child: Text(
                                                    'Hãy nhập thời gian dự kiến(phút)',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          tinhThoiGianKetThuc(int.parse(
                                              _thoi_gian_dien_raController
                                                  .text));
                                          _thoi_gian_ket_thucController.text =
                                              _gio.toString() +
                                                  ' giờ ' +
                                                  _phut.toString() +
                                                  ' phút';
                                        }
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
                                        return "Thời gian bắt đầu không hợp lệ";
                                      }
                                    },
                                    style: TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                      labelText: 'Thời gian bắt đầu*',
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
                                    height: 20,
                                  ),

                                  TextFormField(
                                    readOnly: true,
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
                                        return "Hãy chọn thời gian bắt đầu";
                                      }
                                      if (_gio == 11 && _phut == 0 ||
                                          _gio == 17 && _phut == 0) {
                                        return null;
                                      }
                                      if (_gio >= 7 && _gio < 11 ||
                                          _gio >= 13 && _gio < 17) {
                                        return null;
                                      } else {
                                        return "Thời gian kết thúc không hợp lệ";
                                      }
                                    },
                                    onSaved: (value) {
                                      _thoi_gian_ket_thucController.text =
                                          value!;
                                    },
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Ngày dự kiến bắt đầu',
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
                                    controller: _ngay_toi_thieuController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Tên công việc không được để trống!";
                                      }
                                      if (value.length > 24) {
                                        return ("Ngày không hợp lệ!");
                                      }
                                      //thời gian bắt đầu bé hơn datetime.now thì lỗi
                                      if (DateTime.parse(value)
                                          .isBefore(today)) {
                                        return ("Không được chọn ngày trong quá khứ!");
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      _ngay_toi_thieuController.text = value!;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Wrap(
                                    children: [
                                      kIsWeb
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      'Không thể chọn file trên trang web'),
                                                  flex: 8,
                                                )
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  flex: 8,
                                                  child: MaterialButton(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                    elevation: 5.0,
                                                    height: 40,
                                                    onPressed: () async {
                                                      final path =
                                                          await FlutterDocumentPicker
                                                              .openDocument();
                                                      if (path == null) {
                                                        print('path null');
                                                      } else if ((path
                                                              .split('.')
                                                              .last) !=
                                                          'pdf') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          255,
                                                                          0,
                                                                          0),
                                                              title: Center(
                                                                child: Text(
                                                                  "Hãy chọn file pdf",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        print(path);
                                                        file = File(path);
                                                        fileName = file!.path
                                                            .split('/')
                                                            .last;
                                                        setState(() {
                                                          isfileNameExsited =
                                                              true;
                                                          print('file name:' +
                                                              fileName);
                                                          ranDomTenFilePDF =
                                                              getRandString(
                                                                  fileName
                                                                      .length,
                                                                  UserID
                                                                      .localUID,
                                                                  fileName);
                                                          print('random name:' +
                                                              ranDomTenFilePDF);
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      isfileNameExsited
                                                          ? fileName
                                                          : 'Chọn file pdf',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: MaterialButton(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                    elevation: 5.0,
                                                    height: 40,
                                                    child:
                                                        Icon(Icons.close_sharp),
                                                    onPressed: () async {
                                                      //clear fileName setState
                                                      setState(() {
                                                        file = File('');
                                                        fileName = '';
                                                        isfileNameExsited =
                                                            false;
                                                        ranDomTenFilePDF = '';
                                                        print(fileName);
                                                        print(getRandString(
                                                            fileName.length,
                                                            fileName,
                                                            UserID.localUID));
                                                        print(isfileNameExsited
                                                            .toString());
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              elevation: 5.0,
                                              height: 40,
                                              onPressed: () async {
                                                final path1 =
                                                    await FlutterDocumentPicker
                                                        .openDocument();
                                                if (path1 == null) {
                                                  print('path null');
                                                } else if ((path1
                                                        .split('.')
                                                        .last) !=
                                                    'pdf') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Color.fromARGB(
                                                                255, 255, 0, 0),
                                                        title: Center(
                                                          child: Text(
                                                            "Hãy chọn file pdf",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  print(path1);
                                                  file1 = File(path1);
                                                  fileName1 = file1!.path
                                                      .split('/')
                                                      .last;
                                                  setState(() {
                                                    isfileNameExsited1 = true;
                                                    print('file name:' +
                                                        fileName1);
                                                    ranDomTenFilePDF1 =
                                                        getRandString(
                                                            fileName1.length,
                                                            UserID.localUID,
                                                            fileName1);
                                                    print('random name:' +
                                                        ranDomTenFilePDF1);
                                                  });
                                                }
                                              },
                                              child: Text(
                                                isfileNameExsited1
                                                    ? fileName1
                                                    : 'Chọn file pdf',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              elevation: 5.0,
                                              height: 40,
                                              child: Icon(Icons.close_sharp),
                                              onPressed: () async {
                                                //clear fileName setState
                                                setState(() {
                                                  file1 = File('');
                                                  fileName1 = '';
                                                  isfileNameExsited1 = false;
                                                  ranDomTenFilePDF1 = '';
                                                  print(fileName1);
                                                  print(getRandString(
                                                      fileName1.length,
                                                      fileName1,
                                                      UserID.localUID));
                                                  print(isfileNameExsited1
                                                      .toString());
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     Text(
                                  //       "Độ ưu tiên : ",
                                  //       style: TextStyle(
                                  //         fontSize: 20,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Colors.black,
                                  //       ),
                                  //     ),
                                  //     DropdownButton<String>(
                                  //       dropdownColor: Colors.grey[300],
                                  //       isDense: true,
                                  //       isExpanded: false,
                                  //       iconEnabledColor: Colors.grey,
                                  //       // focusColor: Colors.grey,
                                  //       items: options
                                  //           .map((String dropDownStringItem) {
                                  //         return DropdownMenuItem<String>(
                                  //           value: dropDownStringItem,
                                  //           child: Text(
                                  //             dropDownStringItem,
                                  //             style: TextStyle(
                                  //               color: Colors.black,
                                  //               fontWeight: FontWeight.bold,
                                  //               fontSize: 20,
                                  //             ),
                                  //           ),
                                  //         );
                                  //       }).toList(),
                                  //       onChanged: (newValueSelected) {
                                  //         setState(() {
                                  //           _currentItemSelected =
                                  //               newValueSelected!;
                                  //           rool = newValueSelected;
                                  //         });
                                  //       },
                                  //       value: _currentItemSelected,
                                  //     ),
                                  //   ],
                                  // ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isChecked = value ?? false;
                                            print(_isChecked.toString());
                                          });
                                        },
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                        tristate: false,
                                      ),
                                      Text(
                                          'Kiểm tra với lịch Google Calendar?'),
                                    ],
                                  ),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    elevation: 5.0,
                                    height: 40,
                                    onPressed: () {
                                      _duyetEvent();
                                      // print(selectedPB +
                                      //     ' - ' +
                                      //     selectedPB1 +
                                      //     ' - ' +
                                      //     selectedPB2 +
                                      //     ' - ' +
                                      //     selectedPB3 +
                                      //     ' - ' +
                                      //     selectedPB4);
                                      //getName();
                                      // getDataFromFirestoreAndSendPushNT();
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
                          ],
                        ),
                      ),
                    )))
              ]));
  }
}
