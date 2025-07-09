// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:graduate/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:graduate/screens/chats_screen.dart';
import 'package:graduate/grad1/screens/news.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/users/doctor_card.dart';
import 'package:graduate/widgets/health_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      drawer: Drawer(
        width: 250.w,
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

class DoctorsListScreen extends StatefulWidget {
  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  String? userId;
  List<Map<String, dynamic>> bookedDoctors = [];
  bool isLoadingAppointments = true;
  String? error;

  @override
  void initState() {
    super.initState();
    getCurrentUserAndFetchAppointments();
  }

  Future<void> getCurrentUserAndFetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await fetchBookedDoctors();
    } else {
      setState(() {
        isLoadingAppointments = false;
        error = "User not signed in";
      });
    }
  }

  Future<void> fetchBookedDoctors() async {
    setState(() {
      isLoadingAppointments = true;
      error = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('doctors')
          .get();

      final fetchedDoctors = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['doctorId'] = doc.id;
        return data;
      }).toList();

      setState(() {
        bookedDoctors = fetchedDoctors;
        isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        error = "Error loading appointments";
        isLoadingAppointments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading doctors'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final availableDoctors = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthBanner(
              imageUrl: 'assets/images/doctor_pic.jpg',
              title: 'We care about your health.',
              subtitle:
                  "If you are suffering from any illness, don't forget to contact your doctor.",
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Booked Doctors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 120,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: isLoadingAppointments
                  ? Center(child: CircularProgressIndicator())
                  : (bookedDoctors.isEmpty
                      ? Center(child: Text('No doctors found.'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: bookedDoctors.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final doctor = bookedDoctors[index];
                            return Card(
                              elevation: 3,
                              color: Colors.white,
                              child: Container(
                                width: 220,
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: doctor['profile_image'] != null
                                              ? NetworkImage(
                                                  doctor['profile_image'])
                                              : AssetImage(
                                                      'assets/images/profile-icon-design-free-vector.jpg')
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['name'] ?? 'Unknown Doctor',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            doctor['specialty'] ?? 'Specialty',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Doctors available now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: availableDoctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 60),
                          SizedBox(height: 10),
                          Text(
                            'No doctors are registered yet.\nPlease check back later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: availableDoctors.length,
                      itemBuilder: (context, index) {
                        var doctor = availableDoctors[index];
                        return DoctorCard(
                          doctorData: doctor.data() as Map<String, dynamic>,
                          doctorId: doctor.id,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
