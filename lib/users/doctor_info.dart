// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorInfo extends StatefulWidget {
  const DoctorInfo({super.key});

  @override
  State<DoctorInfo> createState() => _DoctorInfoState();
}

class _DoctorInfoState extends State<DoctorInfo> {
  final User? user = FirebaseAuth.instance.currentUser;
  String name = 'Loading...';
  String phone = 'Loading...';
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctorData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            name = doc['name'] ?? 'Not provided';
            phone = doc['phone_number'] ?? 'Not provided';
            _nameController.text = name;
            _phoneController.text = phone;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching doctor data: $e");
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
            .collection('doctors')
            .doc(user!.uid)
            .update({
          'name': _nameController.text,
          'phone_number': _phoneController.text,
        });

        setState(() {
          name = _nameController.text;
          phone = _phoneController.text;
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
              child:SingleChildScrollView(child: Column(
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
                ],
              ),
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
        child: Column(
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
    );
  }
}