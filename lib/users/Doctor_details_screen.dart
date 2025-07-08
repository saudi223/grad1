// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final String doctorId;
  final String userId;

  const DoctorDetailsScreen({
    required this.doctorData,
    required this.doctorId,
    required this.userId,
  });

  @override
  _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  late Future<bool?> bookedStatusFuture;

  @override
  void initState() {
    super.initState();
    bookedStatusFuture = getDoctorBookedStatus(
      userId: widget.userId,
      doctorId: widget.doctorId,
    );
  }

  void refreshBookedStatus() {
    setState(() {
      bookedStatusFuture = getDoctorBookedStatus(
        userId: widget.userId,
        doctorId: widget.doctorId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: widget.doctorData['profile_image'] != null
                    ? NetworkImage(widget.doctorData['profile_image'])
                    : AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow('Name', widget.doctorData['name'] ?? 'N/A'),
            _buildDetailRow('Specialty', widget.doctorData['specialty'] ?? 'N/A'),
            _buildDetailRow('Phone', widget.doctorData['phone_number'] ?? 'N/A'),
            Spacer(),

            FutureBuilder<bool?>(
              future: bookedStatusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error loading booking status');
                } else {
                  final isBooked = snapshot.data ?? false;
                  if (isBooked) {
                    return Center(
                      child: Text(
                        'Already Booked',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () {
                        addDoctorForUser(
                          userId: widget.userId,
                          doctorId: widget.doctorId,
                          data: widget.doctorData,
                        ).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Booked'),
                            ),
                          );
                          refreshBookedStatus();
                        });
                      },
                      child: Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18)),
          Divider(),
        ],
      ),
    );
  }
}

Future<void> addDoctorForUser({
  required String userId,
  required String doctorId,
  required Map<String, dynamic> data,
}) async {
  try {
    final updatedData = {
      ...data,
      'booked': true,
    };

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('doctors')
        .doc(doctorId);

    await docRef.set(updatedData);

    print("✅ Doctor data added successfully under users/$userId/doctors/$doctorId");
  } catch (e) {
    print("❌ Failed to add doctor data: $e");
  }
}

Future<bool?> getDoctorBookedStatus({
  required String userId,
  required String doctorId,
}) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('doctors')
        .doc(doctorId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('booked')) {
        return data['booked'] as bool?;
      }
    }

    return null;
  } catch (e) {
    print("❌ Failed to fetch doctor booked status: $e");
    return null;
  }
}
