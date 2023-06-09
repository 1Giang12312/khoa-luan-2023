import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  late bool _isEmailExit = false;
  Future<bool> checkEmail() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tai_khoan')
        .where('email', isEqualTo: _emailController.text)
        .get();
    if (querySnapshot.size.isNaN) {
      return false;
    } else
      return true;
  }

  Future<void> checkEmailExists(String email) async {
    try {
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.contains('password')) {
        print('Email $email đã tồn tại và có thể đăng nhập bằng mật khẩu.');
        _isEmailExit = true;
        auth.sendPasswordResetEmail(email: _emailController.text);
        Navigator.of(context).pop();
        final snackBar = SnackBar(
          content: Text('Hãy kiểm tra email của bạn'),
          action: SnackBarAction(
            label: 'Tắt',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        print(
            'Email $email đã tồn tại nhưng không thể đăng nhập bằng mật khẩu.');
        _isEmailExit = false;
      }
    } on FirebaseAuthException catch (e) {
      print('Lỗi: $e');
    }
    if (_isEmailExit == false) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            title: Center(
              child: Text(
                'Email chưa chính xác',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quên mật khẩu', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey[100],
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.clear,
                color: Color.fromARGB(255, 0, 0, 0),
              )),
        ),
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
            child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Email',
                  enabled: true,
                  contentPadding:
                      const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                    return "Email không được để trống";
                  }
                  // if (!RegExp("^[a-zA-Z0-9+_.-]+@gmail.com").hasMatch(value)) {
                  //   return ("Hãy nhập mail agu");
                  // }
                  else {
                    return null;
                  }
                },
                onSaved: (value) {
                  _emailController.text = value!;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                elevation: 5.0,
                height: 40,
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    try {
                      //trước khi send phải kiểm tra email có trong database chưa
                      checkEmailExists(_emailController.text);
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                color: Colors.blue[900],
                child: Text(
                  "Gửi xác nhận",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
