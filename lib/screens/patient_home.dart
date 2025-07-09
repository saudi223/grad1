// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/chats_screen.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/users/doctor_card.dart';


class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  final List<Widget> _widgetOptions = [
    DoctorsListScreen(), // Shows list of doctors
    Center(child: Text('COURSE PAGE')),
    Chats()
  ];

  void logout() {
    final _auth = AuthService();
    _auth.signOut();
    Get.to(() => SignIn());
  }

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 250.w,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 17,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.medical_services_outlined, color: Colors.blue),
            icon: Icon(Icons.medical_services_outlined, color: Colors.black),
            label: "Doctors",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.live_tv_outlined, color: Colors.blue),
            icon: Icon(Icons.live_tv_outlined, color: Colors.black),
            label: "Stream",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.chat_outlined, color: Colors.blue),
            icon: Icon(Icons.chat_outlined, color: Colors.black),
            label: "Chat",
          )
        ],
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(

          size: 35.r,
          color: Color(0xff0F67FE)
        ),
        backgroundColor: Color(0xff242E49),
        title: Text("Home", style: TextStyle(fontSize: 30, color: Color(0xff0F67FE))),
        actions: [
          IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout, color: Color(0xff0F67FE), size: 30.r)
          )
        ],
      ),
      body: _widgetOptions.elementAt(_currentIndex),
    );
  }
}

class DoctorsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')  // Changed from 'users' to 'doctors'
          .snapshots(),          // Removed role filter
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error loading doctors'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No doctors available'));
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doctor = snapshot.data!.docs[index];
            return DoctorCard(
              doctorData: doctor.data() as Map<String, dynamic>,
              doctorId: doctor.id,
            );
          },
        );
      },
    );
  }
}