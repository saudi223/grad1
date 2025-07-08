import 'package:flutter/material.dart';
import 'package:graduate/users/Doctor_details_screen.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctorData;
  final String doctorId;

  const DoctorCard({
    required this.doctorData,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: doctorData['profile_image'] != null
              ? NetworkImage(doctorData['profile_image'])
              : AssetImage('assets/images/profile-icon-design-free-vector.jpg') as ImageProvider,
        ),
        title: Text(doctorData['name'] ?? 'Doctor'),
        subtitle: Text(doctorData['specialty'] ?? 'General'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailsScreen(
                doctorData: doctorData,
                doctorId: doctorId,
              ),
            ),
          );
        },
      ),
    );
  }
}