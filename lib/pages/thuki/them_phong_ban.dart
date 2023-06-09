import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'list_phong_ban.dart';

class ThemPhongBan extends StatefulWidget {
  // final DateTime firstDate;
  // final DateTime lastDate;
  //final DateTime? selectedDate;
  const ThemPhongBan({
    Key? key,
    // required this.firstDate,
    // required this.lastDate,
    // this.selectedDate
  }) : super(key: key);

  @override
  State<ThemPhongBan> createState() => _ThemPhongBanState();
}

class _ThemPhongBanState extends State<ThemPhongBan> {
  //

  final _formkey = GlobalKey<FormState>();
  final TextEditingController _ten_phong_ban = new TextEditingController();
  final TextEditingController faxController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController sdtController = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  _kiemTraTenTaiKhoanTrung(String tenPhongBan) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('phong_ban')
        .where('ten_phong_ban', isEqualTo: tenPhongBan)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void _addPhongBan() async {
    if (_formkey.currentState!.validate()) {
      try {
        if (_kiemTraTenTaiKhoanTrung(_ten_phong_ban.text) == false) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                title: Center(
                  child: Text(
                    'Phòng ban này đã tồn tại',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        } else {
          await FirebaseFirestore.instance.collection('phong_ban').add({
            "email": emailController.text,
            "fax": faxController.text,
            "so_dien_thoai": sdtController.text,
            "ten_phong_ban": _ten_phong_ban.text,
            "is_truong_phong": false
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Thêm phòng ban thành công'),
              action: SnackBarAction(
                label: 'Hủy',
                onPressed: () {},
              ),
            ));
            Navigator.of(context).pop();
            final res = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ListPhongBan(isRouteGD: false),
              ),
            );
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Thêm phòng ban mới', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                        controller: _ten_phong_ban,
                        decoration: InputDecoration(
                          labelText: 'Tên phòng ban',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tên phòng ban',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "Tên phòng ban không được để trống";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _ten_phong_ban.text = value!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "Email không được để trống!";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@agu.edu.vn")
                                  .hasMatch(value) &&
                              !RegExp("^[a-zA-Z0-9+_.-]+@gmail.com")
                                  .hasMatch(value)) {
                            return ("Hãy mail đúng");
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {},
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: faxController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Số fax',
                          hintText: 'Số fax(hoặc không)',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          RegExp regex = RegExp(r'^[0-9]+$');
                          if (value!.length != 0) {
                            if (!regex.hasMatch(value!)) {
                              return ("Bạn phải nhập số!");
                            }
                            if (value!.length < 10 || value!.length > 11) {
                              return ('Bạn phải nhập 10 số hoặc 11 số');
                            } else {
                              return null;
                            }
                          } else {
                            value = '';
                          }
                        },
                        onChanged: (value) {},
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: sdtController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Số điện thoại',
                          hintText: 'Số điện thoại',
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          RegExp regex = RegExp(r'^[0-9]+$');

                          if (value!.length == 0) {
                            return "Số điện thoại không được để trống!";
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Bạn phải nhập số!");
                          }
                          if (value!.length < 10 || value!.length > 12) {
                            return ('Bạn phải nhập 10 số hoặc 11 số hoặc 12 số');
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {},
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        elevation: 5.0,
                        height: 40,
                        onPressed: () {
                          _addPhongBan();
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
