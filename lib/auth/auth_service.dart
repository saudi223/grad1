
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxController {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  Future<UserCredential> signInWithEmailAndPassword(String email,
      password) async {
    try {
      UserCredential usercredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return usercredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email,
      String password, {
        required String role, // Must be either 'patient' or 'doctor'
      }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final userData = {
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userId,
      };

      // 2. Save user data in the correct Firestore collection
      if (role == 'patient') {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(userId)
            .set(userData);
      } else if (role == 'doctor') {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userId)
            .set(userData);
      } else {
        throw Exception('Invalid role. Must be "patient" or "doctor".');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception('An error occurred during sign up: $e');
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

}