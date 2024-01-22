// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Firebase/storage_service.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<String> getUserTheme() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.get('theme') ?? 'aloz';
      }
    }
    return 'aloz'; // Default theme if not found
  }

  void updateTheme(String theme) async {
    // Get the current user
    User? user = _auth.currentUser;

    if (user != null) {
      // Update the theme in Firestore
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .update({'theme': theme});
    }
  }

  void uploadUserProfilePicture(BuildContext context) async {
    try {
      var fileName = await _storageService.uploadFileToFireStorage(
          context,
          ['jpg', 'png', 'jpeg'],
          "UserImages/${FirebaseAuth.instance.currentUser!.uid}/");

      //Delete the old profile picture
      await _storageService.deleteFile('Users',
          FirebaseAuth.instance.currentUser!.uid.toString(), "profile_picture");

      if (fileName != null) {
        //Put the path of the file into firestore
        await addUserImageToFireStore(context, fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future addUserImageToFireStore(BuildContext context, String imagePath) async {
    //Put the path of the file into firestore
    try {
      _firestore
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid.toString())
          .update({
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
}
