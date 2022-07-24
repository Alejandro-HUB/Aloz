import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Firebase/storage_service.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../main.dart';

class ProfilePage extends StatefulWidget {
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
    final Storage storage = Storage();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Update your information:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Change Email",
                    hintText:
                        FirebaseAuth.instance.currentUser!.email.toString(),
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
              ),
              SizedBox(height: 4),
              SizedBox(
                width: 300,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Change Password",
                    labelStyle: TextStyle(color: Colors.white),
                    icon: Icon(Icons.password, color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    helperStyle: TextStyle(color: Colors.white),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              MyElevatedButton(
                label: 'Submit Changes',
                width: 150,
                icon: Icon(Icons.update),
                onPressed: () async {
                  updateUserDetails(emailController.text.toString(),
                      passwordController.text.toString());
                },
                borderRadius: BorderRadius.circular(10),
                child: Text('Upload File'),
              ),
              SizedBox(height: 40),
              Text(
                'Update your Profile Picture:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),
              listImages(
                collectionName: "Users",
                documentName: FirebaseAuth.instance.currentUser!.uid == null
                    ? ""
                    : FirebaseAuth.instance.currentUser!.uid,
                fieldName: "profile_picture",
                circleAvatar: true,
                profilePicture: true,
              ),
              SizedBox(height: 20),
              MyElevatedButton(
                label: 'Upload File',
                width: 150,
                icon: Icon(Icons.cloud),
                onPressed: uploadFile,
                borderRadius: BorderRadius.circular(10),
                child: Text('Upload File'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated Email: Logging you out..."),
          ),
        );
        FirebaseAuth.instance.signOut();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MainPage(),
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
        SnackBar(
          content: Text("Email was not updated."),
        ),
      );
    }
    if (password != null && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser!.updatePassword(password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated Password."),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      final fileName = 'UserImages/' +
          FirebaseAuth.instance.currentUser!.uid.toString() +
          '/' +
          result.files.first.name;
      storage.uploadFile(fileName, uploadfile, context, ProfilePage());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No file selected."),
        ),
      );
    }
  }
}
