// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/users/doctor_card.dart';
import 'package:graduate/widgets/health_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        error = "Please sign in to view appointments";
      });
    }
  }

  Future<void> fetchBookedDoctors() async {
    setState(() {
      isLoadingAppointments = true;
      error = null;
    });

    try {
      // Get booked doctor references from patients collection
      final bookedRefs = await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .collection('booked_doctors')
          .get();

      // Fetch complete doctor data for each booked doctor
      final doctorFutures = bookedRefs.docs.map((doc) async {
        final doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doc.id)
            .get();

        if (doctorDoc.exists) {
          return {
            ...doctorDoc.data() as Map<String, dynamic>,
            'booking_id': doc.id,  // Keep reference to booking document
          };
        }
        return null;
      }).toList();

      final fetchedDoctors = (await Future.wait(doctorFutures))
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        bookedDoctors = fetchedDoctors;
        isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load appointments: ${e.toString()}";
        isLoadingAppointments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')  // Changed from 'users' to 'doctors'
          .orderBy('name')       // Added sorting
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Failed to load doctors',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final availableDoctors = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthBanner(
              imageUrl: 'assets/images/nobookeddoctors.png',
              title: 'We care about your health.',
              subtitle: "If you are suffering from any illness, don't forget to contact your doctor.",
            ),

            // Booked Doctors Section
            if (error != null)
              Padding(
                padding:  EdgeInsets.all(8.0.r),
                child: Text(error!, style: TextStyle(color: Colors.red)),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Your Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: isLoadingAppointments
                  ? Center(child: CircularProgressIndicator())
                  : bookedDoctors.isEmpty
                  ? Center(
                child: Text(
                  'No upcoming appointments',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bookedDoctors.length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final doctor = bookedDoctors[index];
                  return GestureDetector(
                    onTap: () {
                      // Add navigation to appointment details
                    },
                    child:

                    Card(
                      elevation: 3,
                      child: Container(
                        width: 220,
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: doctor['profile_image'] != null
                                  ? NetworkImage(doctor['profile_image'])
                                  : AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp') as ImageProvider,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['name'] ?? 'Dr. Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    doctor['specialty'] ?? 'General',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Available Doctors Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Available Doctors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: availableDoctors.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No doctors available at this time',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: availableDoctors.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var doctor = availableDoctors[index];
                  return DoctorCard(
                    doctorData: {
                      ...doctor.data() as Map<String, dynamic>,
                      'uid': doctor.id,  // Ensure ID is passed
                    },
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