// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientInfo extends StatefulWidget {
  const PatientInfo({super.key});

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  final User? user = FirebaseAuth.instance.currentUser;
  String name = 'Loading...';
  String phone = 'Loading...';
  String bloodType = 'Loading...';
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> fetchPatientData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            name = doc['name'] ?? 'Not provided';
            phone = doc['phone_number1'] ?? 'Not provided';
            bloodType = doc['blood_type'] ?? 'Not provided';
            _nameController.text = name;
            _phoneController.text = phone;
            _bloodTypeController.text = bloodType;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching patient data: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(user!.uid)
            .update({
          'name': _nameController.text,
          'phone_number1': _phoneController.text,
          'blood_type': _bloodTypeController.text,
        });

        setState(() {
          name = _nameController.text;
          phone = _phoneController.text;
          bloodType = _bloodTypeController.text;
          isLoading = false;
        });

        Navigator.of(context).pop(); // Close the edit dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print("Error updating profile: $e");
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile', style: TextStyle(fontSize: 20.sp)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: InputDecoration(
                      labelText: 'Blood Type',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your blood type';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _updateProfile,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    final _auth = AuthService();
    _auth.signOut();
    Get.to(() => SignIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontSize: 24.sp)),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout, size: 28.r),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.w),
        child:SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, size: 28.r),
                      title: Text('Name', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text(name, style: TextStyle(fontSize: 18.sp)),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, size: 28.r),
                      title: Text('Phone', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text(phone, style: TextStyle(fontSize: 18.sp)),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.bloodtype, size: 28.r),
                      title: Text('Blood Type', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text(bloodType, style: TextStyle(fontSize: 18.sp)),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, size: 28.r),
                      title: Text('Email', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text(user?.email ?? 'Not provided',
                          style: TextStyle(fontSize: 18.sp)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Edit Profile Button
            Center(
              child: ElevatedButton(
                onPressed: _showEditDialog,
                child: Text('Edit Profile', style: TextStyle(fontSize: 18.sp)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}