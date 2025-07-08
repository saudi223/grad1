// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:graduate/screens/Doctor_profile.dart';
import 'package:graduate/screens/patient_profile.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:graduate/widgets/custom_button.dart';

enum UserRole {
  patient,
  doctor,
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Expanded(
              child: RadioListTile<UserRole>(
                title: Text("Patient"),
                value: UserRole.patient,
                groupValue: _selectedRole,
                onChanged: (UserRole? value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<UserRole>(
                title: Text("Doctor"),
                value: UserRole.doctor,
                groupValue: _selectedRole,
                onChanged: (UserRole? value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Future<void> _register() async {
    if (_isLoading) return;

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate password length
    if (_pwController.text.length < 6) {
      _showErrorDialog("Password too short",
          "Password must be at least 6 characters long");
      return;
    }

    // Validate password match
    if (_pwController.text != _confirmController.text) {
      _showErrorDialog("Passwords don't match",
          "Please make sure both passwords are identical");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = AuthService();
      await auth.signUpWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text.trim(),

        role: _selectedRole.toString().split('.').last, // Send role to auth service
      );

      // If signup is successful, navigate to appropriate profile page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _selectedRole == UserRole.doctor
                ? DoctorProfile() // You'll need to import and create this
                : PatientProfile(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Signup Error", e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    _confirmController.dispose();
    super.dispose();
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
                        "Sign Up For Free!",
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
                  padding: EdgeInsets.only(top: 250.sp, left: 30.sp, right: 25.sp),
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "email@gmail.com",
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email_outlined, color: Color(0xff242E49)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.w),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40.h),

                      _buildRoleSelector(),
                      // Password Field
                      TextFormField(
                        controller: _pwController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "*********",
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xff242E49)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.w),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40.h),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "*********",
                          labelText: "Confirm Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xff242E49)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.w),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _pwController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 60.h),

                      // Sign Up Button
                      CustomButton(
                        the_text: _isLoading ? "Creating Account..." : "Sign Up",
                        on_tap: _register,
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

                      // Already have an account? Sign In
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignIn()),
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