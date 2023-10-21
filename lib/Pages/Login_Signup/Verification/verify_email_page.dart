// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Home/AppRouter.dart';
import '../../../Assets/buttons.dart';
import '../../../Helpers/Constants/Styling.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

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

    // Check if email is verified
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      // Send verification email and start a timer to check for email verification
      sendVerificationEmail();

      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    // Reload user to get updated email verification status
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();

      // Save user data to Firestore after email verification
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
      await Future.delayed(const Duration(seconds: 5));
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
      ? AppRouter() // If email is verified, navigate to the main widget tree
      : Scaffold(
          appBar: AppBar(
            title: Text('Verify Email',
                style: TextStyle(color: Styling.primaryColor)),
            backgroundColor: Styling.foreground,
            foregroundColor: Styling.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A verification email has been sent.',
                  style: TextStyle(fontSize: 20, color: Styling.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                  label: 'Resend Email',
                  width: double.infinity,
                  icon: Icon(
                    Icons.mail,
                    color: Styling.primaryColor,
                  ),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  borderRadius: BorderRadius.circular(10),
                  child: const Text('Resend Email'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text(
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
