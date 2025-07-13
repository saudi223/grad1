import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({
    super.key,
    required this.doctorData,
    required this.doctorId,
    required this.userId,
  });

  final Map<String, dynamic> doctorData;
  final String doctorId;
  final String userId;

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isBooked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
  }

  Future<void> _checkBookingStatus() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.userId)
          .collection('booked_doctors')
          .doc(widget.doctorId)
          .get();

      setState(() {
        _isBooked = docSnapshot.exists;
      });
    } catch (e) {
      print("Error checking booking status: $e");
    }
  }

  Future<void> _bookAppointment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.userId)
          .collection('booked_doctors')
          .doc(widget.doctorId)
          .set({
        'bookedAt': FieldValue.serverTimestamp(),
        'doctorName': widget.doctorData['name'],
      });

      setState(() {
        _isBooked = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: widget.doctorData['profile_image'] != null
                    ? NetworkImage(widget.doctorData['profile_image'])
                    : const AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', widget.doctorData['name'] ?? 'N/A'),
            _buildDetailRow('Specialty', widget.doctorData['specialty'] ?? 'N/A'),
            _buildDetailRow('Phone', widget.doctorData['phone_number'] ?? 'N/A'),
            const Spacer(),
            _isBooked
                ? Center(
              child: Text(
                'Already Booked',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
                : ElevatedButton(
              onPressed: _isLoading ? null : _bookAppointment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18)),
          const Divider(),
        ],
      ),
    );
  }
}