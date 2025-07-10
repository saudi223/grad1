// ignore_for_file: prefer_const_constructors

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
  List<Map<String, dynamic>> bookedDoctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserAndBookedDoctors();
  }

  Future<void> _loadUserAndBookedDoctors() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = "⚠️ User not logged in";
          isLoading = false;
        });
        return;
      }

      setState(() {
        userId = user.uid;
      });

      // Get references to booked doctors from patients collection
      final bookedDoctorsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .collection('booked_doctors')
          .get();

      // Fetch complete doctor data for each booked doctor
      final doctorFutures = bookedDoctorsSnapshot.docs.map((doc) async {
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
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading booked doctors: $e');
      setState(() {
        error = "Error loading appointments";
        isLoading = false;
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
                    CircularProgressIndicator(color: Colors.white)
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
                      'Booked Doctors: ${bookedDoctors.length}',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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