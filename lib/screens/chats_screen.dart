// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'chat_details_screen.dart';

class Chats extends StatelessWidget {
  const Chats({super.key});

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
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(
                      'assets/images/profile-icon-design-free-vector.jpg',
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AHMED',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Diabetic patient',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '12:35 PM',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
              separatorBuilder: (context, index) => SizedBox(
                height: 15,
              ),
              itemCount: 15,
            ),
          ),
        ),
      ],
    );
  }
}