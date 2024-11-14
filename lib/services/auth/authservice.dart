import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;

  User? currentUser() {
    return auth.currentUser;
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      DocumentSnapshot userDoc =
          await store.collection('Users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        await store.collection('Users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    }
  }

  Future<void> signOut() async {
    return await auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(
          e.message ?? 'An unknown error occurred while sending reset email.');
    }
  }

  Future<UserCredential> signUpWithEmailAndUsername(
      String email, String password, String username) async {
    try {
      QuerySnapshot result = await store
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      if (result.docs.isNotEmpty) {
        throw Exception('Username is already taken.');
      }

      UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await store.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'created at': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    }
  }
}
