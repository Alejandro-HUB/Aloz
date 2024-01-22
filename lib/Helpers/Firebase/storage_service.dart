// ignore_for_file: use_build_context_synchronously, duplicate_ignore, prefer_typing_uninitialized_variables, camel_case_types, unused_local_variable, avoid_init_to_null

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadFileToFireStorage(BuildContext context,
      List<String> allowedExtensions, String? folderPath) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    var result = null;
    String? stringToReturn = null;

    // Select file
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
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
      var fileToUpload;

      //Use path for all other platforms except Web
      try {
        fileToUpload = File(result.files.single.path);
      }
      //Web does not support the use of path, instead we need to use bytes
      catch (e) {
        fileToUpload = result.files.single.bytes;
      }

      if (fileToUpload != null) {
        // Upload file to fire storage
        var fileName = folderPath != null
            ? "$folderPath${result.files.first.name}"
            : result.files.first.name;

        try {
          await storage.ref(fileName).putFile(fileToUpload);

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File Uploaded."),
            ),
          );

          stringToReturn = fileName;
        } catch (e) {
          try {
            await storage.ref(fileName).putData(fileToUpload);

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("File Uploaded."),
              ),
            );

            stringToReturn = fileName;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No file found."),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No file selected."),
        ),
      );
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    return stringToReturn;
  }

  Future deleteFile(
      String collectionName, String documentName, String fieldName) async {
    // The file path is stored on a document inside a collection
    var collection = FirebaseFirestore.instance.collection(collectionName);

    // Try to find the document
    var docSnapshot = await collection.doc(documentName).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();

      // Get the file path using the field name
      var value = data?[fieldName];
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

    downloadURL =
        imageName != "" ? await storage.ref(imageName).getDownloadURL() : "";

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
    final StorageService storage = StorageService();
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
                          child:
                              Image.network(snapshot.data!, fit: BoxFit.cover),
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
    final StorageService storage = StorageService();
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
