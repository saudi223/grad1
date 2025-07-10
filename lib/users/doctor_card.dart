import 'package:flutter/material.dart';
import 'package:graduate/users/Doctor_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final String doctorId;

  const DoctorCard({
    required this.doctorData,
    required this.doctorId,
  });

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  String? userId;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  void getCurrentUserData() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('✅ User ID: ${user.uid}');
      setState(() {
        userId = user.uid;
      });
    } else {
      print('❌ No user signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: widget.doctorData['profile_image'] != null
              ? NetworkImage(widget.doctorData['profile_image'])
              : AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp')
          as ImageProvider,
        ),
        title: Text(widget.doctorData['name'] ?? 'Doctor', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),),
        subtitle: Text(widget.doctorData['role'] ?? 'General'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          print('👤 Current UserID is $userId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailsScreen(
                doctorData: widget.doctorData,
                doctorId: widget.doctorId, userId: userId!,
              ),
            ),
          );
        },
      ),
    );
  }
}
