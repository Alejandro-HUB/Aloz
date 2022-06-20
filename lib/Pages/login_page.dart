import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Helpers/Constants/Styling.dart';
import "../main.dart";
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Assets/buttons.dart';
import 'forgot_password_page.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 100,
                child: Image.asset("images/mapp.png"),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Hey There,\n Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(height: 40),
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
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
              SizedBox(height: 4),
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white),
                  icon: Icon(Icons.password, color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  helperStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              MyElevatedButton(
                label: 'Sign In',
                width: double.infinity,
                icon: Icon(Icons.lock),
                onPressed: signIn,
                borderRadius: BorderRadius.circular(10),
                child: Text('Sign In'),
              ),
              SizedBox(
                height: 24,
              ),
              GestureDetector(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 20,
                  ),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ForgotPasswordPage(),
                )),
              ),
              SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white),
                  text: 'No account?  ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Sign Up',
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

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MainPage(),
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
