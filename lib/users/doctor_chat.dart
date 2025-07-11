import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/screens/chat_details_screen.dart';

class DoctorChats extends StatefulWidget {
  const DoctorChats({super.key});

  @override
  State<DoctorChats> createState() => _DoctorChatsState();
}

class _DoctorChatsState extends State<DoctorChats> {
  List<Map<String, dynamic>> chatPatients = [];
  bool isLoading = true;
  String? error;
  String? doctorId;
  StreamSubscription? _chatsSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeChats();
    _printInitialDebugInfo();
  }

  void _printInitialDebugInfo() {
    final user = FirebaseAuth.instance.currentUser;
    print('Initializing DoctorChats:');
    print('Current User: ${user?.uid}');
    print('Is Authenticated: ${user != null}');
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeChats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          error = "Please sign in to view chats";
        });
        return;
      }

      doctorId = user.uid;
      print('Doctor ID: $doctorId');
      _setupChatsStream();
    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        isLoading = false;
        error = "Failed to initialize chats";
      });
    }
  }

  void _setupChatsStream() {
    print('Setting up stream for doctor: $doctorId');
    _chatsSubscription?.cancel();

    _chatsSubscription = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('patient_chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      print('Received ${snapshot.docs.length} chat documents');
      await _processChatDocuments(snapshot.docs);
    }, onError: (e) {
      print("Stream error: $e");
      setState(() {
        isLoading = false;
        error = "Failed to load chats";
      });
    });
  }

  Future<void> _processChatDocuments(List<QueryDocumentSnapshot> docs) async {
    try {
      final patientFutures = docs.map((doc) async {
        try {
          // Get patient data from the reference document itself
          final lastMessage = doc['lastMessage'] ?? 'No messages yet';
          final timestamp = doc['timestamp'] as Timestamp?;
          final unreadCount = doc['unreadCount'] ?? 0;

          // Get additional patient info
          final patientDoc = await _firestore.collection('patients').doc(doc.id).get();

          return {
            ...?patientDoc.data(),
            'patient_id': doc.id,
            'chat_id': _getChatId(doctorId!, doc.id),
            'last_message': lastMessage,
            'last_message_time': _formatTimestamp(timestamp),
            'unread_count': unreadCount,
          };
        } catch (e) {
          print("Error processing patient ${doc.id}: $e");
          return null;
        }
      }).toList();

      final fetchedPatients = (await Future.wait(patientFutures))
          .whereType<Map<String, dynamic>>()
          .toList();

      if (mounted) {
        setState(() {
          chatPatients = fetchedPatients;
          isLoading = false;
          error = null;
        });
      }
    } catch (e) {
      print("Error processing chats: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          error = "Failed to process chats";
        });
      }
    }
  }
  String _getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
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
              fontSize: 24.sp,
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
                  offset: const Offset(0, 2),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.r),
            SizedBox(height: 16.h),
            Text(error!, style: TextStyle(fontSize: 16.sp)),
            TextButton(
              onPressed: _initializeChats,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (chatPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 48.r, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                print('Current doctor ID: $doctorId');
                print('Checking Firestore path: doctors/$doctorId/patient_chats');
                _firestore.collection('doctors').doc(doctorId).collection('patient_chats').get().then((value) {
                  print('Found ${value.docs.length} patient chats');
                  value.docs.forEach((doc) {
                    print('Chat doc ID: ${doc.id}');
                    print('Chat data: ${doc.data()}');
                  });
                });
              },
              child: const Text('Check Database'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeChats,
      child: ListView.separated(
        padding: EdgeInsets.only(top: 8.h),
        itemCount: chatPatients.length,
        separatorBuilder: (context, index) => Divider(
          height: 1.h,
          indent: 80.w,
          endIndent: 20.w,
        ),
        itemBuilder: (context, index) {
          final patient = chatPatients[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: CircleAvatar(
              radius: 28.r,
              backgroundImage: patient['profile_image'] != null
                  ? NetworkImage(patient['profile_image'] as String)
                  : const AssetImage('assets/images/default_profile.png')
              as ImageProvider,
            ),
            title: Text(
              patient['name']?.toString() ?? 'Patient',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              patient['last_message']?.toString() ?? 'No messages yet',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  patient['last_message_time']?.toString() ?? '',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                if ((patient['unread_count'] as int? ?? 0) > 0)
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: Colors.red,
                    child: Text(
                      patient['unread_count'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    receiverId: patient['patient_id'] as String,
                    receiverName: patient['name'] as String? ?? 'Patient',
                    isDoctor: true,
                  ),
                ),
              ).then((_) => _initializeChats());
            },
          );
        },
      ),
    );
  }
}