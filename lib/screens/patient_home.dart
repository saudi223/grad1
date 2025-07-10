// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/chats_screen.dart';
import 'package:graduate/screens/news.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/users/doctors_list.dart';
import 'package:graduate/users/patient_appointments.dart';
import 'package:graduate/users/patient_info.dart';


class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  final List<Widget> _widgetOptions = [
    DoctorsListScreen(), // Shows list of doctors
    Center(child: Text('COURSE PAGE')),
    NewsScreen(),
    Chats(),
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
      drawer:Drawer(
        width: 250.w,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final patientData = snapshot.data?.data() as Map<String, dynamic>?;
            final email = FirebaseAuth.instance.currentUser?.email ?? 'No email';
            final name = patientData?['name'] ?? 'Patient Name';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundImage: patientData?['profile_image'] != null
                            ? NetworkImage(patientData!['profile_image'])
                            : AssetImage('assets/images/profile-icon-design-free-vector.jpg')
                        as ImageProvider,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PatientInfo()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.medical_services),
                  title: Text('My Appointments'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PatientAppointments()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 330.r),child:
                ListTile(
                  leading: Icon(Icons.logout_outlined),
                  title: Text('logout'),
                  onTap: () {
                    logout();
                  },
                ),)
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 16,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            activeIcon:
            Icon(Icons.medical_services_outlined, color: Colors.blue),
            icon: Icon(Icons.medical_services_outlined, color: Colors.black),
            label: "Doctors",

          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.live_tv_outlined, color: Colors.blue),
            icon: Icon(Icons.live_tv_outlined, color: Colors.black),
            label: "Stream",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.newspaper_outlined, color: Colors.blue),
            icon: Icon(Icons.newspaper_outlined, color: Colors.black),
            label: "News",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.chat_outlined, color: Colors.blue),
            icon: Icon(Icons.chat_outlined, color: Colors.black),
            label: "Chat",
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 35.r,
        ),
        elevation: 5,
        title: Text(
          "Home",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout, size: 30.r))
        ],
      ),
      body: _widgetOptions.elementAt(_currentIndex),
    );
  }
}
