import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/users/doctor_card.dart';

class DoctorsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')  // Changed from 'users' to dedicated collection
          .orderBy('name')       // Added sorting by name
          .snapshots(),
      builder: (context, snapshot) {
        // Error handling
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No doctors available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Success state
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = snapshot.data!.docs[index];
            return DoctorCard(
              doctorData: {
                ...doctor.data() as Map<String, dynamic>,
                'uid': doctor.id,  // Ensure doctorId is passed
              },
              doctorId: doctor.id,
            );
          },
        );
      },
    );
  }
}