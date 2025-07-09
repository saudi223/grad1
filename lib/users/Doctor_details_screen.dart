// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctorData;
  final String doctorId;

  const DoctorDetailsScreen({
    required this.doctorData,
    required this.doctorId,
  });

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
                backgroundImage: doctorData['profile_image'] != null
                    ? NetworkImage(doctorData['profile_image'])
                    : AssetImage('assets/images/profile-icon-design-free-vector.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow('Name', doctorData['name'] ?? 'N/A'),
            _buildDetailRow('Specialty', doctorData['specialty'] ?? 'N/A'),
            _buildDetailRow('Phone', doctorData['phone_number'] ?? 'N/A'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Future functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointment booking will be added later')),
                );
              },
              child: Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
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