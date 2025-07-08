// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_details_screen.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserAndDoctors();
  }

  Future<void> loadUserAndDoctors() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          error = "⚠️ لا يوجد مستخدم مسجل دخول.";
        });
        return;
      }

      userId = user.uid;
      await fetchDoctors();
    } catch (e) {
      print('❌ Error in loadUserAndDoctors: $e');
      setState(() {
        isLoading = false;
        error = "❌ حدث خطأ أثناء تحميل البيانات.";
      });
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('doctors')
          .get();

      final fetchedDoctors = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['doctorId'] = doc.id;
        return data;
      }).toList();

      setState(() {
        doctors = fetchedDoctors;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      print("❌ Error fetching doctors: $e");
      setState(() {
        isLoading = false;
        error = "❌ فشل في جلب البيانات.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : doctors.isEmpty
                        ? Center(
                            child: Image.asset(
                            'assets/images/nobookeddoctors.png',
                            color: Colors.blueAccent,
                          ))
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: doctor['profile_image'] !=
                                          null
                                      ? NetworkImage(doctor['profile_image'])
                                      : AssetImage(
                                          'assets/images/profile-icon-design-free-vector.jpg',
                                        ) as ImageProvider,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['name'] ?? 'Unknown',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      doctor['role'] ?? 'Specialty',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  doctor['last_message_time'] ?? '',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(),
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 15),
                            itemCount: doctors.length,
                          ),
          ),
        ),
      ],
    );
  }
}
