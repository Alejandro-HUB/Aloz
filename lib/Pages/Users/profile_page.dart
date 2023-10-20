// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, use_build_context_synchronously, duplicate_ignore, avoid_init_to_null, prefer_typing_uninitialized_variables, use_super_parameters

import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Firebase/storage_service.dart';
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
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Update your information:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Change Email",
                    hintText:
                        FirebaseAuth.instance.currentUser!.email.toString(),
                    labelStyle: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.mail, color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white),
                    helperStyle: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Change Password",
                    labelStyle: TextStyle(color: Colors.white),
                    icon: Icon(Icons.password, color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    helperStyle: TextStyle(color: Colors.white),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              MyElevatedButton(
                label: 'Submit Changes',
                width: 150,
                icon: const Icon(
                  Icons.update,
                  color: Colors.white,
                ),
                onPressed: () async {
                  updateUserDetails(emailController.text.toString(),
                      passwordController.text.toString());
                },
                borderRadius: BorderRadius.circular(10),
                child: const Text('Upload File'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Update your Profile Picture:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              listImages(
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
              MyElevatedButton(
                label: 'Upload File',
                width: 150,
                icon: const Icon(
                  Icons.cloud,
                  color: Colors.white,
                ),
                onPressed: uploadFile,
                borderRadius: BorderRadius.circular(10),
                child: const Text('Upload File'),
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

  Future uploadFile() async {
    final Storage storage = Storage();
    var result = null;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
        allowMultiple: false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (result != null) {
      var uploadfile;

      //Use path for all other platforms except Web
      try {
        uploadfile = File(result.files.single.path);
      }
      //Web does not support the use of path, instead we need to use bytes
      catch (e) {
        uploadfile = result.files.single.bytes;
      }
      // ignore: prefer_interpolation_to_compose_strings
      final fileName = 'UserImages/${FirebaseAuth.instance.currentUser!.uid}/' +
          result.files.first.name;
      storage.uploadFile(fileName, uploadfile, context, const ProfilePage());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No file selected."),
        ),
      );
    }
  }
}
