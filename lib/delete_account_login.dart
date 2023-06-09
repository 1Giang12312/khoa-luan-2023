import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khoa_luan1/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/UserID.dart';
import 'account_profile.dart';
import 'login.dart';

class DeleteAccountLogin extends StatefulWidget {
  @override
  _DeleteAccountLoginState createState() => _DeleteAccountLoginState();
}

class _DeleteAccountLoginState extends State<DeleteAccountLogin> {
  _DeleteAccountLoginState();
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  String? username = '';
  String? password = '';
  late bool isLoading = false;
  @override
  void initState() {
    super.initState();
    currentAccount();
  }

  void currentAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    password = prefs.getString('password');
    print(username);
    print(password);
  }

  void xoaCongViecLienQuan() async {
    FirebaseFirestore.instance
        .collection('cong_viec')
        .where('tai_khoan_id', isEqualTo: UserID.localUID)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    await FirebaseFirestore.instance
        .collection('tai_khoan')
        .doc(UserID.localUID)
        .delete();
  }

  Future<void> logout(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    UserID.localUID = '';
    clearUserCredentials();
    Navigator.of(context).pop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }

  void doiTrangThaiNeuTaiKhoanLaTP() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    final _phong_ban_ID = userDoc['phong_ban_id'];
    if (userDoc['quyen_han_id'] == 'zVwjjMtybarqdSCOqnDT') {
      //đổi trạng thái của phòng ban đó
      try {
        await FirebaseFirestore.instance
            // .collection('tai_khoan')
            // .doc(uid)
            .collection('phong_ban')
            .doc(_phong_ban_ID)
            .update({"is_truong_phong": false});
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xác thực', style: TextStyle(color: Colors.white)),
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
                  SingleChildScrollView(
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.all(12),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Email',
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
                                    return "Email không được để trống";
                                  }
                                  // if (!RegExp("^[a-zA-Z0-9+_.-]+@agu.edu.vn")
                                  //     .hasMatch(value)) {
                                  //   return ("Hãy nhập mail agu");
                                  // }
                                  else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure3,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure3
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure3 = !_isObscure3;
                                        });
                                      }),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Mật khẩu',
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
                                  RegExp regex = new RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Mật khẩu không được để trống!";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("Mật khẩu phải dài hơn 6 kí tự!");
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  passwordController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
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
                                onPressed: () async {
                                  if (emailController.text == username &&
                                      passwordController.text == password) {
                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    User? user = auth.currentUser;
                                    if (user != null) {
                                      AuthCredential credential =
                                          EmailAuthProvider.credential(
                                        email: username!,
                                        password: password!,
                                      );
                                      try {
                                        await user.reauthenticateWithCredential(
                                            credential);
                                        await user.delete();
                                        xoaCongViecLienQuan();
                                        logout(context);
                                        print(
                                            'User account deleted successfully!');
                                      } catch (e) {
                                        print(
                                            'Error deleting user account: $e');
                                      }
                                    }
                                    print('Xoá');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              Color.fromARGB(255, 255, 0, 0),
                                          title: Center(
                                            child: Text(
                                              'Sai thông tin',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  "Xác thực",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Visibility(
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  visible: visible,
                                  child: Container(
                                      child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))),
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
}
