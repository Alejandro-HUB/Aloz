// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import 'package:projectcrm/Helpers/Firebase/user_service.dart';
import '../../main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../Assets/buttons.dart';
import '../Login_Signup/Verification/forgot_password_page.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    super.key,
    required this.onClickedSignUp,
  });

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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 100,
                child: Image.asset("images/${Styling.logo}"),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Hey There,\n Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Styling.primaryColor),
              ),
              const SizedBox(
                height: 40,
              ),
              const SizedBox(height: 40),
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
              const SizedBox(height: 4),
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
              ),
              const SizedBox(height: 10),
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Sign In',
                width: double.infinity,
                icon: Icon(
                  Icons.lock,
                  color: Styling.primaryColor,
                ),
                onPressed: signIn,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(
                height: 24,
              ),
              GestureDetector(
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Styling.blueLight,
                    fontSize: 20,
                  ),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                )),
              ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Styling.primaryColor),
                  text: 'No account?  ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Sign Up',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Styling.blueLight),
                    )
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get user theme
      final userService = UserService();
      String theme = await userService.getUserTheme();
      alozKey.currentState?.rebuildApp(theme);
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
