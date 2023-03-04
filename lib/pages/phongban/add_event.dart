import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:khoa_luan1/pages/phongban/PB_home_page.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

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

  // Định dạng năm-tháng-ngày

  final thoi_gian_cong_viec_max = 240; //phut
  var _email_PB = '';
  var _app_Password = '';
  var _ten_PB = '';
  var _email_TK = '';
  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    print(uid);
    getName();
    // print(_email_PB);
    // print(_app_Password);
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    // print(_formattedNgaydx);
    //_selectedDate = widget.selectedDate ?? DateTime.now();
  }

  void _addEvent() async {
    final DateTime now;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final tenCongViec = _ten_cong_viecController.text;
    final thoiGiancv = _thoi_gian_cvController.text;
    final tieuDe = _tieu_deController.text;
    final diadiem = _dia_diemController.text;
    // DateTime _formattedNgaydx = DateTime.parse(_ngay_de_xuat.text);
    // //_ngay_de_xuat_formatted = DateFormat.yMEd();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(_formattedNgaydx);

    // print(_formattedNgaydx);
    // if (tenCongViec.isEmpty || thoiGiancv.isEmpty || tieuDe.isEmpty) {
    //   return ;
    // }
    // DateTime formattedDay = DateFormat('yyyy-MM-dd').format(DateTime.parse(_ngay_de_xuat.text));

    if (_formkey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            // .collection('tai_khoan')
            // .doc(uid)
            .collection('cong_viec')
            .add({
          "gd_huy": false,
          "ngay_gio_bat_dau": Timestamp.fromDate(DateTime.now()),
          "ngay_post": Timestamp.fromDate(DateTime.now()),
          "ten_cong_viec": tenCongViec,
          "thoi_gian_cv": thoiGiancv,
          "tieu_de": tieuDe,
          //thu ki duyet
          "tk_duyet": false,
          "trang_thai": true,
          "do_uu_tien": rool,
          "tai_khoan_id": uid,
          // lỗi
          "pb_huy": false,
          "ngay_toi_thieu":
              Timestamp.fromDate(DateTime.parse(_ngay_de_xuat.text)),
          "ngay_gio_ket_thuc": Timestamp.fromDate(DateTime.now()),
          "dia_diem": diadiem
        });
        if (mounted) {
          sendMail();
          Navigator.pop<bool>(context, true);

          //PhongBanHomePage();
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
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(uid).get();
    final _email = userDoc['email'];
    final _app_PW = userDoc['app_password'];
    final _ten = userDoc['ten'];
    _app_Password = _app_PW;
    _email_PB = _email;
    _ten_PB = _ten;
    final thuKiCollection = FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han', isEqualTo: 'TK')
        .limit(1)
        .get();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('quyen_han', isEqualTo: 'TK')
        .limit(1)
        .get();
    _email_TK = querySnapshot.docs.first['email'];
    print(_email_TK);
    setState(() {});
    //print(tenPB);
  }

  // Future<void> sendGmail() async {
  //   try {
  //     var userEmail = _email_PB;
  //     print('-Tiêu đề công việc: ' +
  //         _tieu_deController.text +
  //         '\n' +
  //         '-Tên(chi tiết) công việc: ' +
  //         _ten_cong_viecController.text +
  //         '\n' +
  //         '-Thời gian diễn ra: ' +
  //         _thoi_gian_cvController.text +
  //         '\n' +
  //         '-Địa điểm: ' +
  //         _dia_diemComtroller.text +
  //         '\n' +
  //         '-Ngày đề xuất: ' +
  //         _ngay_de_xuat.text +
  //         '\n' +
  //         _ten_PB +
  //         userEmail +
  //         _app_Password);
  //     var message = Message();
  //     message.subject = 'Phòng ban' + ' thêm công việc mới';
  //     message.text = '-Tiêu đề công việc: ';
  //     message.from = Address(userEmail.toString());
  //     message.recipients.add('vtgiang_20pm@student.agu.edu.vn');
  //     var smtSever = gmailSaslXoauth2(userEmail, 'bkgmulqfkdnztsfe');
  //     send(message, smtSever);
  //     print('email sended');
  //   } catch (e) {
  //     print('${e.toString()}');
  //   }
  // }

  void sendMail() async {
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
          "<h1>Công việc mới!</h1>\n<h2>-Tiêu đề:${_tieu_deController.text}</h2>\n<h2>-Tên(chi tiết):${_ten_cong_viecController.text}</h2>\n<h2>-Thời gian diễn ra: ${_thoi_gian_cvController.text} phút</h2>\n<h2>-Địa điểm: ${_dia_diemController.text}</h2>\n<h2>-Ngày đề xuất : ${_ngay_de_xuat.text}</h2>\n<h2>-Độ ưu tiên : ${rool}</h2>";

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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Thêm công việc")),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           TextFormField(
//             controller: _tieu_deController,
//             maxLines: 1,
//             decoration: InputDecoration(
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.shade400),
//                 ),
//                 fillColor: Colors.grey.shade200,
//                 filled: true,
//                 hintText: 'Tiêu đề',
//                 hintStyle: TextStyle(color: Colors.grey[400])),
//             validator: (value) {
//               if (value!.length == 0) {
//                 return "Tiêu đề không được để trống";
//               } else {
//                 return null;
//               }
//             },
//             onSaved: (value) {
//               _tieu_deController.text = value!;
//             },
//             keyboardType: TextInputType.emailAddress,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           TextFormField(
//             controller: _ten_cong_viecController,
//             maxLines: 3,
//             decoration: InputDecoration(
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.shade400),
//                 ),
//                 fillColor: Colors.grey.shade200,
//                 filled: true,
//                 hintText: 'Tên công việc',
//                 hintStyle: TextStyle(color: Colors.grey[400])),
//             validator: (value) {
//               if (value!.length == 0) {
//                 return "Tiêu đề không được để trống";
//               } else {
//                 return null;
//               }
//             },
//             onSaved: (value) {
//               _tieu_deController.text = value!;
//             },
//             keyboardType: TextInputType.emailAddress,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           TextFormField(
//             controller: _thoi_gian_cvController,
//             maxLines: 1,
//             decoration: InputDecoration(
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.shade400),
//                 ),
//                 fillColor: Colors.grey.shade200,
//                 filled: true,
//                 hintText: 'Thời gian dự kiến (phút)',
//                 hintStyle: TextStyle(color: Colors.grey[400])),
//             validator: (value) {
//               if (value!.length == 0) {
//                 return "Tiêu đề không được để trống";
//               } else {
//                 return null;
//               }
//             },
//             onSaved: (value) {
//               _tieu_deController.text = value!;
//             },
//             keyboardType: TextInputType.emailAddress,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
//             ),
//             onPressed: () {
//               _addEvent();
//             },
//             child: const Text(
//               "Lưu",
//               style: TextStyle(fontSize: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      backgroundColor: Colors.grey[100],
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
                      Text(
                        'Thêm mới',
                        style: TextStyle(fontSize: 30),
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                            return "Tên công việc không được để trống!";
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
                      TextFormField(
                        controller: _dia_diemController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Địa điểm',
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
                            return "Địa điểm không được để trống";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _dia_diemController.text = value!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // InputDatePickerFormField(
                      //   firstDate: widget.firstDate,
                      //   lastDate: widget.lastDate,
                      //   initialDate: _selectedDate,
                      //   onDateSubmitted: (date) {
                      //     print(date);
                      //     setState(() {
                      //       _selectedDate = date;
                      //     });
                      //   },
                      // ),
                      Wrap(
                        children: [
                          TextFormField(
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
                          _addEvent();
                          //getName();
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
