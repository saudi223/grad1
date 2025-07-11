
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
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
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final userData = {
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 2. Save to the appropriate collection
      final collection = role == 'doctor'
          ? FirebaseFirestore.instance.collection('doctors')
          : FirebaseFirestore.instance.collection('patients');

      // 3. Use set() with merge: false to create the document
      await collection.doc(userId).set(userData);

      // 4. Also add to users collection for easy queries
      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }
  Future<void> startNewChat(String patientId, String doctorId) async {
    try {
      // 1. Add to patient's doctor_chats
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('doctor_chats')
          .doc(doctorId) // Use doctorId as the document ID
          .set({
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });

      // 2. (Optional) Add to doctor's patient_chats
      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('patient_chats')
          .doc(patientId)
          .set({
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

}