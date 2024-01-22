// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, use_build_context_synchronously, duplicate_ignore, avoid_init_to_null, prefer_typing_uninitialized_variables, use_super_parameters

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Firebase/storage_service.dart';
import 'package:projectcrm/Helpers/Firebase/user_service.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Page",
          style: TextStyle(color: Styling.primaryColor),
        ),
        backgroundColor: Styling.foreground,
        foregroundColor: Styling.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Update your information:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Styling.primaryColor),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: TextFormField(
                  style: TextStyle(
                    color: Styling.primaryColor,
                  ),
                  controller: emailController,
                  cursorColor: Styling.primaryColor,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Change Email",
                    hintText:
                        FirebaseAuth.instance.currentUser!.email.toString(),
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
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 300,
                child: TextFormField(
                  style: TextStyle(color: Styling.primaryColor),
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Change Password",
                    labelStyle: TextStyle(color: Styling.primaryColor),
                    icon: Icon(Icons.password, color: Styling.primaryColor),
                    hintStyle: TextStyle(color: Styling.primaryColor),
                    helperStyle: TextStyle(color: Styling.primaryColor),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Submit Changes',
                width: 150,
                icon: Icon(
                  Icons.update,
                  color: Styling.primaryColor,
                ),
                onPressed: () async {
                  updateUserDetails(emailController.text.toString(),
                      passwordController.text.toString());
                },
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 40),
              Text(
                'Update your Profile Picture:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Styling.primaryColor),
              ),
              const SizedBox(height: 20),
              listImages(
                backgroundColor: Styling.gradient2,
                collectionName: "Users",
                // ignore: prefer_if_null_operators
                documentName: FirebaseAuth.instance.currentUser!.uid == null
                    ? ""
                    : FirebaseAuth.instance.currentUser!.uid,
                fieldName: "profile_picture",
                circleAvatar: true,
                profilePicture: true,
              ),
              const SizedBox(height: 20),
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Upload File',
                width: 150,
                icon: Icon(
                  Icons.cloud,
                  color: Styling.primaryColor,
                ),
                onPressed: uploadProfilePicture,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future updateUserDetails(String email, String password) async {
    if (email != null && email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser!.updateEmail(email);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Updated Email: Logging you out..."),
          ),
        );
        FirebaseAuth.instance.signOut();
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const MainPage(),
        ));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email was not updated."),
        ),
      );
    }
    if (password != null && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser!.updatePassword(password);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Updated Password."),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password was not updated."),
        ),
      );
    }
  }

  Future uploadProfilePicture() async {
    _userService.uploadUserProfilePicture(context);
  }
}
