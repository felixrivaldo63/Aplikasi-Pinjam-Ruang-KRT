import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/common/theme_helper.dart';
import 'package:flutter_krt_ruang/widgets/header_widget.dart';

// import 'profile_page.dart';

class RegistrationPage extends StatefulWidget {
  final Function()? onTap;
  const RegistrationPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nomorTelponController = TextEditingController();

  void signUpUser() async {
    final documentReference = await FirebaseFirestore.instance
        .collection('users')
        .doc(_emailController.text)
        .get();
    if (!documentReference.exists) {
      try {
        if (_passwordController.text == _confirmPasswordController.text) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
          DocumentReference documentReference = FirebaseFirestore.instance
              .collection("users")
              .doc(_emailController.text);
          Map<String, dynamic> user = {
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'nomor_telp': _nomorTelponController.text.trim(),
            'role': "normal",
          };
          documentReference.set(user);
        } else if (_passwordController.text !=
            _confirmPasswordController.text) {
          passwordNotMatch();
          return;
        }
        // Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        print("Error Code : " + e.code);
        if (e.code == 'invalid-email') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Format Email Salah!"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok"))
                ],
              );
            },
          );
        } else if (e.code == 'weak-password') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Password Minimal 6 Karakter!"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok"))
                ],
              );
            },
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Email Sudah Terdaftar!"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"))
            ],
          );
        },
      );
    }
  }

  void passwordNotMatch() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.orange,
          title: Text("Password Tidak Sama!",
              style: TextStyle(color: Colors.purple)),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nomorTelponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 150,
              child: HeaderWidget(150, false, Icons.app_registration),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border:
                                      Border.all(width: 5, color: Colors.white),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.app_registration,
                                  color: Colors.orange.shade300,
                                  size: 80.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Nama Depan', 'Masukkan Nama Depan'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nama Depan";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Nama Belakang', 'Masukkan Nama Belakang'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nama Belakang";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: ThemeHelper().textInputDecoration(
                                "Alamat Email", "Masukkan Email Anda"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Email";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: TextFormField(
                            controller: _nomorTelponController,
                            decoration: ThemeHelper().textInputDecoration(
                                "Nomor Telepon", "Masukkan Nomor Telepon"),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nomor Telepon";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: ThemeHelper().textInputDecoration(
                                "Password", "Masukkan Password"),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Pasword";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: ThemeHelper().textInputDecoration(
                                "Konfirmasi Password", "Konfirmasi Password"),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Pasword";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          decoration:
                              ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ThemeHelper().buttonStyle(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Text(
                                "Daftar".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                signUpUser();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah Punya Akun?'),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text('Masuk',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
