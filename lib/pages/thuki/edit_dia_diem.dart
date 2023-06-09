import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class EditDiaDiem extends StatefulWidget {
  EditDiaDiem({super.key, required this.diaDiemID});
  String diaDiemID;
  @override
  State<EditDiaDiem> createState() => _EditDiaDiemState();
}

class _EditDiaDiemState extends State<EditDiaDiem> {
  final TextEditingController tenDiaDiemController =
      new TextEditingController();
  final TextEditingController ghiChuController = new TextEditingController();

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
            .collection('dia_diem')
            .doc(widget.diaDiemID)
            .update({
          "ten_dia_diem": tenDiaDiemController.text,
          "ghi_chu": ghiChuController.text
        });

        if (mounted) {
          print('sua thanh cong');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Sửa thông tin địa điểm thành công'),
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
    final usersCollection = FirebaseFirestore.instance.collection('dia_diem');
    final userDoc = await usersCollection.doc(widget.diaDiemID).get();
    tenDiaDiemController.text = userDoc['ten_dia_diem'];
    ghiChuController.text = userDoc['ghi_chu'];
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
        title: Text('Sửa thông tin địa điểm ',
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
                                    controller: tenDiaDiemController,
                                    decoration: InputDecoration(
                                      labelText: 'Tên địa điểm',
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
                                    controller: ghiChuController,
                                    decoration: InputDecoration(
                                      labelText: 'Ghi chú',
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
