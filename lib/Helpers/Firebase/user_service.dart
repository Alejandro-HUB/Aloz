import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<String?> getUserThemeStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    final Stream<String> themeStream = _firestore
        .collection('Users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.get('theme'));

    return themeStream;
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
