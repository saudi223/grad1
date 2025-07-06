// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'HOME PAGE',
    ),
    Text(
      'COURSE PAGE',
    ),
    Text(
      'CONTACT GFG',
    ),
  ];


  void logout(){
    final _auth=AuthService();
    _auth.signOut();
    Get.to(()=>SignIn());
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
      bottomNavigationBar: BottomNavigationBar(items:[
        BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined,color: Colors.black,),label: "doctors",),
        BottomNavigationBarItem(icon: Icon(Icons.live_tv_outlined,color: Colors.black,),label: "Stream"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined,color: Colors.black,),label: "chat",)

      ],
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
      ),
      drawer: Drawer(
        width: 250.w,
      ),
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(onPressed:logout, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
    ),
    );
  }
}
