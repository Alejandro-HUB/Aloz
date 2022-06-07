import 'package:firebase_auth/firebase_auth.dart';
import "../main.dart";
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Assets/buttons.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white),
                icon: Icon(Icons.mail, color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 4),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Colors.white),
                icon: Icon(Icons.password, color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            MyElevatedButton(
              width: double.infinity,
              icon: Icon(Icons.lock),
              onPressed: signIn,
              borderRadius: BorderRadius.circular(10), 
              child: Text('Sign In'),)
          ],
        ),
      );

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }
}