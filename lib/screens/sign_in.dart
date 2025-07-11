// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:graduate/screens/doctor_home.dart';
import 'package:graduate/screens/patient_home.dart';
import 'package:graduate/screens/sign_up.dart';
import 'package:graduate/widgets/custom_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      await auth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _pwController.text.trim(),
      );

      // Get the signed-in user's email
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if email exists in doctors collection
        final doctorQuery = await FirebaseFirestore.instance
            .collection('doctors')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (doctorQuery.docs.isNotEmpty) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DoctorHome()),
            );
          }
          return;
        }

        // If not a doctor, check if patient exists or create new patient
        final patientDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.uid)
            .get();

        if (!patientDoc.exists) {
          // Create basic patient record if doesn't exist
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(user.uid)
              .set({
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PatientHome()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getFirebaseAuthErrorMessage(e);
      if (mounted) {
        _showErrorDialog("Sign In Error", errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Sign In Error",
            e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Login failed: ${e.message}';
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity.w,
        height: double.infinity.h,
        color: Color(0xffF2F5F9),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                // Header Section
                Container(
                  width: double.infinity.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Color(0xff242E49),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25.sp),
                      bottomRight: Radius.circular(25.sp),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),
                      Image.asset("assets/images/Vector.png"),
                      SizedBox(height: 40.h),
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Padding(
                  padding: EdgeInsets.only(
                      top: 250.sp, left: 30.sp, right: 25.sp),
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "email@gmail.com",
                          labelText: "Email Address",
                          prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xff242E49)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40.h),

                      // Password Field
                      TextFormField(
                        controller: _pwController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          hintText: "*********",
                          labelText: "Password",
                          prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xff242E49)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 60.h),

                      // Sign In Button
                      CustomButton(
                        the_text: _isLoading ? "Signing In..." : "Sign In",
                        on_tap: _signIn,
                        width: 400.w,
                        height: 50.h,
                      ),
                      SizedBox(height: 30.h),

                      // Divider with OR
                      Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xff5D6A85))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text("OR", style: TextStyle(color: Color(0xff5D6A85))),
                          ),
                          Expanded(child: Divider(color: Color(0xff5D6A85))),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Don't have an account? Sign Up
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUp()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}