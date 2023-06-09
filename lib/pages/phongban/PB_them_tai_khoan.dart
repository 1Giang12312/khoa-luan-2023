import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/UserID.dart';

class PBThemTaiKhoan extends StatefulWidget {
  @override
  _PBThemTaiKhoanState createState() => _PBThemTaiKhoanState();
}

class _PBThemTaiKhoanState extends State<PBThemTaiKhoan> {
  _PBThemTaiKhoanState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmpassController =
      new TextEditingController();
  final TextEditingController name = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController sdtController = new TextEditingController();
  final TextEditingController appPasswordController =
      new TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;

  var rool = "";
  var phongBanID = '';
  List<DropdownMenuItem<String>> _categoriesList = [];
  String selectedPB = '0';
  late bool isLoading = false;
  var isSignUpSuccess = true;
  @override
  void initState() {
    super.initState();
    isSignUpSuccess = true;
    layPhongBanID();
  }

  layPhongBanID() async {
    setState(() {
      isLoading = true;
    });
    final taikhoanCollection =
        FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await taikhoanCollection.doc(UserID.localUID).get();
    phongBanID = userDoc['phong_ban_id'];
    print(phongBanID);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? AppBar(
              title: Text('Đăng kí', style: TextStyle(color: Colors.white)))
          : AppBar(
              title: Text('Đăng kí', style: TextStyle(color: Colors.white)),
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
                children: <Widget>[
                  Container(
                    color: Colors.grey[100],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(12),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 70,
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
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
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
                                controller: appPasswordController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'App password',
                                  hintText: 'App password',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return "App password không được để trống!";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {},
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: name,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Tên',
                                  hintText: 'Tên',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return "Tên không được để trống!";
                                  } else {
                                    return null;
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
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
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
                                  if (value!.length < 10 ||
                                      value!.length > 12) {
                                    return ('Bạn phải nhập 10 số hoặc 11 số hoặc 12 số');
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {},
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // TextFormField(
                              //   controller: faxController,
                              //   decoration: InputDecoration(
                              //     filled: true,
                              //     fillColor: Colors.white,
                              //     labelText: 'Số fax',
                              //     hintText: 'Số fax(hoặc không)',
                              //     enabled: true,
                              //     contentPadding: const EdgeInsets.only(
                              //         left: 14.0, bottom: 8.0, top: 8.0),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderSide:
                              //           new BorderSide(color: Colors.white),
                              //       borderRadius: new BorderRadius.circular(20),
                              //     ),
                              //     enabledBorder: UnderlineInputBorder(
                              //       borderSide:
                              //           new BorderSide(color: Colors.white),
                              //       borderRadius: new BorderRadius.circular(20),
                              //     ),
                              //   ),
                              //   validator: (value) {
                              //     RegExp regex = RegExp(r'^[0-9]+$');
                              //     if (value!.length != 0) {
                              //       if (!regex.hasMatch(value!)) {
                              //         return ("Bạn phải nhập số!");
                              //       }
                              //       if (value!.length < 10 ||
                              //           value!.length > 11) {
                              //         return ('Bạn phải nhập 10 số hoặc 11 số');
                              //       } else {
                              //         return null;
                              //       }
                              //     } else {
                              //       value = '';
                              //     }
                              //   },
                              //   onChanged: (value) {},
                              // ),
                              Wrap(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('quyen_han')
                                          .where('ten_quyen_han', whereIn: [
                                        'Thành viên phòng ban',
                                        "Phó phòng ban"
                                      ]).snapshots(),
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
                                              child: Text('Chọn quyền hạn')));
                                          for (var tenPhongBan in dsTenPB!) {
                                            tenPBItems.add(
                                              DropdownMenuItem(
                                                value: tenPhongBan.id,
                                                child: Text(
                                                  tenPhongBan['ten_quyen_han'],
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
                              TextFormField(
                                obscureText: _isObscure,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      }),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Mật khẩu',
                                  hintText: 'Mật khẩu',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                ),
                                validator: (value) {
                                  RegExp regex = new RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Mật khẩu không được để trống!";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("Mật khẩu dài hơn 6 kí tự!");
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {},
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                obscureText: _isObscure2,
                                controller: confirmpassController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure2
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure2 = !_isObscure2;
                                        });
                                      }),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Nhập lại mật khẩu',
                                  hintText: 'Nhập lại mật khẩu',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(20),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Mật khẩu không được để trống";
                                  }
                                  if (confirmpassController.text !=
                                      passwordController.text) {
                                    return "Mật khẩu nhập lại không hợp lệ";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {},
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 5.0,
                                height: 40,
                                onPressed: () {
                                  signUp(emailController.text,
                                      passwordController.text, rool);
                                },
                                child: Text(
                                  "Đăng kí",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 70,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void signUp(String email, String password, String rool) async {
    //CircularProgressIndicator();
    setState(() {
      isLoading = true;
    });
    try {
      if (selectedPB == '0') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 0, 0),
              title: Center(
                child: Text(
                  'Hãy chọn quyền hạn',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      } else {
        if (_formkey.currentState!.validate()) {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password)
              .then((value) => {postDetailsToFirestore(email, rool)})
              .catchError((e) {
            print(e);
            if (e.code == 'email-already-in-use') {
              isSignUpSuccess = false;
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color.fromARGB(255, 255, 0, 0),
                    title: Center(
                      child: Text(
                        'Email đã này đã được đăng kí',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }
          });
          // if (mounted) {
          //   Navigator.of(context).pop();
          //   final snackBar = SnackBar(
          //     content: Text('Đã đăng kí tài khoản thành công!'),
          //     action: SnackBarAction(
          //       label: 'Tắt',
          //       onPressed: () {},
          //     ),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // }
          if (isSignUpSuccess != false) {
            Navigator.of(context).pop();
            final snackBar = SnackBar(
              content: Text('Đã đăng kí tài khoản thành công!'),
              action: SnackBarAction(
                label: 'Tắt',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
        // } on FirebaseAuthException catch (e) {
        //   // pop the loading circle
        //   Navigator.pop(context);
        //   // show error message
        //   showErrorMessage(e.code);
        // }
      }
    } catch (e) {
      print(e);
    }
    // if (mounted) {
    //   Navigator.of(context).pop();
    //   final snackBar = SnackBar(
    //     content: Text('Đã đăng kí tài khoản thành công!'),
    //     action: SnackBarAction(
    //       label: 'Tắt',
    //       onPressed: () {},
    //     ),
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // }
    setState(() {
      isLoading = false;
      isSignUpSuccess = true;
    });
  }

  postDetailsToFirestore(String email, String rool) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref =
        FirebaseFirestore.instance.collection('tai_khoan');
    ref.doc(user!.uid).set({
      'email': emailController.text,
      'ten': name.text,
      'trang_thai': true,
      'app_password': appPasswordController.text,
      'so_dien_thoai': sdtController.text,
      'FCMtoken': '',
      'phong_ban_id': phongBanID,
      'quyen_han_id': selectedPB
    });
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
