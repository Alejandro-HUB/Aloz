import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: MyElevatedButton(
                label: 'Upload File',
                width: double.infinity,
                icon: Icon(Icons.lock),
                onPressed: uploadFile,
                borderRadius: BorderRadius.circular(10),
                child: Text('Upload File'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future uploadFile() async {
    final results = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if(results == null)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No file selected."),
        ),
      );
      return null;
    }

    final path = results.files.single.path!;
    final fileName = results.files.single.name;

    print(path);
    print(fileName);
  }
}
