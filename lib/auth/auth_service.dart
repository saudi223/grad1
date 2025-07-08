import 'dart:ffi';

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
  required String role,
  }) async {
  try {
  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
  );

  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'email': email,
  'role': role,
  'createdAt': FieldValue.serverTimestamp(),
  'uid': userCredential.user!.uid,
  });

  return userCredential;

  } on FirebaseAuthException catch (e) {
  throw Exception(e.code);
  } catch (e) {
  throw Exception('An error occurred during sign up');
  }
  }


  Future<void> signOut() async {
    return await _auth.signOut();
  }

}