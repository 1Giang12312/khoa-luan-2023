import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/pages/phongban/PB_home_page.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as path1;
import '../../data/UserID.dart';
import '../../services/send_push_massage.dart';
import 'item_details.dart';

class EditItem extends StatefulWidget {
  String itemId;
  EditItem({Key? key, required this.itemId}) : super(key: key);

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  late bool isLoading = false;
  var options = ['Cao', 'Vừa', 'Thấp'];
  var rool = "Vừa";
  var _currentItemSelected = "Vừa";
  late DateTime _selectedDate;
  final _formkey = GlobalKey<FormState>();
  final _ten_cong_viecController = TextEditingController();
  final _thoi_gian_cvController = TextEditingController();
  final _tieu_deController = TextEditingController();
  final thoi_gian_cong_viec_max = 240;
  final _dia_diemController = TextEditingController();
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;
  late Map data;
  var filePDF_ban_dau = '';
  var filePDF_so_sanh = '';
  var _email_PB = '';
  var _app_Password = '';
  var _ten_PB = '';
  var _email_TK = '';

  var _tieu_de = '';
  var _ten_cong_viec = '';
  var _ngay_toi_thieu = '';
  var _thoi_gianCV = '';
  var _dia_diem = '';
  var _do_uu_tien = '';

  var tenFilePDF = '';
  var ranDomTenFilePDF = '';
  var ranDomTenFilePDF1 = '';
  String fileName = '';
  String fileName1 = '';
  bool isfileNameExsited = false;
  bool isfileNameExsited1 = false;
  File? file = null;
  File? file1 = null;
  String fileNameDefault = 'Chọn file pdf';
  String refileNamDefault = '';
  String fileNameDefault1 = 'Chọn file pdf';
  String refileNamDefault1 = '';
  // bool isFileChange = false;
  // bool isFileChange1 = false;
  var todaynow = DateTime.now().toString();
  String filePDFPath = '';
  String filePDFPath1 = '';
  bool isEmptyFileName = true;
  var _FCMtoken = '';
  var idThuKi = '';
  bool is2file = false;
  String selectedDD = '0';
  var idThuky = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getFCMToken();
    final _reference =
        FirebaseFirestore.instance.collection('cong_viec').doc(widget.itemId);
    _futureData = _reference.get();
    getName();
    getDiaDiem();
    _loadData();
    setState(() {
      isLoading = false;
    });
  }

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
        _ngay_de_xuat.text = pickedDate.toString();
      });
    });
  }

  getDiaDiem() async {
    final diaDiemCollection =
        FirebaseFirestore.instance.collection('cong_viec');
    final diaDiemDoc = await diaDiemCollection.doc(widget.itemId).get();
    selectedDD = diaDiemDoc['dia_diem_id'];
  }

  String getRandString(int len, String uid, String tenFile) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    var base64UrlEncodeString = base64UrlEncode(values);
    return uid + '/' + tenFile + '_)()(_' + base64UrlEncodeString;
  }

  Future<void> xoaFilePDF(String tenFilePDFXoa) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference reference =
        storage.ref().child('pdf_files').child('/${tenFilePDFXoa}');
    await reference.delete();
  }

  getFCMToken() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Thư ký')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idThuKi = docId!;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idThuKi)
        .limit(1)
        .get();
    _FCMtoken = querySnapshot.docs.first['FCMtoken'];
    print(_FCMtoken);
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

  void _editItem() async {
    setState(() {
      isLoading = true;
    });
    final DateTime now;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final tenCongViec = _ten_cong_viecController.text;
    final thoiGiancv = _thoi_gian_cvController.text;
    final tieuDe = _tieu_deController.text;
    final diaDiem = _dia_diemController.text;

    // tenFilePDF = filePDFPath + filePDFPath1;
    if (filePDFPath == '') {
      tenFilePDF = filePDFPath1;
    } else if (filePDFPath1 == '') {
      tenFilePDF = filePDFPath;
    } else if (filePDFPath != '' && filePDFPath1 != '') {
      tenFilePDF = filePDFPath + '_=)()(=_' + filePDFPath1;
    }
    // if (fileName == '' && fileName1 == '') {
    //   tenFilePDF = '';
    // } else if (fileName != '' && fileName1 == '') {
    //   tenFilePDF = ranDomTenFilePDF;
    // } else if (fileName == '' && fileName1 != '') {
    //   tenFilePDF = ranDomTenFilePDF1;
    // } else {
    //   tenFilePDF = ranDomTenFilePDF + '_=)()(=_' + ranDomTenFilePDF1;
    // }
//     if (fileName == '') {
//       tenFilePDF = '';
//       if (filePDF_ban_dau != filePDF_so_sanh) {
//         xoaFilePDF(filePDF_ban_dau);
//       }
//       if (isEmptyFileName == false) {
//         tenFilePDF = filePDF_ban_dau;
//       }
//       if (isEmptyFileName == true &&
//           isfileNameExsited == false &&
//           filePDF_ban_dau != '') {
//         xoaFilePDF(filePDF_ban_dau);
//       }
//       //thực hiện xoá file
//     } else {
//       tenFilePDF = ranDomTenFilePDF;
// //nếu file mới khác tên file cũ xoá file cũ
// //xoá file ban cũ
//       if (filePDF_ban_dau != filePDF_so_sanh && filePDF_ban_dau != '') {
//         //xoá file ban dau
//         xoaFilePDF(filePDF_ban_dau);
//       }
//     }
    if (selectedDD == '0') {
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
    }
    if (_formkey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            // .collection('tai_khoan')
            // .doc(uid)
            .collection('cong_viec')
            .doc(widget.itemId)
            .update({
          "ten_cong_viec": tenCongViec,
          "thoi_gian_cv": thoiGiancv,
          "tieu_de": tieuDe,
          "ngay_toi_thieu":
              Timestamp.fromDate(DateTime.parse(_ngay_de_xuat.text)),
          "do_uu_tien": rool,
          "dia_diem_id": selectedDD,
          "file_pdf": tenFilePDF
        });

        if (mounted) {
          //nếu file pdf bị xóa => xóa file pdf trên storage + update file_pdf = ''
          //nếu file pdf bị sửa mới =? upload file mới + update file_pdf + xóa file cũ
          //nếu bình thường lưu lại đường dẫn cũ
          if (fileName != '') {
            firebase_storage.UploadTask? task =
                await uploadFile(file!, filePDFPath);
          }
          if (fileName1 != '') {
            firebase_storage.UploadTask? task =
                await uploadFile(file1!, filePDFPath1);
          }
          if (!kIsWeb) {
            sendMail();
          }

          SendPushMessage(_FCMtoken, _tieu_deController.text,
              _ten_PB + ' đã chỉnh sửa cuộc họp', 'pb_edit_event');
          addThongBao(
              _ten_PB +
                  ' đã chỉnh sửa cuộc họp' +
                  ' Cuộc họp: ' +
                  _tieu_deController.text,
              _ten_PB + ' đã chỉnh sửa cuộc họp',
              idThuKi,
              todaynow);
          Navigator.of(context).popUntil((route) => route.isFirst);
          final result = Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetails(widget.itemId),
            ),
          );
          print('sua thanh cong');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Sửa công việc thành công'),
            action: SnackBarAction(
              label: 'Hủy',
              onPressed: () {},
            ),
          ));
        }
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  getName() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(uid).get();

    final _email = userDoc['email'];
    final _app_PW = userDoc['app_password'];

    final _phong_ban_id = userDoc['phong_ban_id'];
    final phongBanCollection1 =
        FirebaseFirestore.instance.collection('phong_ban');
    final phongBanDoc1 = await phongBanCollection1.doc(_phong_ban_id).get();
    final _ten = phongBanDoc1['ten_phong_ban'];

    _app_Password = _app_PW;
    _email_PB = _email;
    _ten_PB = _ten;

    //công việc cũ - công việc mới

    //công việc cũ

    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Thư ký')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idThuKi = docId!;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han_id', isEqualTo: idThuKi)
        .limit(1)
        .get();

    _email_TK = querySnapshot.docs.first['email'];
    setState(() {});
    //print(tenPB);
  }

  void _loadData() async {
    final document = await FirebaseFirestore.instance
        .collection('cong_viec')
        .doc(widget.itemId)
        .get();
    if (document.exists) {
      final data = document.data();
      _ten_cong_viecController.text = data!['ten_cong_viec'];
      _tieu_deController.text = data['tieu_de'];
      final dateString = data['ngay_toi_thieu'].toDate();
      final dateStringText =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(dateString);
      _ngay_de_xuat.text = dateStringText;
      _thoi_gian_cvController.text = data['thoi_gian_cv'];
      // _dia_diemController.text = data['dia_diem'];
      _currentItemSelected = data['do_uu_tien'];
      filePDF_ban_dau = data['file_pdf'];
      filePDF_so_sanh = data['file_pdf'];

      if (data['file_pdf'] == '') {
        fileNameDefault = 'Chọn file PDF';
        fileNameDefault1 = 'Chọn file PDF';
      } else {
        // refileNamDefault = data['file_pdf'].split('/')[1];
        // fileNameDefault = refileNamDefault.split('_)()(_')[0];
        // isEmptyFileName = false;
        if (data['file_pdf'].toString().contains('_=)()(=_')) {
          is2file = true;
          refileNamDefault = data['file_pdf'].split('/')[2];
          fileNameDefault = refileNamDefault.split('_)()(_').first;

          refileNamDefault1 = data['file_pdf'].split('/')[1];
          fileNameDefault1 = refileNamDefault1.split('_)()(_').first;

          filePDFPath = data['file_pdf'].split('_=)()(=_')[0];
          filePDFPath1 = data['file_pdf'].split('_=)()(=_')[1];
        } else {
          filePDFPath = data['file_pdf'];

          refileNamDefault = data['file_pdf'].split('/')[1];
          fileNameDefault = refileNamDefault.split('_)()(_').first;
        }
      }
      //load công việc cũ
      _tieu_de = data['tieu_de'];
      _ten_cong_viec = data['ten_cong_viec'];
      _ngay_toi_thieu = dateStringText;
      _thoi_gianCV = data['thoi_gian_cv'];
      // _dia_diem = data['dia_diem'];
      _do_uu_tien = data['do_uu_tien'];
    }
  }

  void sendMail() async {
    var userEmail = _email_PB;
    final smtpServer = gmail(_email_PB.toString(), _app_Password);
    final message = Message()
      ..from = Address(_email_PB.toString(), _ten_PB)
      ..recipients.add(_email_TK.toString())
      // ..ccRecipients.addAll(['recipient2@example.com', 'recipient3@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Phòng ban ' + _ten_PB + '  sửa công việc'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Công việc trước sửa!</h1>\n\n<h2>-Tiêu đề:${_tieu_de}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viec}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gianCV} phút</h2>\n<h2>-Địa điểm: ${_dia_diem}</h2>\n<h2>-Ngày tối thiểu : ${_ngay_toi_thieu}</h2>\n<h2>-Độ ưu tiên : ${_do_uu_tien}</h2> \n<h1>Công việc sau sửa!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_cvController.text} phút</h2>\n<h2>-Địa điểm: ${_dia_diemController.text}</h2>\n<h2>-Ngày đề xuất : ${_ngay_de_xuat.text}</h2>\n<h2>-Độ ưu tiên : ${rool}</h2>";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sửa công việc', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Hệ thống đang xử lí!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  color: Colors.grey[100],
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _tieu_deController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Tiêu đề',
                                enabled: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 14.0, bottom: 8.0, top: 8.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
                                  borderRadius: new BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
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
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Tên công việc',
                                enabled: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 14.0, bottom: 8.0, top: 15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
                                  borderRadius: new BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
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
                                hintText: 'Thời gian dự kiến(phút)',
                                enabled: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 14.0, bottom: 8.0, top: 15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
                                  borderRadius: new BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
                                  borderRadius: new BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                RegExp regex = RegExp(r'^[0-9]+$');

                                if (value!.isEmpty) {
                                  return "Tên công việc không được để trống!";
                                }
                                if (!regex.hasMatch(value)) {
                                  return ("Bạn phải nhập số!");
                                }
                                if (int.parse(value) >
                                    thoi_gian_cong_viec_max) {
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
                            // TextFormField(
                            //   controller: _dia_diemController,
                            //   decoration: InputDecoration(
                            //     filled: true,
                            //     fillColor: Colors.white,
                            //     hintText: 'Địa điểm',
                            //     enabled: true,
                            //     contentPadding: const EdgeInsets.only(
                            //         left: 14.0, bottom: 8.0, top: 15.0),
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide:
                            //           new BorderSide(color: Colors.white),
                            //       borderRadius: new BorderRadius.circular(10),
                            //     ),
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide:
                            //           new BorderSide(color: Colors.white),
                            //       borderRadius: new BorderRadius.circular(10),
                            //     ),
                            //   ),
                            //   validator: (value) {
                            //     if (value!.isEmpty) {
                            //       return "Địa điểm không được để trống";
                            //     } else {
                            //       return null;
                            //     }
                            //   },
                            //   onSaved: (value) {
                            //     _dia_diemController.text = value!;
                            //   },
                            // ),
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
                                        final dsTenPB = snapshot
                                            .data?.docs.reversed
                                            .toList();
                                        tenPBItems.add(DropdownMenuItem(
                                            value: '0',
                                            child: Text('Chọn địa điểm')));
                                        for (var tenPhongBan in dsTenPB!) {
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
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Ngày đề xuất',
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Thời gian dự kiến(phút)',
                                enabled: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 14.0, bottom: 8.0, top: 15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
                                  borderRadius: new BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.white),
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
                                                  print('path:' + path);
                                                  file = File(path);
                                                  fileName = file!.path
                                                      .split('/')
                                                      .last;

                                                  setState(() {
                                                    //    isFileChange = true;
                                                    isfileNameExsited = true;
                                                    print('file name:' +
                                                        fileName);
                                                    filePDFPath = getRandString(
                                                        fileName.length,
                                                        UserID.localUID,
                                                        fileName);
                                                    print(filePDFPath);
                                                    // ranDomTenFilePDF =
                                                    //     getRandString(
                                                    //         fileName.length,
                                                    //         UserID.localUID,
                                                    //         fileName);
                                                    // print('random name:' +
                                                    //     ranDomTenFilePDF);
                                                    // filePDF_so_sanh =
                                                    //     ranDomTenFilePDF;
                                                  });
                                                }
                                              },
                                              child: Text(
                                                isfileNameExsited
                                                    ? fileName
                                                    : fileNameDefault,
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
                                                  // isFileChange = true;
                                                  filePDFPath = '';
                                                  isEmptyFileName = true;
                                                  file = File('');
                                                  fileName = '';
                                                  fileNameDefault =
                                                      'Chọn file pdf';
                                                  isfileNameExsited = false;
                                                  // print('file:' +
                                                  //     file.toString());
                                                  // print('fileName:' + fileName);
                                                  // print(getRandString(
                                                  //     fileName.length,
                                                  //     fileName,
                                                  //     UserID.localUID));
                                                  // print(isfileNameExsited
                                                  //     .toString());
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
                                          final path1 =
                                              await FlutterDocumentPicker
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
                                            print(path1);
                                            file1 = File(path1);
                                            fileName1 =
                                                file1!.path.split('/').last;
                                            setState(() {
                                              // isFileChange1 = true;
                                              filePDFPath1 = getRandString(
                                                  fileName1.length,
                                                  UserID.localUID,
                                                  fileName1);
                                              isfileNameExsited1 = true;
                                              // print('file name:' + fileName1);
                                              // ranDomTenFilePDF1 = getRandString(
                                              //     fileName1.length,
                                              //     UserID.localUID,
                                              //     fileName1);
                                              // print('random name:' +
                                              //     ranDomTenFilePDF1);
                                            });
                                          }
                                        },
                                        child: Text(
                                          isfileNameExsited1
                                              ? fileName1
                                              : fileNameDefault1,
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
                                            //    isFileChange1 = true;
                                            file1 = File('');
                                            fileName1 = '';
                                            isfileNameExsited1 = false;
                                            ranDomTenFilePDF1 = '';
                                            filePDFPath1 = '';
                                            fileNameDefault1 = 'Chọn file pdf';
                                            // print(fileName1);
                                            // print(getRandString(
                                            //     fileName1.length,
                                            //     fileName1,
                                            //     UserID.localUID));
                                            // print(
                                            //     isfileNameExsited1.toString());
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
                                  items:
                                      options.map((String dropDownStringItem) {
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
                                // if (fileName == '' && fileName1 == '') {
                                //   tenFilePDF = '';
                                // } else if (fileName != '' && fileName1 == '') {
                                //   tenFilePDF = ranDomTenFilePDF;
                                // } else if (fileName == '' && fileName1 != '') {
                                //   tenFilePDF = ranDomTenFilePDF1;
                                // } else {
                                //   tenFilePDF = ranDomTenFilePDF +
                                //       '_=)()(=_' +
                                //       ranDomTenFilePDF1;
                                // }
                                //_editItem();
                                // if (filePDF_ban_dau
                                //     .toString()
                                //     .contains('_=)()(=_')) {
                                //   if (isFileChange == false &&
                                //       isFileChange1 == false) {
                                //     tenFilePDF = filePDF_ban_dau;
                                //   } //ko có j đổi
                                //   if (isFileChange == false &&
                                //       isFileChange1 == true) {
                                //     tenFilePDF = ranDomTenFilePDF +
                                //         filePDF_ban_dau
                                //             .toString()
                                //             .split('_=)()(=_')[1];
                                //   }
                                //   if (isFileChange == true &&
                                //       isFileChange1 == false) {
                                //     tenFilePDF = filePDF_ban_dau
                                //             .toString()
                                //             .split('_=)()(=_')[0] +
                                //         ranDomTenFilePDF1;
                                //   }
                                //   if (isFileChange == true &&
                                //       isFileChange1 == true) {
                                //     tenFilePDF =
                                //         ranDomTenFilePDF + ranDomTenFilePDF1;
                                //   }
                                // } else {
                                //   if (isFileChange == false &&
                                //       isFileChange1 == false) {
                                //     tenFilePDF = filePDF_ban_dau;
                                //   }
                                //   if (isFileChange == true) {
                                //     tenFilePDF = ranDomTenFilePDF +
                                //         "_=)()(=_" +
                                //         filePDF_ban_dau;
                                //   }
                                //   if (isFileChange1 == true) {
                                //     tenFilePDF = ranDomTenFilePDF1 +
                                //         "_=)()(=_" +
                                //         filePDF_ban_dau;
                                //   }
                                // }
                                // print(filePDFPath);
                                // print(filePDFPath1);
                                // if (filePDFPath == '') {
                                //   tenFilePDF = filePDFPath1;
                                // } else if (filePDFPath1 == '') {
                                //   tenFilePDF = filePDFPath;
                                // } else if (filePDFPath != '' &&
                                //     filePDFPath1 != '') {
                                //   tenFilePDF =
                                //       filePDFPath + '_=)()(=_' + filePDFPath1;
                                // }
                                // print(tenFilePDF);
                                // print(fileName);
                                // print(fileName1);
                                _editItem();
                                // print(refileNamDefault);
                                // print(refileNamDefault1);
                                // print('file' + fileName);
                                // print(fileName1);
                                // print(tenFilePDF);
                                //  else {
                                //   if (isFileChange == false ||
                                //       isFileChange1 == false) {
                                //     tenFilePDF = filePDF_ban_dau;
                                //   } //ko có j đổi
                                //   if (isFileChange == false ||
                                //       isFileChange1 == true) {
                                //     tenFilePDF = ranDomTenFilePDF +
                                //         filePDF_ban_dau
                                //             .toString()
                                //             .split('_=)()(=_')[0];
                                //   }
                                //   if (isFileChange == true ||
                                //       isFileChange1 == false) {
                                //     tenFilePDF = filePDF_ban_dau
                                //             .toString()
                                //             .split('_=)()(=_')[0] +
                                //         ranDomTenFilePDF1;
                                //   }
                                //   if (isFileChange == true ||
                                //       isFileChange1 == true) {
                                //     tenFilePDF =
                                //         ranDomTenFilePDF + ranDomTenFilePDF1;
                                //   }
                                // }
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
                ),
              ],
            ),
    );
  }
}
