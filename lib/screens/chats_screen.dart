// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduate/screens/chat_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Chats extends StatefulWidget {
  const Chats({super.key});


  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Map<String, dynamic>> chatDoctors = [];
  bool isLoading = true;
  String? error;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          error = "Please sign in to view chats";
        });
        return;
      }

      userId = user.uid;

      await _fetchChatDoctors();
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        isLoading = false;
        error = "Failed to load chats";
      });
    }
  }

  Future<void> _fetchChatDoctors() async {
    try {
      // Get doctor references from patient's chats collection
      final chatRefs = await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .collection('doctor_chats')
          .orderBy('timestamp', descending: true)
          .get();

      // Fetch complete doctor data for each chat
      final doctorFutures = chatRefs.docs.map((doc) async {
        final doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doc.id)
            .get();

        if (doctorDoc.exists) {
          return {
            ...doctorDoc.data() as Map<String, dynamic>,
            'chat_id': doc.id,
            'last_message': doc['lastMessage'],
            'last_message_time': _formatTimestamp(doc['timestamp']),
            'unread_count': doc['unreadCount'] ?? 0,
          };
        }
        return null;
      }).toList();

      final fetchedDoctors = (await Future.wait(doctorFutures))
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        chatDoctors = fetchedDoctors;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching chat doctors: $e");
      setState(() {
        isLoading = false;
        error = "Failed to load chat participants";
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20.0.r),
          child: Text(
            "Messages",
            style: TextStyle(
              fontSize: 24.r,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.r),
                topRight: Radius.circular(35.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
                  spreadRadius: 2.r,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _buildChatList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.r),
            SizedBox(height: 16.h),
            Text(
              error!,
              style: TextStyle(fontSize: 16.r),
            ),
            TextButton(
              onPressed: _loadUserAndChats,
              child: Text("Try Again"),
            ),
          ],
        ),
      );
    }

    if (chatDoctors.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/nobookeddoctors.png',
            height: 150.h,
            width: double.infinity.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'No active chats',
            style: TextStyle(
              fontSize: 20.r,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Book a doctor to start chatting',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.r),
      itemCount: chatDoctors.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final doctor = chatDoctors[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: doctor['profile_image'] != null
                ? NetworkImage(doctor['profile_image'])
                : AssetImage('assets/images/default_doctor.png') as ImageProvider,
          ),
          title: Text(
            doctor['name'] ?? 'Doctor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            doctor['last_message'] ?? 'No messages yet',
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                doctor['last_message_time'] ?? '',
                style: TextStyle(color: Colors.grey),
              ),
              if ((doctor['unread_count'] ?? 0) > 0)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    doctor['unread_count'].toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.r),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  doctorId: doctor['chat_id'],
                  doctorName: doctor['name'],
                ), // ChatPage
              ), // MaterialPageRoute
            ).then((_) => _loadUserAndChats()); // Refresh when returning
          },
        );
      },
    );
  }
}