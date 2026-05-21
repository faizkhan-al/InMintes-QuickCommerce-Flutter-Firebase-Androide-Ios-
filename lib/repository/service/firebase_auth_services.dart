import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // create user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // after user creation save user data in firestote
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name':
              name.isEmpty
                  ? "User"
                  : name, //if name not given by user default name is 'user'
          'phone': "", // we have option to add phone later
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential.user;
    } catch (e) {
      print("Some error occured: $e");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Some error occured:$e");
    }
    return null;
  }
}
