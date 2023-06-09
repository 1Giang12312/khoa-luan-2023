import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'list_dia_diem.dart';
import 'list_phong_ban.dart';

class ThemDiaDiem extends StatefulWidget {
  // final DateTime firstDate;
  // final DateTime lastDate;
  //final DateTime? selectedDate;
  const ThemDiaDiem({
    Key? key,
    // required this.firstDate,
    // required this.lastDate,
    // this.selectedDate
  }) : super(key: key);

  @override
  State<ThemDiaDiem> createState() => _ThemDiaDiemState();
}

class _ThemDiaDiemState extends State<ThemDiaDiem> {
  //

  final _formkey = GlobalKey<FormState>();
  final TextEditingController _ten_dia_diem = new TextEditingController();
  final TextEditingController _ghi_chu = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  _kiemTraTenDiaDiemTrung(String tenPhongBan) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('dia_diem')
        .where('ten_dia_diem', isEqualTo: tenPhongBan)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void _addDiaDiem() async {
    if (_ten_dia_diem.text.isEmpty) {
      _ten_dia_diem.text = '';
    }
    if (_formkey.currentState!.validate()) {
      try {
        if (_kiemTraTenDiaDiemTrung(_ten_dia_diem.text) == false) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                title: Center(
                  child: Text(
                    'Đại điểm này đã tồn tại',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        } else {
          await FirebaseFirestore.instance.collection('dia_diem').add({
            "ghi_chu": _ghi_chu.text,
            "ten_dia_diem": _ten_dia_diem.text,
            "trang_thai": true,
            "is_from_google_calendar": false
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Thêm địa diểm thành công'),
              action: SnackBarAction(
                label: 'Hủy',
                onPressed: () {},
              ),
            ));
            Navigator.of(context).pop();
            final res = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ListDiaDiem(
                  isRouteGD: false,
                  isRoutePB: false,
                  isRouteTK: true,
                  isRouteTVPB: false,
                ),
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
        title: Text('Thêm địa diểm mới', style: TextStyle(color: Colors.white)),
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
                        controller: _ten_dia_diem,
                        decoration: InputDecoration(
                          labelText: 'Tên địa diểm',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tên địa diểm',
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
                            return "Tên địa diểm không được để trống";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _ten_dia_diem.text = value!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _ghi_chu,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú(hoặc không)',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ghi chú(hoặc không)',
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
                        onChanged: (value) {},
                        keyboardType: TextInputType.emailAddress,
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        elevation: 5.0,
                        height: 40,
                        onPressed: () {
                          _addDiaDiem();
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
