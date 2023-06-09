import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class EditPhongBan extends StatefulWidget {
  EditPhongBan({super.key, required this.phongBanID});
  String phongBanID;
  @override
  State<EditPhongBan> createState() => _EditPhongBanState();
}

class _EditPhongBanState extends State<EditPhongBan> {
  final TextEditingController tenPhongBanController =
      new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController sdtController = new TextEditingController();
  final TextEditingController faxController = new TextEditingController();

  final _formkey = GlobalKey<FormState>();
  late bool isLoading = false;
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
            .collection('phong_ban')
            .doc(widget.phongBanID)
            .update({
          "ten_phong_ban": tenPhongBanController.text,
          "so_dien_thoai": sdtController.text,
          "fax": faxController.text,
          "email": emailController.text
        });

        if (mounted) {
          print('sua thanh cong');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Sửa thông tin phòng ban thành công'),
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
    setState(() {
      isLoading = true;
    });
    final usersCollection = FirebaseFirestore.instance.collection('phong_ban');
    final userDoc = await usersCollection.doc(widget.phongBanID).get();
    tenPhongBanController.text = userDoc['ten_phong_ban'];
    emailController.text = userDoc['email'];
    sdtController.text = userDoc['so_dien_thoai'];
    faxController.text = userDoc['fax'];
    // if (userDoc['quyen_han'] == 'TK') {
    //   quyenHanController.text = 'Thư kí';
    // } else if (userDoc['quyen_han'] == 'GD') {
    //   quyenHanController.text = 'Giám đốc';
    // } else {
    //   quyenHanController.text = 'Phòng ban';
    // }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sửa thông tin phòng ban ',
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
                                    controller: tenPhongBanController,
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
                                      if (!RegExp("^[a-zA-Z0-9+_.-]+@gmail.com") //regexp agu mail
                                              .hasMatch(value) &&
                                          !RegExp("^[a-zA-Z0-9+_.-]+@agu.edu.vn") //regexp agu mail
                                              .hasMatch(value)) {
                                        return ("Hãy nhập đúng mail");
                                      } else {
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
                                      if (value!.length != 0) {
                                        if (!regex.hasMatch(value!)) {
                                          return ("Bạn phải nhập số!");
                                        }
                                        if (value!.length < 10 ||
                                            value!.length > 11) {
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
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
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
