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

  @override
  void initState() {
    super.initState();
    fetchPatientData();
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
                onPressed: () {
                  // Add edit functionality here if needed
                },
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