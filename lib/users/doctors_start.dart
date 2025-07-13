import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/screens/chat_details_screen.dart';
import 'package:graduate/screens/chats_screen.dart';

class DoctorsStart extends StatefulWidget {
  const DoctorsStart({
    super.key,
    required this.doctorData,
    required this.doctorId,
    required this.userId,
  });

  final Map<String, dynamic> doctorData;
  final String doctorId;
  final String userId;

  @override
  State<DoctorsStart> createState() => _DoctorsStartState();
}

class _DoctorsStartState extends State<DoctorsStart> {
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
                    : AssetImage('assets/images/male-doctor-smiling-happy-face-600nw-2481032615.webp')
                as ImageProvider,
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
                  return Text('Error loading status');
                } else {
                  final isBooked = snapshot.data ?? false;
                  return ElevatedButton(
                    onPressed: () async {
                      // First create the chat document if it doesn't exist
                      final chatId = '${widget.userId}_${widget.doctorId}'; // or vice versa

                      try {
                        // Check if chat exists
                        final chatDoc = await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId)
                            .get();

                        if (!chatDoc.exists) {
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .set({
                            'participants': [widget.userId, widget.doctorId],
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // Navigate to chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverId: widget.doctorId,
                              receiverName: widget.doctorData['name'] ?? 'Doctor',
                              isDoctor: false,
                              receiverRole: 'doctor',
                              
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to start chat: $e')),
                        );
                      }
                    },
                    child: Text(
                      isBooked ? 'Start Chat' : 'Book & Chat',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  );
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

Future<bool?> getDoctorBookedStatus({
  required String userId,
  required String doctorId,
}) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(userId)
        .collection('booked_doctors')
        .doc(doctorId);

    final docSnapshot = await docRef.get();
    return docSnapshot.exists;
  } catch (e) {
    print("❌ Failed to fetch doctor booked status: $e");
    return null;
  }
}