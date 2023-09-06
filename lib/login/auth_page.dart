import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/bottomTabAdmin.dart';
import 'package:flutter_krt_ruang/bottomTabUser.dart';
import 'package:flutter_krt_ruang/login/login_or_register_page.dart';

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // const AuthPage({super.key});

  Widget loginRole = SizedBox();

  Future getDataUser() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is login
          if (snapshot.hasData) {
            DocumentReference documentReference = FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.email);
            documentReference.get().then((datasnapshot) {
              if (datasnapshot.get('role') == "admin") {
                setState(() {
                  loginRole = BottomTabAdmin();
                });
              } else {
                setState(() {
                  loginRole = BottomTabUser();
                });
              }
            });
            return loginRole;
          }
          //user is not login
          else {
            loginRole = SizedBox();
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
