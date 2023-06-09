import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/services/upload_filepdf.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as path1;
import '../../dashboard.dart';
import '../../data/UserID.dart';
import 'dart:math';
import 'dart:convert';
import '../../services/send_push_massage.dart';
import 'list_cong_viec.dart';

class AddEvent extends StatefulWidget {
  // final DateTime firstDate;
  // final DateTime lastDate;
  //final DateTime? selectedDate;
  const AddEvent({
    Key? key,
    // required this.firstDate,
    // required this.lastDate,
    // this.selectedDate
  }) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  //
  final _ngay_de_xuat = TextEditingController();
  // late String _ngay_de_xuat_formatted;
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
        _ngay_de_xuat.text = pickedDate.toString();
      });
    });
  }

  //
  var options = ['Cao', 'Vừa', 'Thấp'];
  var rool = "Vừa";
  var _currentItemSelected = "Vừa";
  late DateTime _selectedDate;
  final _formkey = GlobalKey<FormState>();
  final _ten_cong_viecController = TextEditingController();
  final _thoi_gian_cvController = TextEditingController();
  final _tieu_deController = TextEditingController();
  final _dia_diemController = TextEditingController();
  //late  DateTime now = DateTime.now();
  //tải lên file pdf
  String fileName = '';
  String fileName1 = '';
  bool isfileNameExsited = false;
  bool isfileNameExsited1 = false;
  File? file = null;
  File? file1 = null;
  // Định dạng năm-tháng-ngày
  var todaynow = DateTime.now().toString();

  final thoi_gian_cong_viec_max = 240; //phut
  var _email_PB = '';
  var _app_Password = '';
  var _ten_PB = '';
  var _email_TK = '';
  var tenFilePDF = '';
  var ranDomTenFilePDF = '';
  var ranDomTenFilePDF1 = '';
  var _FCMtoken = '';
  var _diaDiem = '';
  var _phong_ban_ID = '';
  var tenDiaDiem = '';
  var idThuky = '';
  //var chuoi = '';
  bool isTaiKhoanBiKhoa = true;
  List<DropdownMenuItem<String>> _categoriesList = [];
  String selectedPB = '0';
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getName();
    getFCMToken();
    // print(_email_PB);
    // print(_app_Password);
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    // print(_formattedNgaydx);
    //_selectedDate = widget.selectedDate ?? DateTime.now();
  }

  getDiaDiem() async {
    if (selectedPB != '0') {
      final diaDiemCollection =
          FirebaseFirestore.instance.collection('dia_diem');
      final diaDiemDoc = await diaDiemCollection.doc(selectedPB).get();
      _diaDiem = diaDiemDoc['ten_dia_diem'];
    }
  }

  getFCMToken() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: 'TK')
        .limit(1)
        .get();
    _FCMtoken = querySnapshot.docs.first['FCMtoken'];
    print(_FCMtoken);
  }

  void resetTextField() {
    setState(() {
      fileName = '';
      fileName1 = '';
      isfileNameExsited = false;
      isfileNameExsited1 = false;
      file = null;
      file1 = null;
      getName();
      _ten_cong_viecController.clear();
      _thoi_gian_cvController.clear();
      _tieu_deController.clear();
      _dia_diemController.clear();
      fileName = '';
      isfileNameExsited = false;
      file = null;
      _email_PB = '';
      _app_Password = '';
      _ten_PB = '';
      _email_TK = '';
      tenFilePDF = '';
      ranDomTenFilePDF = '';
      ranDomTenFilePDF1 = '';
    });
  }

  void _addEvent() async {
    final DateTime now;
    final tenCongViec = _ten_cong_viecController.text;
    final thoiGiancv = _thoi_gian_cvController.text;
    final tieuDe = _tieu_deController.text;
    final diadiem = _dia_diemController.text;
    // if (fileName == '') {
    //   tenFilePDF = '';
    // } else {
    //   tenFilePDF = ranDomTenFilePDF;
    // }
    if (fileName == '' && fileName1 == '') {
      tenFilePDF = '';
    } else if (fileName != '' && fileName1 == '') {
      tenFilePDF = ranDomTenFilePDF;
    } else if (fileName == '' && fileName1 != '') {
      tenFilePDF = ranDomTenFilePDF1;
    } else {
      tenFilePDF = ranDomTenFilePDF + '_=)()(=_' + ranDomTenFilePDF1;
    }
    if (_formkey.currentState!.validate()) {
      try {
        if (selectedPB == '0') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Color.fromARGB(255, 255, 0, 0),
                title: Center(
                  child: Text(
                    'Hãy địa điểm',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        } else if (isTaiKhoanBiKhoa == false) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                title: Center(
                  child: Text(
                    'Tài khoản bị khoá !',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        } else {
          await FirebaseFirestore.instance.collection('cong_viec').add({
            "is_gd_them": false,
            "ngay_gio_bat_dau": Timestamp.fromDate(DateTime.now()),
            "ngay_post": Timestamp.fromDate(DateTime.now()),
            "ten_cong_viec": tenCongViec,
            "thoi_gian_cv": thoiGiancv,
            "tieu_de": tieuDe,
            //thu ki duyet
            "tk_duyet": false,
            "trang_thai": true,
            "do_uu_tien": rool,
            "tai_khoan_id": UserID.localUID,
            // lỗi
            "pb_huy": false,
            "ngay_toi_thieu":
                Timestamp.fromDate(DateTime.parse(_ngay_de_xuat.text)),
            "ngay_gio_ket_thuc": Timestamp.fromDate(DateTime.now()),
            "dia_diem_id": selectedPB,
            "file_pdf": tenFilePDF,
            "phong_ban_id": _phong_ban_ID,
            "is_from_google_calendar": false
          });
          if (mounted) {
            if (file != null) {
              firebase_storage.UploadTask? task =
                  await uploadFile(file!, ranDomTenFilePDF);
            }
            if (file1 != null) {
              firebase_storage.UploadTask? task =
                  await uploadFile(file1!, ranDomTenFilePDF1);
            }
            if (!kIsWeb) {
              sendMail();
            }

            SendPushMessage(_FCMtoken, _tieu_deController.text,
                _ten_PB + ' đã thêm cuộc hợp mới', 'pb_add_event');
            addThongBao(
                _ten_PB +
                    ' đã thêm cuộc hợp mới' +
                    ' Công việc: ' +
                    _tieu_deController.text,
                _ten_PB + ' đã thêm cuộc hợp mới',
                idThuky,
                todaynow);
            //reset giá trị
            resetTextField();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.green,
                  title: Center(
                    child: Text(
                      'Thêm công việc thành công',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
            //Nhảy qua list
            final res = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ListCongViec(isRoteGD: false),
              ),
            );
            //PhongBanHomePage();
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  getName() async {
    // var _email = '';
    // var _app_PW = '';
    // var _ten = '';
    // final FirebaseAuth auth = FirebaseAuth.instance;
    // final User? user = auth.currentUser;
    // final uid = user?.uid;
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    final _email = userDoc['email'];
    final _app_PW = userDoc['app_password'];

    final _id_phong_ban = userDoc['phong_ban_id'];

    final phongBanCollection =
        FirebaseFirestore.instance.collection('phong_ban');
    final phongBanDoc = await phongBanCollection.doc(_id_phong_ban).get();
    final _ten = phongBanDoc['ten_phong_ban'];
    //final _ten = userDoc['ten'];

    final _phong_ban_id = userDoc['phong_ban_id'];
    if (userDoc['trang_thai'] == false) {
      isTaiKhoanBiKhoa = false;
    }
    _app_Password = _app_PW;
    _email_PB = _email;
    _ten_PB = _ten;
    _phong_ban_ID = _phong_ban_id;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: 'TK')
        .limit(1)
        .get();
    _email_TK = querySnapshot.docs.first['email'];
    idThuky = querySnapshot.docs.first.id;
    print(_email_TK);

    //     final diaDiemCollection =
    //     FirebaseFirestore.instance.collection('dia_diem');
    // final diadiemDoc =
    //     await phongBanCollection.doc(eventDoc['dia_diem_id']).get();
    // final _dia_Diem = phongBanDoc['ten_dia_diem'];
    //setState(() {});
    //print(tenPB);
  }

  void sendMail() async {
    getDiaDiem();
    var userEmail = _email_PB;
    final smtpServer = gmail(_email_PB.toString(), _app_Password);
    final message = Message()
      ..from = Address(_email_PB.toString(), _ten_PB)
      ..recipients.add(_email_TK.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Phòng ban ' + _ten_PB + ' thêm công việc mới'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_cvController.text} phút</h2>\n<h2>-Địa điểm: ${tenDiaDiem}</h2>\n<h2>-Ngày đề xuất : ${_ngay_de_xuat.text}</h2>\n<h2>-Độ ưu tiên : ${rool}</h2>";

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

  String getRandString(int len, String uid, String tenFile) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    var base64UrlEncodeString = base64UrlEncode(values);
    return uid + '/' + tenFile + '_)()(_' + base64UrlEncodeString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        title:
            Text('Thêm công việc mới', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.all(4),
            color: Colors.grey[100],
            padding: EdgeInsets.all(4),
            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Form(
                key: _formkey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _tieu_deController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tiêu đề',
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
                        validator: (value) {
                          if (value!.length == 0) {
                            return "Tiêu đề không được để trống";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _tieu_deController.text = value!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _ten_cong_viecController,
                        decoration: InputDecoration(
                          labelText: 'Tên công việc',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tên công việc',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 15.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Tên công việc không được để trống!";
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
                      TextFormField(
                        controller: _thoi_gian_cvController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Thời gian dự kiến(phút)',
                          hintText: 'Thời gian dự kiến(phút)',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 15.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          RegExp regex = RegExp(r'^[0-9]+$');

                          if (value!.isEmpty) {
                            return "Thời gian dự kiến không được để trống!";
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Bạn phải nhập số!");
                          }
                          if (int.parse(value) > thoi_gian_cong_viec_max) {
                            return ("Công việc không vượt quá 4 tiếng!");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _thoi_gian_cvController.text = value!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('dia_diem')
                                  .where('trang_thai', isEqualTo: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<DropdownMenuItem> tenPBItems = [];
                                if (!snapshot.hasData) {
                                  const CircularProgressIndicator();
                                } else {
                                  final dsTenPB =
                                      snapshot.data?.docs.reversed.toList();
                                  tenPBItems.add(DropdownMenuItem(
                                      value: '0',
                                      child: Text('Chọn địa điểm')));
                                  for (var tenPhongBan in dsTenPB!) {
                                    tenDiaDiem = tenPhongBan['ten_dia_diem'];
                                    tenPBItems.add(
                                      DropdownMenuItem(
                                        value: tenPhongBan.id,
                                        child: Text(
                                          tenPhongBan['ten_dia_diem'],
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
                      SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        children: [
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Ngày đề xuất',
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ngày đề xuất',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white),
                                borderRadius: new BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white),
                                borderRadius: new BorderRadius.circular(10),
                              ),
                            ),
                            onTap: _selectDatePicker,
                            controller: _ngay_de_xuat,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Tên công việc không được để trống!";
                              }
                              if (value.length > 23) {
                                return ("Ngày không hợp lệ!");
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _ngay_de_xuat.text = value!;
                            },
                          ),
                        ],
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        elevation: 5.0,
                                        height: 40,
                                        onPressed: () async {
                                          final path =
                                              await FlutterDocumentPicker
                                                  .openDocument();
                                          if (path == null) {
                                            print('path null');
                                          } else if ((path.split('.').last) !=
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
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            print(path);
                                            file = File(path);
                                            fileName =
                                                file!.path.split('/').last;
                                            setState(() {
                                              isfileNameExsited = true;
                                              print('file name:' + fileName);
                                              ranDomTenFilePDF = getRandString(
                                                  fileName.length,
                                                  UserID.localUID,
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        elevation: 5.0,
                                        height: 40,
                                        child: Icon(Icons.close_sharp),
                                        onPressed: () async {
                                          //clear fileName setState
                                          setState(() {
                                            file = File('');
                                            fileName = '';
                                            isfileNameExsited = false;
                                            ranDomTenFilePDF = '';
                                            print(fileName);
                                            print(getRandString(fileName.length,
                                                fileName, UserID.localUID));
                                            print(isfileNameExsited.toString());
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () async {
                                    final path1 = await FlutterDocumentPicker
                                        .openDocument();
                                    if (path1 == null) {
                                      print('path null');
                                    } else if ((path1.split('.').last) !=
                                        'pdf') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                Color.fromARGB(255, 255, 0, 0),
                                            title: Center(
                                              child: Text(
                                                "Hãy chọn file pdf",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      print(path1);
                                      file1 = File(path1);
                                      fileName1 = file1!.path.split('/').last;
                                      setState(() {
                                        isfileNameExsited1 = true;
                                        print('file name:' + fileName1);
                                        ranDomTenFilePDF1 = getRandString(
                                            fileName1.length,
                                            UserID.localUID,
                                            fileName1);
                                        print(
                                            'random name:' + ranDomTenFilePDF1);
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
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
                                      print(getRandString(fileName1.length,
                                          fileName1, UserID.localUID));
                                      print(isfileNameExsited1.toString());
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Độ ưu tiên : ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButton<String>(
                            dropdownColor: Colors.grey[300],
                            isDense: true,
                            isExpanded: false,
                            iconEnabledColor: Colors.grey,
                            // focusColor: Colors.grey,
                            items: options.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(
                                  dropDownStringItem,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValueSelected) {
                              setState(() {
                                _currentItemSelected = newValueSelected!;
                                rool = newValueSelected;
                              });
                            },
                            value: _currentItemSelected,
                          ),
                        ],
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        elevation: 5.0,
                        height: 40,
                        onPressed: () {
                          //getName();
                          // if (ranDomTenFilePDF == '') {
                          //   chuoi = ranDomTenFilePDF1;
                          // } else if (ranDomTenFilePDF1 == '') {
                          //   chuoi = ranDomTenFilePDF;
                          // } else {
                          //   chuoi = ranDomTenFilePDF +
                          //       '_=)()(=_' +
                          //       ranDomTenFilePDF1;
                          // }
                          _addEvent();
                          //  print(chuoi);
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
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
