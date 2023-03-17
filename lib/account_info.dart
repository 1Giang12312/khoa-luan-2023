import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AccountInfor extends StatefulWidget {
  AccountInfor({super.key, required this.userIDString});
  String userIDString;
  @override
  State<AccountInfor> createState() => _AccountInforState();
}

class _AccountInforState extends State<AccountInfor> {
  final TextEditingController tenController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController sdtController = new TextEditingController();
  final TextEditingController appPasswordController =
      new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isReadOnly = true;
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void _editItem() async {
    final DateTime now;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    if (_formkey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            // .collection('tai_khoan')
            // .doc(uid)
            .collection('tai_khoan')
            .doc(widget.userIDString)
            .update({
          "app_password": appPasswordController.text,
          "email": emailController.text,
          "ten": tenController.text,
          "so_dien_thoai": sdtController.text,
        });

        if (mounted) {
          print('sua thanh cong');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Sửa thông tin cá nhân thành công'),
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
  }

  getData() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(widget.userIDString).get();
    tenController.text = userDoc['ten'];
    emailController.text = userDoc['email'];
    sdtController.text = userDoc['so_dien_thoai'];
    appPasswordController.text = userDoc['app_password'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Danh sác yêu cầu hủy ',
      //       style: TextStyle(color: Colors.black)),
      //   backgroundColor: Colors.grey[100],
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(
      //         Icons.clear,
      //         color: Colors.red,
      //       )),
      // ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
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
                              height: 25,
                            ),
                            Text(
                              "Thông tin cá nhân",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 40,
                              ),
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            TextFormField(
                              controller: tenController,
                              decoration: InputDecoration(
                                labelText: 'Tên',
                                filled: true,
                                fillColor: Colors.white,
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
                              height: 10,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.white,
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
                                // if (!RegExp(
                                //         "^[a-zA-Z0-9+_.-]+@gmail.com") //regexp agu mail
                                //     .hasMatch(value)) {
                                //   return ("Hãy nhập mail");
                                // }
                                else {
                                  return null;
                                }
                              },
                              onChanged: (value) {},
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: sdtController,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại',
                                filled: true,
                                fillColor: Colors.white,
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
                                if (value!.length != 10) {
                                  return ('Bạn phải nhập 10 số');
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {},
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              obscureText: _isObscure,
                              controller: appPasswordController,
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
                                labelText: 'App password',
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
                                if (value!.length == 0) {
                                  return "App password không được để trống!";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {},
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () {
                                    Navigator.pop(context);

                                    // signUp(emailController.text,
                                    //     passwordController.text, rool);
                                  },
                                  child: Text(
                                    "Trở lại",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () {
                                    _editItem();
                                    // signUp(emailController.text,
                                    //     passwordController.text, rool);
                                  },
                                  color: Colors.blue[900],
                                  child: Text(
                                    "Lưu",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
