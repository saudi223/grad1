import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduate/users/doctors_start.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> bookedDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookedDoctors();
  }

  Future<void> _fetchBookedDoctors() async {
    if (user == null) return;

    try {
      QuerySnapshot bookedRefs = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user!.uid)
          .collection('booked_doctors')
          .get();

      List<Map<String, dynamic>> fetchedDoctors = [];

      for (var doc in bookedRefs.docs) {
        DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doc.id)
            .get();

        if (doctorDoc.exists) {
          fetchedDoctors.add({
            ...doctorDoc.data() as Map<String, dynamic>,
            'booking_id': doc.id,
          });
        }
      }

      setState(() {
        bookedDoctors = fetchedDoctors;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching booked doctors: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments', style: TextStyle(fontSize: 24.sp)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookedDoctors.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 60, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No booked doctors found',
              style: TextStyle(fontSize: 18.sp),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: bookedDoctors.length,
        itemBuilder: (context, index) {
          final doctor = bookedDoctors[index];
          return InkWell(
            onTap: () {
              Get.to(() => DoctorsStart(
                doctorData: doctor,
                doctorId: doctor['booking_id'] ?? '',
                userId: user?.uid ?? '',
              ));
            },
            child: Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 16.h),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundImage: doctor['profile_image'] != null
                          ? NetworkImage(doctor['profile_image'])
                          : AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp')
                      as ImageProvider,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'] ?? 'Dr. Unknown',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            doctor['specialty'] ?? 'General Practitioner',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
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
    );
  }
}