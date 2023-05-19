// ignore_for_file: library_private_types_in_public_api

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Assets/buttons.dart';
import '../../main.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

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
                child: Image.asset("images/mapp.png"),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Create account',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white),
                  icon: Icon(Icons.mail, color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  helperStyle: TextStyle(color: Colors.white),
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
                style: const TextStyle(color: Colors.white),
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white),
                  icon: Icon(Icons.password, color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  helperStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Your password must have at least 6 characters.'
                    : null,
              ),
              const SizedBox(height: 20),
              MyElevatedButton(
                label: 'Sign Up',
                width: double.infinity,
                icon: const Icon(Icons.arrow_upward),
                onPressed: signUp,
                borderRadius: BorderRadius.circular(10),
                child: const Text('Sign Up'),
              ),
              const SizedBox(
                height: 24,
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white),
                  text: 'Already have an account?  ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: 'Log In',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
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
