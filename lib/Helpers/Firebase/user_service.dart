import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
