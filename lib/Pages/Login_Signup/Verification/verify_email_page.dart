import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../Home/widget_tree.dart';
import '../../../Assets/buttons.dart';
import '../../../Helpers/Constants/Styling.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      users
          .doc(FirebaseAuth.instance.currentUser!.uid.toString())
          .set({
            'id': FirebaseAuth.instance.currentUser!.uid,
            'email': FirebaseAuth.instance.currentUser!.email,
            'profile_picture':
                FirebaseAuth.instance.currentUser!.photoURL != null &&
                        FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty
                    ? FirebaseAuth.instance.currentUser!.photoURL
                    : "",
          })
          .then((value) => print('User Added'))
          .catchError((error) => print('Failed to add user: $error'));
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? WidgetTree()
      : Scaffold(
          appBar: AppBar(
            title: Text('Verify Email', style: TextStyle(color: Colors.white)),
            backgroundColor: Styling.purpleLight,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A verification email has been sent.',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                MyElevatedButton(
                  label: 'Resend Email',
                  width: double.infinity,
                  icon: Icon(Icons.mail),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Text('Resend Email'),
                ),
                SizedBox(height: 8),
                TextButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
        );
}
