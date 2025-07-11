import 'package:cloud_firestore/cloud_firestore.dart';
class Conversation {
  final String conversationId;
  final List<String> participants;
  final String patientId;
  final String doctorId;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Conversation({
    required this.conversationId,
    required this.participants,
    required this.patientId,
    required this.doctorId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      conversationId: id,
      participants: List<String>.from(map['participants']),
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
    );
  }
}