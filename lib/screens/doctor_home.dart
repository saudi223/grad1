// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  void logout() {
    final _auth = AuthService();
    _auth.signOut();
    Get.to(() => SignIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 250.w,
      ),
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(fontSize: 30, color: Color(0xff0F67FE)),
        ),
        actions: [
          IconButton(
              onPressed: logout,
              icon: Icon(
                Icons.logout,
                color: Color(0xff0F67FE),
                size: 30.r,
              ))
        ],
      ),
    );
  }
}
