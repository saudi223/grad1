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
          backgroundImage: widget.doctorData['profile_image'] != null
              ? NetworkImage(widget.doctorData['profile_image'])
              : AssetImage('assets/images/profile-icon-design-free-vector.jpg')
                  as ImageProvider,
        ),
        title: Text(widget.doctorData['name'] ?? 'Doctor'),
        subtitle: Text(widget.doctorData['specialty'] ?? 'General'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          print('👤 Current UserID is $userId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailsScreen(
                userId: userId!,
                doctorData: widget.doctorData,
                doctorId: widget.doctorId,
              ),
            ),
          );
        },
      ),
    );
  }
}
