// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:graduate/screens/news.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/users/doctor_chat.dart';
import 'package:graduate/users/doctor_info.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  final List<Widget> _widgetOptions = [
    Center(child: Text('COURSE PAGE')),
    NewsScreen(),
    DoctorChats(),
  ];

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> doctorData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          doctorData = doc.data() as Map<String, dynamic>;
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

  void logout() {
    final _auth = AuthService();
    _auth.signOut();
    Get.to(() => SignIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 16,
        backgroundColor: Colors.white,
        items: [
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
      drawer: Drawer(
        width: 250.w,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
            padding: EdgeInsets.zero,
            children: [
        DrawerHeader(
        decoration: BoxDecoration(
        color: Color(0xff242E49),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: doctorData['profile_image'] != null
                  ? NetworkImage(doctorData['profile_image'])
                  : AssetImage('assets/images/nobookeddoctors.png')
              as ImageProvider,
            ),
            SizedBox(height: 10.h),
            Text(
              doctorData['name'] ?? 'Doctor Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              user?.email ?? 'doctor@email.com',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),


      ListTile(
        leading: Icon(Icons.person, color: Colors.black),
        title: Text('My Profile', style: TextStyle(fontSize: 16.sp)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorInfo()));
        },
      ),
      ListTile(
        leading: Icon(Icons.settings, color: Colors.black),
        title: Text('Settings', style: TextStyle(fontSize: 16.sp)),
        onTap: () {
          // Navigate to settings screen
          Navigator.pop(context);
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.black),
        title: Text('Logout', style: TextStyle(fontSize: 16.sp)),
        onTap: logout,
      ),
      ],
    ),
    ),
    appBar: AppBar(
      iconTheme: IconThemeData(
        size: 35.r,
        color: Colors.white
      ),
    backgroundColor: Color(0xff242E49),
    title: Text(
    "Home",
    style: TextStyle(fontSize: 30, color: Colors.white),
    ),
    actions: [
    IconButton(
    onPressed: logout,
    icon: Icon(Icons.logout, color: Colors.white, size: 30.r),
    )
    ],
    ),
    body: _widgetOptions.elementAt(_currentIndex),
    );
  }
}