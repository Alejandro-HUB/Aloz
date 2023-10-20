// ignore_for_file: library_private_types_in_public_api

import '../login_page.dart';
import '../signup_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override 
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) =>
    isLogin ? LoginWidget(onClickedSignUp: toggle,) : SignUpWidget(onClickedSignIn: toggle,);

    void toggle() => setState(() => isLogin = !isLogin);
}