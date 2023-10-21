// ignore_for_file: use_build_context_synchronously, duplicate_ignore, prefer_typing_uninitialized_variables, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");

  Future<void> uploadFile(String fileName, var uploadfile, BuildContext context,
      Widget currenPage) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await storage.ref(fileName).putFile(uploadfile);

      //Delete the old profile picture
      await deleteFile('Users',
          FirebaseAuth.instance.currentUser!.uid.toString(), "profile_picture");

      //Put the path of the file into firestore
      // ignore: use_build_context_synchronously
      addImageToFireStore(context, fileName);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File Uploaded."),
        ),
      );
    } catch (e) {
      try {
        await storage.ref(fileName).putData(uploadfile);

        //Delete the old profile picture
        await deleteFile(
            'Users',
            FirebaseAuth.instance.currentUser!.uid.toString(),
            "profile_picture");

        //Put the path of the file into firestore
        // ignore: use_build_context_synchronously
        addImageToFireStore(context, fileName);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

    // ignore: use_build_context_synchronously
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
          // ignore: avoid_print
          .then((value) => print('Image Added'))
          // ignore: avoid_print
          .catchError((error) => print('Failed to add Image: $error'));
          
      //Add profile picture to FirebaseAuth as well
      if (imagePath.isNotEmpty) {
        FirebaseAuth.instance.currentUser!.updatePhotoURL(imagePath);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future deleteFile(
      String collectionName, String documentName, String fieldName) async {
    var collection = FirebaseFirestore.instance.collection(collectionName);
    var docSnapshot = await collection.doc(documentName).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?[fieldName]; // <-- The value you want to retrieve.
      // Call setState if needed.
      if (value != null) {
        await storage.ref().child(value).delete();
      }
    }
  }

  Future<ListResult> listFiles(String bucketName, BuildContext context) async {
    ListResult results = await storage.ref(bucketName).listAll();

    for (var ref in results.items) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found file: $ref'),
        ),
      );
    }
    return results;
  }

  Future<String> downloadURL(String imageName) async {
    String downloadURL = "";

    downloadURL = imageName != "" ? await storage.ref(imageName).getDownloadURL() : "";

    return downloadURL;
  }
}

class listImages extends StatelessWidget {
  final collectionName;
  final documentName;
  final fieldName;
  final backgroundColor;
  final double? radius;
  final circleAvatar;
  final width;
  final height;
  final profilePicture;

  const listImages({
    super.key,
    required this.collectionName,
    required this.documentName,
    required this.fieldName,
    required this.circleAvatar,
    required this.profilePicture,
    required this.backgroundColor,
    this.radius = 60.0,
    this.width = 500.0,
    this.height = 500.0,
  });

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    var collection = FirebaseFirestore.instance.collection(collectionName);
    String bucketName = "";

    return Column(
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: collection.doc(documentName).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');

            if (snapshot.hasData) {
              var output = snapshot.data!.data();
              if (output.toString().contains(fieldName)) {
                bucketName = output![fieldName];
              }
              // <-- Your value
              return FutureBuilder(
                  future: storage.downloadURL(bucketName),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done &&
                        bucketName != "") {
                      if (circleAvatar) {
                        return CircleAvatar(
                          backgroundColor: backgroundColor,
                          radius: radius,
                          backgroundImage: NetworkImage(snapshot.data!),
                        );
                      } else {
                        return SizedBox(
                          width: width,
                          height: height,
                          child: Image.network(snapshot.data!,
                              fit: BoxFit.cover),
                        );
                      }
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (!snapshot.hasData || bucketName == "") {
                      if (profilePicture) {
                        return CircleAvatar(
                          backgroundColor: backgroundColor,
                          radius: radius,
                          child: Image.asset("images/profile.png"),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Something went wrong'),
                        ),
                      );
                      return Container();
                    }
                  });
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class listImageNames extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final bucketName;

  const listImageNames({
    super.key,
    required this.bucketName,
  });

  @override
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
                        child: Text(data.items[index].name),
                      ));
                },
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong'),
              ),
            );
            return Container();
          }
        });
  }
}
