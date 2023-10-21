// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import '../../Assets/buttons.dart';
import '../../main.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    super.key,
    required this.onClickedSignIn,
  });

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
              ),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 100,
                child: Image.asset("images/${Styling.logo}"),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Create account',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Styling.primaryColor),
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                style: TextStyle(color: Styling.primaryColor),
                controller: emailController,
                cursorColor: Styling.primaryColor,
                textInputAction: TextInputAction.next,
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
                height: 4,
              ),
              TextFormField(
                style: TextStyle(color: Styling.primaryColor),
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Styling.primaryColor),
                  icon: Icon(Icons.password, color: Styling.primaryColor),
                  hintStyle: TextStyle(color: Styling.primaryColor),
                  helperStyle: TextStyle(color: Styling.primaryColor),
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Your password must have at least 6 characters.'
                    : null,
              ),
              const SizedBox(height: 20),
              GradientButton(
                gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Sign Up',
                width: double.infinity,
                icon: Icon(
                  Icons.arrow_upward,
                  color: Styling.primaryColor,
                ),
                onPressed: signUp,
                borderRadius: BorderRadius.circular(10),
                child: const Text('Sign Up'),
              ),
              const SizedBox(
                height: 24,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Styling.primaryColor),
                  text: 'Already have an account?  ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: 'Log In',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Styling.blueLight,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
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
