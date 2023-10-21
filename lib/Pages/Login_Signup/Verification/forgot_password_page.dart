// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import '../../../Assets/buttons.dart';
import '../../../Helpers/Constants/Styling.dart';
import '../../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Styling.foreground,
          foregroundColor: Styling.primaryColor,
          elevation: 0,
          title: Text(
            'Reset Password',
            style: TextStyle(color: Styling.primaryColor),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Receive an email to\n reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Styling.primaryColor),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    style: TextStyle(color: Styling.primaryColor),
                    controller: emailController,
                    cursorColor: Styling.primaryColor,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Styling.primaryColor),
                      icon: Icon(Icons.mail, color: Styling.primaryColor),
                      hintStyle: TextStyle(color: Styling.primaryColor),
                      helperStyle: TextStyle(color: Styling.primaryColor),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GradientButton(
                    gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                    label: 'Reset Password',
                    width: double.infinity,
                    icon: Icon(
                      Icons.restart_alt_outlined,
                      color: Styling.primaryColor,
                    ),
                    onPressed: verifyEmail,
                    borderRadius: BorderRadius.circular(10),
                    child: const Text('Reset Password'),
                  ),
                ],
              )),
        ),
      );

  Future verifyEmail() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password Reset Email Sent.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const MainPage(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
