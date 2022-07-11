import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/Pages/Users/profile_page.dart';

import '../../Assets/app_bar_widget.dart';
import '../../main.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");

  Future<void> uploadFile(String fileName, var uploadfile, BuildContext context,
      Widget currenPage) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await storage.ref(fileName).putFile(uploadfile);

      //Put the path of the file into firestore
      addImageToFireStore(context, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("File Uploaded."),
        ),
      );
    } catch (e) {
      try {
        await storage.ref(fileName).putData(uploadfile);

        //Put the path of the file into firestore
        addImageToFireStore(context, fileName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File Uploaded."),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    Navigator.pop(context);
  }

  Future addImageToFireStore(BuildContext context, String imagePath) async {
    //Put the path of the file into firestore
    try {
      users
          .doc(FirebaseAuth.instance.currentUser!.uid.toString())
          .set({
            'id': FirebaseAuth.instance.currentUser!.uid,
            'email': FirebaseAuth.instance.currentUser!.email,
            'profile_picture': imagePath,
          })
          .then((value) => print('User Added'))
          .catchError((error) => print('Failed to add user: $error'));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<ListResult> listFiles(String bucketName, BuildContext context) async {
    ListResult results = await storage.ref(bucketName).listAll();

    results.items.forEach((Reference ref) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found file: $ref'),
        ),
      );
    });
    return results;
  }

  Future<String> downloadURL(String imageName) async {
    String downloadURL = await storage.ref(imageName).getDownloadURL();

    return downloadURL;
  }
}

class listImages extends StatelessWidget {
  final bucketName;

  const listImages({
    Key? key,
    required this.bucketName,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return FutureBuilder(
        future: storage.downloadURL(bucketName),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: 300,
              height: 250,
              child: Image.network(snapshot.data!, fit: BoxFit.cover),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Something went wrong'),
              ),
            );
            return Container();
          }
        });
  }
}

class listImageNames extends StatelessWidget {
  final bucketName;

  const listImageNames({
    Key? key,
    required this.bucketName,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return FutureBuilder(
        future: storage.listFiles(bucketName, context),
        builder: (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data!.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final data = snapshot.requireData;
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(data!.items[index].name),
                      ));
                },
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Something went wrong'),
              ),
            );
            return Container();
          }
        });
  }
}
