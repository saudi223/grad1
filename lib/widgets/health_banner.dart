// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthBanner extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const HealthBanner({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  State<HealthBanner> createState() => _HealthBannerState();
}

class _HealthBannerState extends State<HealthBanner> {
  String? userId;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserAndDoctors();
  }

  Future<void> _loadUserAndDoctors() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          error = "⚠️ لا يوجد مستخدم مسجل دخول";
          isLoading = false;
        });
        return;
      }

      setState(() {
        userId = user.uid;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('doctors')
          .get();

      List<Map<String, dynamic>> fetchedDoctors = snapshot.docs.map((doc) {
        final data = doc.data();
        data['doctorId'] = doc.id;
        return data;
      }).toList();

      setState(() {
        doctors = fetchedDoctors;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
        error = "حدث خطأ أثناء تحميل البيانات";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Image.asset(
                widget.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (isLoading)
                    Container()
                  else if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  else
                    Text(
                      'Number of booked doctors: (${doctors.length})',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
