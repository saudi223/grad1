import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      messageId: id,
      senderId: map['senderId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      read: map['read'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'read': read,
    };
  }
}