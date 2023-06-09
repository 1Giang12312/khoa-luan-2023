import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ListTaiKhoanDetails extends StatefulWidget {
  ListTaiKhoanDetails({super.key, required this.userIDString});
  String userIDString;
  @override
  State<ListTaiKhoanDetails> createState() => _ListTaiKhoanDetailsState();
}

class _ListTaiKhoanDetailsState extends State<ListTaiKhoanDetails> {
  final TextEditingController tenController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController sdtController = new TextEditingController();
  final TextEditingController appPasswordController =
      new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController faxController = new TextEditingController();
  final TextEditingController quyenHanController = new TextEditingController();
  final TextEditingController phongBanController = new TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isReadOnly = true;
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(widget.userIDString).get();
    tenController.text = userDoc['ten'];
    emailController.text = userDoc['email'];
    sdtController.text = userDoc['so_dien_thoai'];
    appPasswordController.text = userDoc['app_password'];
    // if (userDoc['quyen_han'] == 'TK') {
    //   quyenHanController.text = 'Thư kí';
    // } else if (userDoc['quyen_han'] == 'GD') {
    //   quyenHanController.text = 'Giám đốc';
    // } else {
    //   quyenHanController.text = 'Phòng ban';
    // }
    final quyenhanCollection =
        FirebaseFirestore.instance.collection('quyen_han');
    final taikhoanCollection =
        FirebaseFirestore.instance.collection('tai_khoan');

    final userID = widget.userIDString;

    final userQuyenHanDoc = await taikhoanCollection.doc(userID).get();
    final quyenHanID = userQuyenHanDoc['quyen_han_id'];
    final quyenHanDoc = await quyenhanCollection.doc(quyenHanID).get();
    final ten_quyen_han = quyenHanDoc['ten_quyen_han'];
    quyenHanController.text = ten_quyen_han;

    final phongBanCollection =
        FirebaseFirestore.instance.collection('phong_ban');

    final userPhongBanDoc = await taikhoanCollection.doc(userID).get();
    final phongBanID = userPhongBanDoc['phong_ban_id'];
    final phongBanDoc = await phongBanCollection.doc(phongBanID).get();
    final ten_phong_ban = phongBanDoc['ten_phong_ban'];
    phongBanController.text = ten_phong_ban;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Thông tin cá nhân ',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
                    "Đang tải!",
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
                                  TextFormField(
                                    readOnly: true,
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
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
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
                                    readOnly: true,
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
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
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
                                    readOnly: true,
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
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
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
                                    height: 10,
                                  ),
                                  // TextFormField(
                                  //   obscureText: _isObscure,
                                  //   controller: appPasswordController,
                                  //   decoration: InputDecoration(
                                  //     suffixIcon: IconButton(
                                  //         icon: Icon(_isObscure
                                  //             ? Icons.visibility_off
                                  //             : Icons.visibility),
                                  //         onPressed: () {
                                  //           setState(() {
                                  //             _isObscure = !_isObscure;
                                  //           });
                                  //         }),
                                  //     filled: true,
                                  //     fillColor: Colors.white,
                                  //     labelText: 'App password',
                                  //     enabled: true,
                                  //     contentPadding: const EdgeInsets.only(
                                  //         left: 14.0, bottom: 8.0, top: 15.0),
                                  //     focusedBorder: OutlineInputBorder(
                                  //       borderSide:
                                  //           new BorderSide(color: Colors.white),
                                  //       borderRadius:
                                  //           new BorderRadius.circular(20),
                                  //     ),
                                  //     enabledBorder: UnderlineInputBorder(
                                  //       borderSide:
                                  //           new BorderSide(color: Colors.white),
                                  //       borderRadius:
                                  //           new BorderRadius.circular(20),
                                  //     ),
                                  //   ),
                                  //   validator: (value) {
                                  //     if (value!.length == 0) {
                                  //       return "App password không được để trống!";
                                  //     } else {
                                  //       return null;
                                  //     }
                                  //   },
                                  //   onChanged: (value) {},
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  TextFormField(
                                    controller: quyenHanController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Quyền hạn',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabled: true,
                                      contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: phongBanController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Phòng ban',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabled: true,
                                      contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.white),
                                        borderRadius:
                                            new BorderRadius.circular(20),
                                      ),
                                    ),
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
                                    ],
                                  ),
                                  SizedBox(
                                    height: 100,
                                  ),
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
